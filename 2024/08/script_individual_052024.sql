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
  v_dados(v_dados.last()).vr_nrdconta := 99999447;
  v_dados(v_dados.last()).vr_nrctremp := 7716533;
  v_dados(v_dados.last()).vr_vllanmto := 447.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99997940;
  v_dados(v_dados.last()).vr_nrctremp := 6261793;
  v_dados(v_dados.last()).vr_vllanmto := 164.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99991110;
  v_dados(v_dados.last()).vr_nrctremp := 6788141;
  v_dados(v_dados.last()).vr_vllanmto := 39.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99991110;
  v_dados(v_dados.last()).vr_nrctremp := 8163414;
  v_dados(v_dados.last()).vr_vllanmto := 335.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99976854;
  v_dados(v_dados.last()).vr_nrctremp := 5943455;
  v_dados(v_dados.last()).vr_vllanmto := 150.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99546850;
  v_dados(v_dados.last()).vr_nrctremp := 7295553;
  v_dados(v_dados.last()).vr_vllanmto := 40.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99373939;
  v_dados(v_dados.last()).vr_nrctremp := 6856446;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99234645;
  v_dados(v_dados.last()).vr_nrctremp := 7492262;
  v_dados(v_dados.last()).vr_vllanmto := 20209.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99226375;
  v_dados(v_dados.last()).vr_nrctremp := 4922540;
  v_dados(v_dados.last()).vr_vllanmto := 121.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99129973;
  v_dados(v_dados.last()).vr_nrctremp := 7992211;
  v_dados(v_dados.last()).vr_vllanmto := 13.64;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97252735;
  v_dados(v_dados.last()).vr_nrctremp := 5343342;
  v_dados(v_dados.last()).vr_vllanmto := 565.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97153435;
  v_dados(v_dados.last()).vr_nrctremp := 7091891;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91336236;
  v_dados(v_dados.last()).vr_nrctremp := 4604397;
  v_dados(v_dados.last()).vr_vllanmto := 3783.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90438736;
  v_dados(v_dados.last()).vr_nrctremp := 6084116;
  v_dados(v_dados.last()).vr_vllanmto := 241.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89471636;
  v_dados(v_dados.last()).vr_nrctremp := 7550298;
  v_dados(v_dados.last()).vr_vllanmto := 407.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88334635;
  v_dados(v_dados.last()).vr_nrctremp := 6665413;
  v_dados(v_dados.last()).vr_vllanmto := 330.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88308235;
  v_dados(v_dados.last()).vr_nrctremp := 3235912;
  v_dados(v_dados.last()).vr_vllanmto := 12.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87856735;
  v_dados(v_dados.last()).vr_nrctremp := 4857588;
  v_dados(v_dados.last()).vr_vllanmto := 8668.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87856735;
  v_dados(v_dados.last()).vr_nrctremp := 8171723;
  v_dados(v_dados.last()).vr_vllanmto := 16.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86988336;
  v_dados(v_dados.last()).vr_nrctremp := 5349520;
  v_dados(v_dados.last()).vr_vllanmto := 445.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98494546;
  v_dados(v_dados.last()).vr_nrctremp := 5366514;
  v_dados(v_dados.last()).vr_vllanmto := 85.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98166522;
  v_dados(v_dados.last()).vr_nrctremp := 7229630;
  v_dados(v_dados.last()).vr_vllanmto := 12.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98076094;
  v_dados(v_dados.last()).vr_nrctremp := 8045092;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98072609;
  v_dados(v_dados.last()).vr_nrctremp := 5139328;
  v_dados(v_dados.last()).vr_vllanmto := 25128.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98046721;
  v_dados(v_dados.last()).vr_nrctremp := 7509178;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 98028960;
  v_dados(v_dados.last()).vr_nrctremp := 8009812;
  v_dados(v_dados.last()).vr_vllanmto := 19.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97998192;
  v_dados(v_dados.last()).vr_nrctremp := 7965959;
  v_dados(v_dados.last()).vr_vllanmto := 35.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97982733;
  v_dados(v_dados.last()).vr_nrctremp := 8161698;
  v_dados(v_dados.last()).vr_vllanmto := 17.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97982245;
  v_dados(v_dados.last()).vr_nrctremp := 7654661;
  v_dados(v_dados.last()).vr_vllanmto := 11.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97980382;
  v_dados(v_dados.last()).vr_nrctremp := 7351781;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97961280;
  v_dados(v_dados.last()).vr_nrctremp := 3664319;
  v_dados(v_dados.last()).vr_vllanmto := 16.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97933260;
  v_dados(v_dados.last()).vr_nrctremp := 7074929;
  v_dados(v_dados.last()).vr_vllanmto := 12.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97870978;
  v_dados(v_dados.last()).vr_nrctremp := 7410061;
  v_dados(v_dados.last()).vr_vllanmto := 16.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97848239;
  v_dados(v_dados.last()).vr_nrctremp := 7930270;
  v_dados(v_dados.last()).vr_vllanmto := 24.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97816981;
  v_dados(v_dados.last()).vr_nrctremp := 4076508;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97804541;
  v_dados(v_dados.last()).vr_nrctremp := 6809716;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97804541;
  v_dados(v_dados.last()).vr_nrctremp := 7493988;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97796166;
  v_dados(v_dados.last()).vr_nrctremp := 6380322;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97762750;
  v_dados(v_dados.last()).vr_nrctremp := 7164271;
  v_dados(v_dados.last()).vr_vllanmto := 22.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97703273;
  v_dados(v_dados.last()).vr_nrctremp := 4423623;
  v_dados(v_dados.last()).vr_vllanmto := 15.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97693154;
  v_dados(v_dados.last()).vr_nrctremp := 8072790;
  v_dados(v_dados.last()).vr_vllanmto := 20.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97687715;
  v_dados(v_dados.last()).vr_nrctremp := 7059873;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97657077;
  v_dados(v_dados.last()).vr_nrctremp := 6692582;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97657077;
  v_dados(v_dados.last()).vr_nrctremp := 6973498;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97648574;
  v_dados(v_dados.last()).vr_nrctremp := 7685825;
  v_dados(v_dados.last()).vr_vllanmto := 20.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97647519;
  v_dados(v_dados.last()).vr_nrctremp := 6540635;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97633488;
  v_dados(v_dados.last()).vr_nrctremp := 7354171;
  v_dados(v_dados.last()).vr_vllanmto := 31.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97610984;
  v_dados(v_dados.last()).vr_nrctremp := 8123308;
  v_dados(v_dados.last()).vr_vllanmto := 19.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97606863;
  v_dados(v_dados.last()).vr_nrctremp := 6832100;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97584827;
  v_dados(v_dados.last()).vr_nrctremp := 4440402;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97557064;
  v_dados(v_dados.last()).vr_nrctremp := 6947306;
  v_dados(v_dados.last()).vr_vllanmto := 21.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97487309;
  v_dados(v_dados.last()).vr_nrctremp := 7649248;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97486701;
  v_dados(v_dados.last()).vr_nrctremp := 6646862;
  v_dados(v_dados.last()).vr_vllanmto := 25.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97484008;
  v_dados(v_dados.last()).vr_nrctremp := 3969605;
  v_dados(v_dados.last()).vr_vllanmto := 20.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97461954;
  v_dados(v_dados.last()).vr_nrctremp := 7807476;
  v_dados(v_dados.last()).vr_vllanmto := 12.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97452378;
  v_dados(v_dados.last()).vr_nrctremp := 7971361;
  v_dados(v_dados.last()).vr_vllanmto := 20.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97429260;
  v_dados(v_dados.last()).vr_nrctremp := 7821098;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97395820;
  v_dados(v_dados.last()).vr_nrctremp := 6119888;
  v_dados(v_dados.last()).vr_vllanmto := 19.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97394947;
  v_dados(v_dados.last()).vr_nrctremp := 8057847;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97368890;
  v_dados(v_dados.last()).vr_nrctremp := 7024737;
  v_dados(v_dados.last()).vr_vllanmto := 40.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97339164;
  v_dados(v_dados.last()).vr_nrctremp := 7537904;
  v_dados(v_dados.last()).vr_vllanmto := 31.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97332887;
  v_dados(v_dados.last()).vr_nrctremp := 6217026;
  v_dados(v_dados.last()).vr_vllanmto := 10.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97323756;
  v_dados(v_dados.last()).vr_nrctremp := 8124812;
  v_dados(v_dados.last()).vr_vllanmto := 28.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97289566;
  v_dados(v_dados.last()).vr_nrctremp := 7966136;
  v_dados(v_dados.last()).vr_vllanmto := 70.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97286559;
  v_dados(v_dados.last()).vr_nrctremp := 6017285;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97155349;
  v_dados(v_dados.last()).vr_nrctremp := 7196567;
  v_dados(v_dados.last()).vr_vllanmto := 26.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97055719;
  v_dados(v_dados.last()).vr_nrctremp := 4953363;
  v_dados(v_dados.last()).vr_vllanmto := 4857.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97046213;
  v_dados(v_dados.last()).vr_nrctremp := 7838944;
  v_dados(v_dados.last()).vr_vllanmto := 24.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 97031763;
  v_dados(v_dados.last()).vr_nrctremp := 7996986;
  v_dados(v_dados.last()).vr_vllanmto := 22.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96994584;
  v_dados(v_dados.last()).vr_nrctremp := 6912519;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96922940;
  v_dados(v_dados.last()).vr_nrctremp := 7822538;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96922494;
  v_dados(v_dados.last()).vr_nrctremp := 3619639;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96916486;
  v_dados(v_dados.last()).vr_nrctremp := 7912580;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96872276;
  v_dados(v_dados.last()).vr_nrctremp := 8161141;
  v_dados(v_dados.last()).vr_vllanmto := 16.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96868490;
  v_dados(v_dados.last()).vr_nrctremp := 6781425;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96862351;
  v_dados(v_dados.last()).vr_nrctremp := 5625472;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96856050;
  v_dados(v_dados.last()).vr_nrctremp := 6839964;
  v_dados(v_dados.last()).vr_vllanmto := 5866.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96854219;
  v_dados(v_dados.last()).vr_nrctremp := 8038899;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96849304;
  v_dados(v_dados.last()).vr_nrctremp := 8121270;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96846054;
  v_dados(v_dados.last()).vr_nrctremp := 6748175;
  v_dados(v_dados.last()).vr_vllanmto := 1417.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96478837;
  v_dados(v_dados.last()).vr_nrctremp := 5592146;
  v_dados(v_dados.last()).vr_vllanmto := 15.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96477059;
  v_dados(v_dados.last()).vr_nrctremp := 7791921;
  v_dados(v_dados.last()).vr_vllanmto := 29.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96475102;
  v_dados(v_dados.last()).vr_nrctremp := 6906293;
  v_dados(v_dados.last()).vr_vllanmto := 34.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96475102;
  v_dados(v_dados.last()).vr_nrctremp := 7519418;
  v_dados(v_dados.last()).vr_vllanmto := 13.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96407646;
  v_dados(v_dados.last()).vr_nrctremp := 8147004;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96404132;
  v_dados(v_dados.last()).vr_nrctremp := 4521182;
  v_dados(v_dados.last()).vr_vllanmto := 1984.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96373750;
  v_dados(v_dados.last()).vr_nrctremp := 6695451;
  v_dados(v_dados.last()).vr_vllanmto := 20.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96373318;
  v_dados(v_dados.last()).vr_nrctremp := 7940509;
  v_dados(v_dados.last()).vr_vllanmto := 25.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96328789;
  v_dados(v_dados.last()).vr_nrctremp := 8060978;
  v_dados(v_dados.last()).vr_vllanmto := 17.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96290420;
  v_dados(v_dados.last()).vr_nrctremp := 7964200;
  v_dados(v_dados.last()).vr_vllanmto := 22.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96278811;
  v_dados(v_dados.last()).vr_nrctremp := 4816442;
  v_dados(v_dados.last()).vr_vllanmto := 6743.55;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96238690;
  v_dados(v_dados.last()).vr_nrctremp := 6864662;
  v_dados(v_dados.last()).vr_vllanmto := 24.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96215755;
  v_dados(v_dados.last()).vr_nrctremp := 8045712;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96210257;
  v_dados(v_dados.last()).vr_nrctremp := 8062195;
  v_dados(v_dados.last()).vr_vllanmto := 22.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96184558;
  v_dados(v_dados.last()).vr_nrctremp := 7380652;
  v_dados(v_dados.last()).vr_vllanmto := 21.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96179538;
  v_dados(v_dados.last()).vr_nrctremp := 8110756;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96170310;
  v_dados(v_dados.last()).vr_nrctremp := 8039087;
  v_dados(v_dados.last()).vr_vllanmto := 16.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96158964;
  v_dados(v_dados.last()).vr_nrctremp := 7955031;
  v_dados(v_dados.last()).vr_vllanmto := 31.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96135310;
  v_dados(v_dados.last()).vr_nrctremp := 3730749;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96129719;
  v_dados(v_dados.last()).vr_nrctremp := 7930804;
  v_dados(v_dados.last()).vr_vllanmto := 36.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96122153;
  v_dados(v_dados.last()).vr_nrctremp := 7815986;
  v_dados(v_dados.last()).vr_vllanmto := 12.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96113057;
  v_dados(v_dados.last()).vr_nrctremp := 6828075;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96107839;
  v_dados(v_dados.last()).vr_nrctremp := 8134609;
  v_dados(v_dados.last()).vr_vllanmto := 16.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96095733;
  v_dados(v_dados.last()).vr_nrctremp := 6071851;
  v_dados(v_dados.last()).vr_vllanmto := 15.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96083301;
  v_dados(v_dados.last()).vr_nrctremp := 6916215;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96079541;
  v_dados(v_dados.last()).vr_nrctremp := 5552101;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96038306;
  v_dados(v_dados.last()).vr_nrctremp := 4984115;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96033576;
  v_dados(v_dados.last()).vr_nrctremp := 6814009;
  v_dados(v_dados.last()).vr_vllanmto := 20.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96030992;
  v_dados(v_dados.last()).vr_nrctremp := 4606072;
  v_dados(v_dados.last()).vr_vllanmto := 12.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96018399;
  v_dados(v_dados.last()).vr_nrctremp := 7120866;
  v_dados(v_dados.last()).vr_vllanmto := 22.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 95954295;
  v_dados(v_dados.last()).vr_nrctremp := 4815888;
  v_dados(v_dados.last()).vr_vllanmto := 8156.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 95939172;
  v_dados(v_dados.last()).vr_nrctremp := 8099385;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93999585;
  v_dados(v_dados.last()).vr_nrctremp := 7499050;
  v_dados(v_dados.last()).vr_vllanmto := 22.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93994265;
  v_dados(v_dados.last()).vr_nrctremp := 6858385;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93989350;
  v_dados(v_dados.last()).vr_nrctremp := 8116304;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93979371;
  v_dados(v_dados.last()).vr_nrctremp := 7934000;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93979371;
  v_dados(v_dados.last()).vr_nrctremp := 7347472;
  v_dados(v_dados.last()).vr_vllanmto := 12.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93979355;
  v_dados(v_dados.last()).vr_nrctremp := 7353486;
  v_dados(v_dados.last()).vr_vllanmto := 12.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93970242;
  v_dados(v_dados.last()).vr_nrctremp := 6272562;
  v_dados(v_dados.last()).vr_vllanmto := 21.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93927215;
  v_dados(v_dados.last()).vr_nrctremp := 7584106;
  v_dados(v_dados.last()).vr_vllanmto := 19.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93915730;
  v_dados(v_dados.last()).vr_nrctremp := 7356718;
  v_dados(v_dados.last()).vr_vllanmto := 29.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93912560;
  v_dados(v_dados.last()).vr_nrctremp := 4428207;
  v_dados(v_dados.last()).vr_vllanmto := 15.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93912560;
  v_dados(v_dados.last()).vr_nrctremp := 7988418;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93862903;
  v_dados(v_dados.last()).vr_nrctremp := 7169579;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93862334;
  v_dados(v_dados.last()).vr_nrctremp := 7387011;
  v_dados(v_dados.last()).vr_vllanmto := 20.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93845634;
  v_dados(v_dados.last()).vr_nrctremp := 7939803;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93840195;
  v_dados(v_dados.last()).vr_nrctremp := 8147855;
  v_dados(v_dados.last()).vr_vllanmto := 20.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93824432;
  v_dados(v_dados.last()).vr_nrctremp := 8171747;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93805942;
  v_dados(v_dados.last()).vr_nrctremp := 5963471;
  v_dados(v_dados.last()).vr_vllanmto := 12.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93803397;
  v_dados(v_dados.last()).vr_nrctremp := 6816723;
  v_dados(v_dados.last()).vr_vllanmto := 20.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93762771;
  v_dados(v_dados.last()).vr_nrctremp := 7862598;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93695489;
  v_dados(v_dados.last()).vr_nrctremp := 8000830;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93690355;
  v_dados(v_dados.last()).vr_nrctremp := 6506789;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93658028;
  v_dados(v_dados.last()).vr_nrctremp := 8112105;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93658028;
  v_dados(v_dados.last()).vr_nrctremp := 8112130;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93631812;
  v_dados(v_dados.last()).vr_nrctremp := 7257531;
  v_dados(v_dados.last()).vr_vllanmto := 11.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93623623;
  v_dados(v_dados.last()).vr_nrctremp := 7524195;
  v_dados(v_dados.last()).vr_vllanmto := 30.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93614080;
  v_dados(v_dados.last()).vr_nrctremp := 8002334;
  v_dados(v_dados.last()).vr_vllanmto := 20.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93582528;
  v_dados(v_dados.last()).vr_nrctremp := 6907395;
  v_dados(v_dados.last()).vr_vllanmto := 27146.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93561083;
  v_dados(v_dados.last()).vr_nrctremp := 7951169;
  v_dados(v_dados.last()).vr_vllanmto := 16.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93483805;
  v_dados(v_dados.last()).vr_nrctremp := 7932571;
  v_dados(v_dados.last()).vr_vllanmto := 14.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93483295;
  v_dados(v_dados.last()).vr_nrctremp := 7873099;
  v_dados(v_dados.last()).vr_vllanmto := 15.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93480962;
  v_dados(v_dados.last()).vr_nrctremp := 5539306;
  v_dados(v_dados.last()).vr_vllanmto := 12.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93475357;
  v_dados(v_dados.last()).vr_nrctremp := 7955345;
  v_dados(v_dados.last()).vr_vllanmto := 17.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93461550;
  v_dados(v_dados.last()).vr_nrctremp := 7375350;
  v_dados(v_dados.last()).vr_vllanmto := 23.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93450788;
  v_dados(v_dados.last()).vr_nrctremp := 7820345;
  v_dados(v_dados.last()).vr_vllanmto := 20.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93421370;
  v_dados(v_dados.last()).vr_nrctremp := 7353975;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93385315;
  v_dados(v_dados.last()).vr_nrctremp := 8146715;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93324413;
  v_dados(v_dados.last()).vr_nrctremp := 7524850;
  v_dados(v_dados.last()).vr_vllanmto := 22.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93284667;
  v_dados(v_dados.last()).vr_nrctremp := 8076928;
  v_dados(v_dados.last()).vr_vllanmto := 34.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93279477;
  v_dados(v_dados.last()).vr_nrctremp := 6507300;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93278799;
  v_dados(v_dados.last()).vr_nrctremp := 5743491;
  v_dados(v_dados.last()).vr_vllanmto := 373.45;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93269366;
  v_dados(v_dados.last()).vr_nrctremp := 7619314;
  v_dados(v_dados.last()).vr_vllanmto := 21.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93242158;
  v_dados(v_dados.last()).vr_nrctremp := 7529126;
  v_dados(v_dados.last()).vr_vllanmto := 30.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93236999;
  v_dados(v_dados.last()).vr_nrctremp := 7891446;
  v_dados(v_dados.last()).vr_vllanmto := 22.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93233060;
  v_dados(v_dados.last()).vr_nrctremp := 7990127;
  v_dados(v_dados.last()).vr_vllanmto := 15.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93211350;
  v_dados(v_dados.last()).vr_nrctremp := 4802898;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93202148;
  v_dados(v_dados.last()).vr_nrctremp := 6695236;
  v_dados(v_dados.last()).vr_vllanmto := 13.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93186789;
  v_dados(v_dados.last()).vr_nrctremp := 6522055;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93154410;
  v_dados(v_dados.last()).vr_nrctremp := 8155385;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93133804;
  v_dados(v_dados.last()).vr_nrctremp := 5432971;
  v_dados(v_dados.last()).vr_vllanmto := 13.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93129203;
  v_dados(v_dados.last()).vr_nrctremp := 7915347;
  v_dados(v_dados.last()).vr_vllanmto := 27.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93095570;
  v_dados(v_dados.last()).vr_nrctremp := 4469248;
  v_dados(v_dados.last()).vr_vllanmto := 10.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93041845;
  v_dados(v_dados.last()).vr_nrctremp := 5661497;
  v_dados(v_dados.last()).vr_vllanmto := 21.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88641236;
  v_dados(v_dados.last()).vr_nrctremp := 6080438;
  v_dados(v_dados.last()).vr_vllanmto := 33.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84785136;
  v_dados(v_dados.last()).vr_nrctremp := 7841256;
  v_dados(v_dados.last()).vr_vllanmto := 28.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 96860685;
  v_dados(v_dados.last()).vr_nrctremp := 5545964;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93026749;
  v_dados(v_dados.last()).vr_nrctremp := 7462502;
  v_dados(v_dados.last()).vr_vllanmto := 26.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93003919;
  v_dados(v_dados.last()).vr_nrctremp := 7780254;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 93002300;
  v_dados(v_dados.last()).vr_nrctremp := 7498559;
  v_dados(v_dados.last()).vr_vllanmto := 14.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92984770;
  v_dados(v_dados.last()).vr_nrctremp := 7912106;
  v_dados(v_dados.last()).vr_vllanmto := 48.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92921841;
  v_dados(v_dados.last()).vr_nrctremp := 7309388;
  v_dados(v_dados.last()).vr_vllanmto := 17.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92899420;
  v_dados(v_dados.last()).vr_nrctremp := 7539142;
  v_dados(v_dados.last()).vr_vllanmto := 16.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92868240;
  v_dados(v_dados.last()).vr_nrctremp := 7053526;
  v_dados(v_dados.last()).vr_vllanmto := 11.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92859577;
  v_dados(v_dados.last()).vr_nrctremp := 7791721;
  v_dados(v_dados.last()).vr_vllanmto := 15.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92814964;
  v_dados(v_dados.last()).vr_nrctremp := 6588897;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92793045;
  v_dados(v_dados.last()).vr_nrctremp := 5170845;
  v_dados(v_dados.last()).vr_vllanmto := 55.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92776043;
  v_dados(v_dados.last()).vr_nrctremp := 6245675;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92715265;
  v_dados(v_dados.last()).vr_nrctremp := 8079942;
  v_dados(v_dados.last()).vr_vllanmto := 29.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92686796;
  v_dados(v_dados.last()).vr_nrctremp := 6250804;
  v_dados(v_dados.last()).vr_vllanmto := 36.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92682065;
  v_dados(v_dados.last()).vr_nrctremp := 7452294;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92627757;
  v_dados(v_dados.last()).vr_nrctremp := 7368505;
  v_dados(v_dados.last()).vr_vllanmto := 125.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92625177;
  v_dados(v_dados.last()).vr_nrctremp := 4178604;
  v_dados(v_dados.last()).vr_vllanmto := 280.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92621120;
  v_dados(v_dados.last()).vr_nrctremp := 7881054;
  v_dados(v_dados.last()).vr_vllanmto := 52.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92608493;
  v_dados(v_dados.last()).vr_nrctremp := 7368857;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92550592;
  v_dados(v_dados.last()).vr_nrctremp := 2655988;
  v_dados(v_dados.last()).vr_vllanmto := 1197.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92527981;
  v_dados(v_dados.last()).vr_nrctremp := 7658114;
  v_dados(v_dados.last()).vr_vllanmto := 15.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92497322;
  v_dados(v_dados.last()).vr_nrctremp := 6625085;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92494668;
  v_dados(v_dados.last()).vr_nrctremp := 8177033;
  v_dados(v_dados.last()).vr_vllanmto := 30.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92443516;
  v_dados(v_dados.last()).vr_nrctremp := 7095762;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92434584;
  v_dados(v_dados.last()).vr_nrctremp := 6212102;
  v_dados(v_dados.last()).vr_vllanmto := 16.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92419348;
  v_dados(v_dados.last()).vr_nrctremp := 7433877;
  v_dados(v_dados.last()).vr_vllanmto := 15.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92416934;
  v_dados(v_dados.last()).vr_nrctremp := 7518679;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92347169;
  v_dados(v_dados.last()).vr_nrctremp := 6573772;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92304630;
  v_dados(v_dados.last()).vr_nrctremp := 7709609;
  v_dados(v_dados.last()).vr_vllanmto := 55.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92165826;
  v_dados(v_dados.last()).vr_nrctremp := 6700712;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92085083;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 2193.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92076572;
  v_dados(v_dados.last()).vr_nrctremp := 6695190;
  v_dados(v_dados.last()).vr_vllanmto := 15.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92071830;
  v_dados(v_dados.last()).vr_nrctremp := 7918071;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92020950;
  v_dados(v_dados.last()).vr_nrctremp := 7644729;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91974550;
  v_dados(v_dados.last()).vr_nrctremp := 7599513;
  v_dados(v_dados.last()).vr_vllanmto := 15.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91959772;
  v_dados(v_dados.last()).vr_nrctremp := 7962578;
  v_dados(v_dados.last()).vr_vllanmto := 18.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91948410;
  v_dados(v_dados.last()).vr_nrctremp := 7128556;
  v_dados(v_dados.last()).vr_vllanmto := 13.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91941474;
  v_dados(v_dados.last()).vr_nrctremp := 8016547;
  v_dados(v_dados.last()).vr_vllanmto := 18.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91941229;
  v_dados(v_dados.last()).vr_nrctremp := 3990688;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91939674;
  v_dados(v_dados.last()).vr_nrctremp := 4800878;
  v_dados(v_dados.last()).vr_vllanmto := 33.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91934966;
  v_dados(v_dados.last()).vr_nrctremp := 8159348;
  v_dados(v_dados.last()).vr_vllanmto := 28273.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91934923;
  v_dados(v_dados.last()).vr_nrctremp := 8027942;
  v_dados(v_dados.last()).vr_vllanmto := 18.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91896770;
  v_dados(v_dados.last()).vr_nrctremp := 7948180;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91873215;
  v_dados(v_dados.last()).vr_nrctremp := 7554412;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91858330;
  v_dados(v_dados.last()).vr_nrctremp := 6636405;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91846781;
  v_dados(v_dados.last()).vr_nrctremp := 6104579;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91835437;
  v_dados(v_dados.last()).vr_nrctremp := 7327691;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91828295;
  v_dados(v_dados.last()).vr_nrctremp := 4644755;
  v_dados(v_dados.last()).vr_vllanmto := 3272.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91801001;
  v_dados(v_dados.last()).vr_nrctremp := 7571035;
  v_dados(v_dados.last()).vr_vllanmto := 13.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91726620;
  v_dados(v_dados.last()).vr_nrctremp := 7994967;
  v_dados(v_dados.last()).vr_vllanmto := 13.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91726603;
  v_dados(v_dados.last()).vr_nrctremp := 4648247;
  v_dados(v_dados.last()).vr_vllanmto := 370.01;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91695490;
  v_dados(v_dados.last()).vr_nrctremp := 4879513;
  v_dados(v_dados.last()).vr_vllanmto := 5494.22;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91672872;
  v_dados(v_dados.last()).vr_nrctremp := 8072053;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91662583;
  v_dados(v_dados.last()).vr_nrctremp := 7469939;
  v_dados(v_dados.last()).vr_vllanmto := 18.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91645620;
  v_dados(v_dados.last()).vr_nrctremp := 8151585;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91642086;
  v_dados(v_dados.last()).vr_nrctremp := 8011078;
  v_dados(v_dados.last()).vr_vllanmto := 16.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91625327;
  v_dados(v_dados.last()).vr_nrctremp := 8005723;
  v_dados(v_dados.last()).vr_vllanmto := 13.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91548802;
  v_dados(v_dados.last()).vr_nrctremp := 7727910;
  v_dados(v_dados.last()).vr_vllanmto := 17.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91534054;
  v_dados(v_dados.last()).vr_nrctremp := 8140798;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91521351;
  v_dados(v_dados.last()).vr_nrctremp := 7837357;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91510007;
  v_dados(v_dados.last()).vr_nrctremp := 7857963;
  v_dados(v_dados.last()).vr_vllanmto := 12.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91464609;
  v_dados(v_dados.last()).vr_nrctremp := 7235321;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91457696;
  v_dados(v_dados.last()).vr_nrctremp := 7462549;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91455049;
  v_dados(v_dados.last()).vr_nrctremp := 8070754;
  v_dados(v_dados.last()).vr_vllanmto := 21.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91431093;
  v_dados(v_dados.last()).vr_nrctremp := 8077152;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91409772;
  v_dados(v_dados.last()).vr_nrctremp := 5611665;
  v_dados(v_dados.last()).vr_vllanmto := 12.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91362202;
  v_dados(v_dados.last()).vr_nrctremp := 4101609;
  v_dados(v_dados.last()).vr_vllanmto := 2173.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91362202;
  v_dados(v_dados.last()).vr_nrctremp := 6131009;
  v_dados(v_dados.last()).vr_vllanmto := 4481.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91361893;
  v_dados(v_dados.last()).vr_nrctremp := 7068406;
  v_dados(v_dados.last()).vr_vllanmto := 19.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91344352;
  v_dados(v_dados.last()).vr_nrctremp := 7832495;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91295734;
  v_dados(v_dados.last()).vr_nrctremp := 7631224;
  v_dados(v_dados.last()).vr_vllanmto := 25.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91253918;
  v_dados(v_dados.last()).vr_nrctremp := 7207889;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91240107;
  v_dados(v_dados.last()).vr_nrctremp := 7722138;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91234875;
  v_dados(v_dados.last()).vr_nrctremp := 7168193;
  v_dados(v_dados.last()).vr_vllanmto := 12.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91209846;
  v_dados(v_dados.last()).vr_nrctremp := 6038794;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91162122;
  v_dados(v_dados.last()).vr_nrctremp := 7377030;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91142350;
  v_dados(v_dados.last()).vr_nrctremp := 8059311;
  v_dados(v_dados.last()).vr_vllanmto := 21.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91141990;
  v_dados(v_dados.last()).vr_nrctremp := 7840966;
  v_dados(v_dados.last()).vr_vllanmto := 56.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91092620;
  v_dados(v_dados.last()).vr_nrctremp := 3627786;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91072344;
  v_dados(v_dados.last()).vr_nrctremp := 7980777;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91041732;
  v_dados(v_dados.last()).vr_nrctremp := 6205911;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90974921;
  v_dados(v_dados.last()).vr_nrctremp := 6170404;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90961170;
  v_dados(v_dados.last()).vr_nrctremp := 2985651;
  v_dados(v_dados.last()).vr_vllanmto := 1822.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90950755;
  v_dados(v_dados.last()).vr_nrctremp := 6712895;
  v_dados(v_dados.last()).vr_vllanmto := 22.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90944755;
  v_dados(v_dados.last()).vr_nrctremp := 7514846;
  v_dados(v_dados.last()).vr_vllanmto := 46.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90938763;
  v_dados(v_dados.last()).vr_nrctremp := 7574052;
  v_dados(v_dados.last()).vr_vllanmto := 13.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90926757;
  v_dados(v_dados.last()).vr_nrctremp := 8107984;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90915216;
  v_dados(v_dados.last()).vr_nrctremp := 5566176;
  v_dados(v_dados.last()).vr_vllanmto := 236.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90911199;
  v_dados(v_dados.last()).vr_nrctremp := 6016044;
  v_dados(v_dados.last()).vr_vllanmto := 1033.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90880110;
  v_dados(v_dados.last()).vr_nrctremp := 7785397;
  v_dados(v_dados.last()).vr_vllanmto := 22.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90878086;
  v_dados(v_dados.last()).vr_nrctremp := 8043950;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90865014;
  v_dados(v_dados.last()).vr_nrctremp := 7488239;
  v_dados(v_dados.last()).vr_vllanmto := 69.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90846885;
  v_dados(v_dados.last()).vr_nrctremp := 8118845;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90817605;
  v_dados(v_dados.last()).vr_nrctremp := 7564142;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90809300;
  v_dados(v_dados.last()).vr_nrctremp := 6779377;
  v_dados(v_dados.last()).vr_vllanmto := 11.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90808797;
  v_dados(v_dados.last()).vr_nrctremp := 5286369;
  v_dados(v_dados.last()).vr_vllanmto := 32.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90766628;
  v_dados(v_dados.last()).vr_nrctremp := 5621986;
  v_dados(v_dados.last()).vr_vllanmto := 19.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90763440;
  v_dados(v_dados.last()).vr_nrctremp := 6905588;
  v_dados(v_dados.last()).vr_vllanmto := 14.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90720903;
  v_dados(v_dados.last()).vr_nrctremp := 3481207;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90685156;
  v_dados(v_dados.last()).vr_nrctremp := 6190218;
  v_dados(v_dados.last()).vr_vllanmto := 19.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90685156;
  v_dados(v_dados.last()).vr_nrctremp := 6916842;
  v_dados(v_dados.last()).vr_vllanmto := 12.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90685156;
  v_dados(v_dados.last()).vr_nrctremp := 7993010;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90676149;
  v_dados(v_dados.last()).vr_nrctremp := 6001285;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90656504;
  v_dados(v_dados.last()).vr_nrctremp := 7633185;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90651138;
  v_dados(v_dados.last()).vr_nrctremp := 5959615;
  v_dados(v_dados.last()).vr_vllanmto := 224.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90647378;
  v_dados(v_dados.last()).vr_nrctremp := 5027319;
  v_dados(v_dados.last()).vr_vllanmto := 169.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90608739;
  v_dados(v_dados.last()).vr_nrctremp := 6916649;
  v_dados(v_dados.last()).vr_vllanmto := 14.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90595300;
  v_dados(v_dados.last()).vr_nrctremp := 7703048;
  v_dados(v_dados.last()).vr_vllanmto := 10.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90579380;
  v_dados(v_dados.last()).vr_nrctremp := 6926912;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90566769;
  v_dados(v_dados.last()).vr_nrctremp := 4559377;
  v_dados(v_dados.last()).vr_vllanmto := 232.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90560370;
  v_dados(v_dados.last()).vr_nrctremp := 7238783;
  v_dados(v_dados.last()).vr_vllanmto := 26.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90549368;
  v_dados(v_dados.last()).vr_nrctremp := 6930833;
  v_dados(v_dados.last()).vr_vllanmto := 1558.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90515390;
  v_dados(v_dados.last()).vr_nrctremp := 8073086;
  v_dados(v_dados.last()).vr_vllanmto := 16.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90498844;
  v_dados(v_dados.last()).vr_nrctremp := 4531209;
  v_dados(v_dados.last()).vr_vllanmto := 12.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90498844;
  v_dados(v_dados.last()).vr_nrctremp := 7620929;
  v_dados(v_dados.last()).vr_vllanmto := 28.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90496680;
  v_dados(v_dados.last()).vr_nrctremp := 6238730;
  v_dados(v_dados.last()).vr_vllanmto := 11.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90489799;
  v_dados(v_dados.last()).vr_nrctremp := 8008048;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90479998;
  v_dados(v_dados.last()).vr_nrctremp := 7369622;
  v_dados(v_dados.last()).vr_vllanmto := 228.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90479998;
  v_dados(v_dados.last()).vr_nrctremp := 7950495;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90476603;
  v_dados(v_dados.last()).vr_nrctremp := 7259026;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90473051;
  v_dados(v_dados.last()).vr_nrctremp := 7417213;
  v_dados(v_dados.last()).vr_vllanmto := 551.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90456440;
  v_dados(v_dados.last()).vr_nrctremp := 4391966;
  v_dados(v_dados.last()).vr_vllanmto := 120.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90442431;
  v_dados(v_dados.last()).vr_nrctremp := 7570898;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90435605;
  v_dados(v_dados.last()).vr_nrctremp := 6731340;
  v_dados(v_dados.last()).vr_vllanmto := 11.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90424492;
  v_dados(v_dados.last()).vr_nrctremp := 4535138;
  v_dados(v_dados.last()).vr_vllanmto := 1009.1;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90381505;
  v_dados(v_dados.last()).vr_nrctremp := 6738554;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90366620;
  v_dados(v_dados.last()).vr_nrctremp := 4343361;
  v_dados(v_dados.last()).vr_vllanmto := 3054.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90339797;
  v_dados(v_dados.last()).vr_nrctremp := 4680083;
  v_dados(v_dados.last()).vr_vllanmto := 7110.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90335864;
  v_dados(v_dados.last()).vr_nrctremp := 6731023;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90312295;
  v_dados(v_dados.last()).vr_nrctremp := 7009169;
  v_dados(v_dados.last()).vr_vllanmto := 20.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90299264;
  v_dados(v_dados.last()).vr_nrctremp := 7483770;
  v_dados(v_dados.last()).vr_vllanmto := 10.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90291840;
  v_dados(v_dados.last()).vr_nrctremp := 5199517;
  v_dados(v_dados.last()).vr_vllanmto := 202.6;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90287274;
  v_dados(v_dados.last()).vr_nrctremp := 4801045;
  v_dados(v_dados.last()).vr_vllanmto := 1275.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90287274;
  v_dados(v_dados.last()).vr_nrctremp := 6631120;
  v_dados(v_dados.last()).vr_vllanmto := 324.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90260651;
  v_dados(v_dados.last()).vr_nrctremp := 5378221;
  v_dados(v_dados.last()).vr_vllanmto := 1108.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90255224;
  v_dados(v_dados.last()).vr_nrctremp := 4046030;
  v_dados(v_dados.last()).vr_vllanmto := 8667.05;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90181859;
  v_dados(v_dados.last()).vr_nrctremp := 7922740;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90181689;
  v_dados(v_dados.last()).vr_nrctremp := 8167834;
  v_dados(v_dados.last()).vr_vllanmto := 12.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90179781;
  v_dados(v_dados.last()).vr_nrctremp := 7387037;
  v_dados(v_dados.last()).vr_vllanmto := 52.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90124308;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 2081.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90101294;
  v_dados(v_dados.last()).vr_nrctremp := 6478546;
  v_dados(v_dados.last()).vr_vllanmto := 29.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90094670;
  v_dados(v_dados.last()).vr_nrctremp := 7722113;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90076885;
  v_dados(v_dados.last()).vr_nrctremp := 7422521;
  v_dados(v_dados.last()).vr_vllanmto := 18.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90057104;
  v_dados(v_dados.last()).vr_nrctremp := 4445492;
  v_dados(v_dados.last()).vr_vllanmto := 3418.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90052951;
  v_dados(v_dados.last()).vr_nrctremp := 7306990;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90042239;
  v_dados(v_dados.last()).vr_nrctremp := 7814459;
  v_dados(v_dados.last()).vr_vllanmto := 23.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90041860;
  v_dados(v_dados.last()).vr_nrctremp := 5848326;
  v_dados(v_dados.last()).vr_vllanmto := 10486.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90004388;
  v_dados(v_dados.last()).vr_nrctremp := 7685027;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89975022;
  v_dados(v_dados.last()).vr_nrctremp := 7279592;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89965051;
  v_dados(v_dados.last()).vr_nrctremp := 5717931;
  v_dados(v_dados.last()).vr_vllanmto := 15.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89959493;
  v_dados(v_dados.last()).vr_nrctremp := 7499386;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89934873;
  v_dados(v_dados.last()).vr_nrctremp := 5120902;
  v_dados(v_dados.last()).vr_vllanmto := 128.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89933443;
  v_dados(v_dados.last()).vr_nrctremp := 6300813;
  v_dados(v_dados.last()).vr_vllanmto := 13.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89913400;
  v_dados(v_dados.last()).vr_nrctremp := 7626161;
  v_dados(v_dados.last()).vr_vllanmto := 15982.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89893557;
  v_dados(v_dados.last()).vr_nrctremp := 7068455;
  v_dados(v_dados.last()).vr_vllanmto := 18.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89884728;
  v_dados(v_dados.last()).vr_nrctremp := 6053088;
  v_dados(v_dados.last()).vr_vllanmto := 2023.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89820274;
  v_dados(v_dados.last()).vr_nrctremp := 7966889;
  v_dados(v_dados.last()).vr_vllanmto := 17.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89789598;
  v_dados(v_dados.last()).vr_nrctremp := 5803332;
  v_dados(v_dados.last()).vr_vllanmto := 11.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89762967;
  v_dados(v_dados.last()).vr_nrctremp := 6750565;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89754409;
  v_dados(v_dados.last()).vr_nrctremp := 4193713;
  v_dados(v_dados.last()).vr_vllanmto := 314.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89750772;
  v_dados(v_dados.last()).vr_nrctremp := 5311587;
  v_dados(v_dados.last()).vr_vllanmto := 11.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89748808;
  v_dados(v_dados.last()).vr_nrctremp := 5345929;
  v_dados(v_dados.last()).vr_vllanmto := 1801.46;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89742397;
  v_dados(v_dados.last()).vr_nrctremp := 8103018;
  v_dados(v_dados.last()).vr_vllanmto := 12.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89726383;
  v_dados(v_dados.last()).vr_nrctremp := 4889176;
  v_dados(v_dados.last()).vr_vllanmto := 55.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89706595;
  v_dados(v_dados.last()).vr_nrctremp := 4753411;
  v_dados(v_dados.last()).vr_vllanmto := 1007;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89705645;
  v_dados(v_dados.last()).vr_nrctremp := 6687664;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89705645;
  v_dados(v_dados.last()).vr_nrctremp := 7982185;
  v_dados(v_dados.last()).vr_vllanmto := 19.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89693191;
  v_dados(v_dados.last()).vr_nrctremp := 6066950;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89692802;
  v_dados(v_dados.last()).vr_nrctremp := 7376916;
  v_dados(v_dados.last()).vr_vllanmto := 23.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89685350;
  v_dados(v_dados.last()).vr_nrctremp := 7761086;
  v_dados(v_dados.last()).vr_vllanmto := 31.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89682246;
  v_dados(v_dados.last()).vr_nrctremp := 4677944;
  v_dados(v_dados.last()).vr_vllanmto := 8872.38;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89682246;
  v_dados(v_dados.last()).vr_nrctremp := 5587986;
  v_dados(v_dados.last()).vr_vllanmto := 2887.82;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89662008;
  v_dados(v_dados.last()).vr_nrctremp := 6988050;
  v_dados(v_dados.last()).vr_vllanmto := 21.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89639359;
  v_dados(v_dados.last()).vr_nrctremp := 4521812;
  v_dados(v_dados.last()).vr_vllanmto := 13.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89631129;
  v_dados(v_dados.last()).vr_nrctremp := 8140909;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89626761;
  v_dados(v_dados.last()).vr_nrctremp := 6464042;
  v_dados(v_dados.last()).vr_vllanmto := 249.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89599802;
  v_dados(v_dados.last()).vr_nrctremp := 8067075;
  v_dados(v_dados.last()).vr_vllanmto := 31.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89593960;
  v_dados(v_dados.last()).vr_nrctremp := 7613818;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89575563;
  v_dados(v_dados.last()).vr_nrctremp := 5801922;
  v_dados(v_dados.last()).vr_vllanmto := 127.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89567420;
  v_dados(v_dados.last()).vr_nrctremp := 4783814;
  v_dados(v_dados.last()).vr_vllanmto := 192.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89559690;
  v_dados(v_dados.last()).vr_nrctremp := 6037634;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89534409;
  v_dados(v_dados.last()).vr_nrctremp := 4476841;
  v_dados(v_dados.last()).vr_vllanmto := 737.91;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89531639;
  v_dados(v_dados.last()).vr_nrctremp := 7562825;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89512278;
  v_dados(v_dados.last()).vr_nrctremp := 3932268;
  v_dados(v_dados.last()).vr_vllanmto := 67.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89507541;
  v_dados(v_dados.last()).vr_nrctremp := 8051773;
  v_dados(v_dados.last()).vr_vllanmto := 16.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89490304;
  v_dados(v_dados.last()).vr_nrctremp := 6787302;
  v_dados(v_dados.last()).vr_vllanmto := 853.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89465857;
  v_dados(v_dados.last()).vr_nrctremp := 7451816;
  v_dados(v_dados.last()).vr_vllanmto := 20.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89455258;
  v_dados(v_dados.last()).vr_nrctremp := 6181433;
  v_dados(v_dados.last()).vr_vllanmto := 17.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89428170;
  v_dados(v_dados.last()).vr_nrctremp := 4167462;
  v_dados(v_dados.last()).vr_vllanmto := 22.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89422899;
  v_dados(v_dados.last()).vr_nrctremp := 6363678;
  v_dados(v_dados.last()).vr_vllanmto := 15292.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89362187;
  v_dados(v_dados.last()).vr_nrctremp := 4453483;
  v_dados(v_dados.last()).vr_vllanmto := 1809.64;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89359550;
  v_dados(v_dados.last()).vr_nrctremp := 6489392;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89352947;
  v_dados(v_dados.last()).vr_nrctremp := 8023329;
  v_dados(v_dados.last()).vr_vllanmto := 19.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89342267;
  v_dados(v_dados.last()).vr_nrctremp := 3167828;
  v_dados(v_dados.last()).vr_vllanmto := 78.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89338782;
  v_dados(v_dados.last()).vr_nrctremp := 7977707;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89336488;
  v_dados(v_dados.last()).vr_nrctremp := 5158755;
  v_dados(v_dados.last()).vr_vllanmto := 28.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89333462;
  v_dados(v_dados.last()).vr_nrctremp := 6804037;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89333209;
  v_dados(v_dados.last()).vr_nrctremp := 6317870;
  v_dados(v_dados.last()).vr_vllanmto := 13.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89329139;
  v_dados(v_dados.last()).vr_nrctremp := 4692518;
  v_dados(v_dados.last()).vr_vllanmto := 1376.99;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89324420;
  v_dados(v_dados.last()).vr_nrctremp := 6524795;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89304527;
  v_dados(v_dados.last()).vr_nrctremp := 8030440;
  v_dados(v_dados.last()).vr_vllanmto := 19.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89292146;
  v_dados(v_dados.last()).vr_nrctremp := 6443733;
  v_dados(v_dados.last()).vr_vllanmto := 23.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89272820;
  v_dados(v_dados.last()).vr_nrctremp := 7165449;
  v_dados(v_dados.last()).vr_vllanmto := 577.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89271114;
  v_dados(v_dados.last()).vr_nrctremp := 6695578;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89268059;
  v_dados(v_dados.last()).vr_nrctremp := 7795351;
  v_dados(v_dados.last()).vr_vllanmto := 38.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89264711;
  v_dados(v_dados.last()).vr_nrctremp := 3701725;
  v_dados(v_dados.last()).vr_vllanmto := 130.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89251067;
  v_dados(v_dados.last()).vr_nrctremp := 4640120;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89249917;
  v_dados(v_dados.last()).vr_nrctremp := 6135678;
  v_dados(v_dados.last()).vr_vllanmto := 68.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89214498;
  v_dados(v_dados.last()).vr_nrctremp := 7398774;
  v_dados(v_dados.last()).vr_vllanmto := 16.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89184378;
  v_dados(v_dados.last()).vr_nrctremp := 7808537;
  v_dados(v_dados.last()).vr_vllanmto := 11.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89183754;
  v_dados(v_dados.last()).vr_nrctremp := 5216299;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89154002;
  v_dados(v_dados.last()).vr_nrctremp := 5501714;
  v_dados(v_dados.last()).vr_vllanmto := 2525.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89148010;
  v_dados(v_dados.last()).vr_nrctremp := 5141026;
  v_dados(v_dados.last()).vr_vllanmto := 22.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89121724;
  v_dados(v_dados.last()).vr_nrctremp := 7225058;
  v_dados(v_dados.last()).vr_vllanmto := 1395.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89116542;
  v_dados(v_dados.last()).vr_nrctremp := 7464609;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89100514;
  v_dados(v_dados.last()).vr_nrctremp := 7216349;
  v_dados(v_dados.last()).vr_vllanmto := 15.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89100492;
  v_dados(v_dados.last()).vr_nrctremp := 8085738;
  v_dados(v_dados.last()).vr_vllanmto := 15.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89080262;
  v_dados(v_dados.last()).vr_nrctremp := 5972513;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89038878;
  v_dados(v_dados.last()).vr_nrctremp := 7688221;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89032357;
  v_dados(v_dados.last()).vr_nrctremp := 7987602;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89031547;
  v_dados(v_dados.last()).vr_nrctremp := 7312034;
  v_dados(v_dados.last()).vr_vllanmto := 10.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88982947;
  v_dados(v_dados.last()).vr_nrctremp := 7851299;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88955907;
  v_dados(v_dados.last()).vr_nrctremp := 4344288;
  v_dados(v_dados.last()).vr_vllanmto := 105.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88924688;
  v_dados(v_dados.last()).vr_nrctremp := 6735712;
  v_dados(v_dados.last()).vr_vllanmto := 207.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88899276;
  v_dados(v_dados.last()).vr_nrctremp := 6132418;
  v_dados(v_dados.last()).vr_vllanmto := 24.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88899276;
  v_dados(v_dados.last()).vr_nrctremp := 7762118;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88884651;
  v_dados(v_dados.last()).vr_nrctremp := 7041334;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88849147;
  v_dados(v_dados.last()).vr_nrctremp := 7991498;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88844722;
  v_dados(v_dados.last()).vr_nrctremp := 7841499;
  v_dados(v_dados.last()).vr_vllanmto := 14.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88810577;
  v_dados(v_dados.last()).vr_nrctremp := 7360616;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88810143;
  v_dados(v_dados.last()).vr_nrctremp := 7195356;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88807991;
  v_dados(v_dados.last()).vr_nrctremp := 8058873;
  v_dados(v_dados.last()).vr_vllanmto := 24.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88804399;
  v_dados(v_dados.last()).vr_nrctremp := 4604839;
  v_dados(v_dados.last()).vr_vllanmto := 410.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88793311;
  v_dados(v_dados.last()).vr_nrctremp := 7580570;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88791734;
  v_dados(v_dados.last()).vr_nrctremp := 7293592;
  v_dados(v_dados.last()).vr_vllanmto := 38.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88776603;
  v_dados(v_dados.last()).vr_nrctremp := 4901463;
  v_dados(v_dados.last()).vr_vllanmto := 20062.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88771857;
  v_dados(v_dados.last()).vr_nrctremp := 4581982;
  v_dados(v_dados.last()).vr_vllanmto := 64.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88748049;
  v_dados(v_dados.last()).vr_nrctremp := 7726372;
  v_dados(v_dados.last()).vr_vllanmto := 24.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88745244;
  v_dados(v_dados.last()).vr_nrctremp := 7182185;
  v_dados(v_dados.last()).vr_vllanmto := 366.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88745244;
  v_dados(v_dados.last()).vr_nrctremp := 7234406;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88744493;
  v_dados(v_dados.last()).vr_nrctremp := 7978224;
  v_dados(v_dados.last()).vr_vllanmto := 2828.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88739350;
  v_dados(v_dados.last()).vr_nrctremp := 8061227;
  v_dados(v_dados.last()).vr_vllanmto := 28.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88710092;
  v_dados(v_dados.last()).vr_nrctremp := 4556448;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88692426;
  v_dados(v_dados.last()).vr_nrctremp := 5897742;
  v_dados(v_dados.last()).vr_vllanmto := 2098.3;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88689450;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 5230.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88659089;
  v_dados(v_dados.last()).vr_nrctremp := 7971217;
  v_dados(v_dados.last()).vr_vllanmto := 27.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88632644;
  v_dados(v_dados.last()).vr_nrctremp := 8029204;
  v_dados(v_dados.last()).vr_vllanmto := 14.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88630692;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 1087.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88629538;
  v_dados(v_dados.last()).vr_nrctremp := 7919589;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88620921;
  v_dados(v_dados.last()).vr_nrctremp := 5061942;
  v_dados(v_dados.last()).vr_vllanmto := 27.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88582310;
  v_dados(v_dados.last()).vr_nrctremp := 7217875;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88566161;
  v_dados(v_dados.last()).vr_nrctremp := 5257224;
  v_dados(v_dados.last()).vr_vllanmto := 98.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88556816;
  v_dados(v_dados.last()).vr_nrctremp := 7649400;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88439798;
  v_dados(v_dados.last()).vr_nrctremp := 8057163;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88431118;
  v_dados(v_dados.last()).vr_nrctremp := 7672718;
  v_dados(v_dados.last()).vr_vllanmto := 38380.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88423409;
  v_dados(v_dados.last()).vr_nrctremp := 4674681;
  v_dados(v_dados.last()).vr_vllanmto := 2440.24;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88406881;
  v_dados(v_dados.last()).vr_nrctremp := 8138705;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88399818;
  v_dados(v_dados.last()).vr_nrctremp := 7935143;
  v_dados(v_dados.last()).vr_vllanmto := 21.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88399753;
  v_dados(v_dados.last()).vr_nrctremp := 6956820;
  v_dados(v_dados.last()).vr_vllanmto := 12.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88384160;
  v_dados(v_dados.last()).vr_nrctremp := 4589257;
  v_dados(v_dados.last()).vr_vllanmto := 2944.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88370526;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 2611.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88342042;
  v_dados(v_dados.last()).vr_nrctremp := 6268477;
  v_dados(v_dados.last()).vr_vllanmto := 27644.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88296482;
  v_dados(v_dados.last()).vr_nrctremp := 6186099;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88292959;
  v_dados(v_dados.last()).vr_nrctremp := 6556949;
  v_dados(v_dados.last()).vr_vllanmto := 23.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88287297;
  v_dados(v_dados.last()).vr_nrctremp := 3098270;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88281990;
  v_dados(v_dados.last()).vr_nrctremp := 3005429;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88252116;
  v_dados(v_dados.last()).vr_nrctremp := 3604371;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88240304;
  v_dados(v_dados.last()).vr_nrctremp := 3170921;
  v_dados(v_dados.last()).vr_vllanmto := 12.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88238580;
  v_dados(v_dados.last()).vr_nrctremp := 4490149;
  v_dados(v_dados.last()).vr_vllanmto := 17.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88236196;
  v_dados(v_dados.last()).vr_nrctremp := 4513090;
  v_dados(v_dados.last()).vr_vllanmto := 24.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88233413;
  v_dados(v_dados.last()).vr_nrctremp := 5500927;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88231321;
  v_dados(v_dados.last()).vr_nrctremp := 3305760;
  v_dados(v_dados.last()).vr_vllanmto := 14.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88226573;
  v_dados(v_dados.last()).vr_nrctremp := 3170781;
  v_dados(v_dados.last()).vr_vllanmto := 19.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88226220;
  v_dados(v_dados.last()).vr_nrctremp := 7631219;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88226174;
  v_dados(v_dados.last()).vr_nrctremp := 4350017;
  v_dados(v_dados.last()).vr_vllanmto := 18.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88221792;
  v_dados(v_dados.last()).vr_nrctremp := 7765537;
  v_dados(v_dados.last()).vr_vllanmto := 21.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88221342;
  v_dados(v_dados.last()).vr_nrctremp := 5233294;
  v_dados(v_dados.last()).vr_vllanmto := 125.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88214109;
  v_dados(v_dados.last()).vr_nrctremp := 4974493;
  v_dados(v_dados.last()).vr_vllanmto := 202;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88201171;
  v_dados(v_dados.last()).vr_nrctremp := 6323677;
  v_dados(v_dados.last()).vr_vllanmto := 10.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88154645;
  v_dados(v_dados.last()).vr_nrctremp := 7972504;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88133206;
  v_dados(v_dados.last()).vr_nrctremp := 7878561;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88126293;
  v_dados(v_dados.last()).vr_nrctremp := 6990572;
  v_dados(v_dados.last()).vr_vllanmto := 12.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88112195;
  v_dados(v_dados.last()).vr_nrctremp := 3941325;
  v_dados(v_dados.last()).vr_vllanmto := 14.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88110745;
  v_dados(v_dados.last()).vr_nrctremp := 3521680;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88088944;
  v_dados(v_dados.last()).vr_nrctremp := 8061030;
  v_dados(v_dados.last()).vr_vllanmto := 18.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88071626;
  v_dados(v_dados.last()).vr_nrctremp := 6913717;
  v_dados(v_dados.last()).vr_vllanmto := 16.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88046907;
  v_dados(v_dados.last()).vr_nrctremp := 7502019;
  v_dados(v_dados.last()).vr_vllanmto := 58.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88043754;
  v_dados(v_dados.last()).vr_nrctremp := 7047172;
  v_dados(v_dados.last()).vr_vllanmto := 1596.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88019500;
  v_dados(v_dados.last()).vr_nrctremp := 3404776;
  v_dados(v_dados.last()).vr_vllanmto := 10.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87995867;
  v_dados(v_dados.last()).vr_nrctremp := 7647300;
  v_dados(v_dados.last()).vr_vllanmto := 13.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87980762;
  v_dados(v_dados.last()).vr_nrctremp := 3430704;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87979748;
  v_dados(v_dados.last()).vr_nrctremp := 4452101;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87978440;
  v_dados(v_dados.last()).vr_nrctremp := 3421230;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87978440;
  v_dados(v_dados.last()).vr_nrctremp := 3421257;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87961857;
  v_dados(v_dados.last()).vr_nrctremp := 7240176;
  v_dados(v_dados.last()).vr_vllanmto := 17863.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87928825;
  v_dados(v_dados.last()).vr_nrctremp := 6538142;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87925702;
  v_dados(v_dados.last()).vr_nrctremp := 3255681;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87917807;
  v_dados(v_dados.last()).vr_nrctremp := 7624609;
  v_dados(v_dados.last()).vr_vllanmto := 26.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87903199;
  v_dados(v_dados.last()).vr_nrctremp := 7281104;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87896214;
  v_dados(v_dados.last()).vr_nrctremp := 6277579;
  v_dados(v_dados.last()).vr_vllanmto := 7235.43;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87890658;
  v_dados(v_dados.last()).vr_nrctremp := 3297031;
  v_dados(v_dados.last()).vr_vllanmto := 14.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87886197;
  v_dados(v_dados.last()).vr_nrctremp := 4221205;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87886197;
  v_dados(v_dados.last()).vr_nrctremp := 6164373;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87876205;
  v_dados(v_dados.last()).vr_nrctremp := 3315152;
  v_dados(v_dados.last()).vr_vllanmto := 23.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87851288;
  v_dados(v_dados.last()).vr_nrctremp := 7631064;
  v_dados(v_dados.last()).vr_vllanmto := 18.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87817691;
  v_dados(v_dados.last()).vr_nrctremp := 3389755;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87816040;
  v_dados(v_dados.last()).vr_nrctremp := 3393615;
  v_dados(v_dados.last()).vr_vllanmto := 12.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87787733;
  v_dados(v_dados.last()).vr_nrctremp := 3420248;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87761858;
  v_dados(v_dados.last()).vr_nrctremp := 7106507;
  v_dados(v_dados.last()).vr_vllanmto := 21.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87758881;
  v_dados(v_dados.last()).vr_nrctremp := 6769405;
  v_dados(v_dados.last()).vr_vllanmto := 10.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87754614;
  v_dados(v_dados.last()).vr_nrctremp := 7534433;
  v_dados(v_dados.last()).vr_vllanmto := 10.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87741504;
  v_dados(v_dados.last()).vr_nrctremp := 3455167;
  v_dados(v_dados.last()).vr_vllanmto := 13.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87735946;
  v_dados(v_dados.last()).vr_nrctremp := 6320282;
  v_dados(v_dados.last()).vr_vllanmto := 6404.91;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87725800;
  v_dados(v_dados.last()).vr_nrctremp := 3706648;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87721287;
  v_dados(v_dados.last()).vr_nrctremp := 4912772;
  v_dados(v_dados.last()).vr_vllanmto := 12.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87709198;
  v_dados(v_dados.last()).vr_nrctremp := 8092130;
  v_dados(v_dados.last()).vr_vllanmto := 16.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87707845;
  v_dados(v_dados.last()).vr_nrctremp := 5828078;
  v_dados(v_dados.last()).vr_vllanmto := 3694.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87706539;
  v_dados(v_dados.last()).vr_nrctremp := 3938066;
  v_dados(v_dados.last()).vr_vllanmto := 17.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87703360;
  v_dados(v_dados.last()).vr_nrctremp := 6824521;
  v_dados(v_dados.last()).vr_vllanmto := 15.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87701480;
  v_dados(v_dados.last()).vr_nrctremp := 7282249;
  v_dados(v_dados.last()).vr_vllanmto := 295.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87683318;
  v_dados(v_dados.last()).vr_nrctremp := 3510982;
  v_dados(v_dados.last()).vr_vllanmto := 172.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87683318;
  v_dados(v_dados.last()).vr_nrctremp := 3845592;
  v_dados(v_dados.last()).vr_vllanmto := 1260.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87682427;
  v_dados(v_dados.last()).vr_nrctremp := 5783533;
  v_dados(v_dados.last()).vr_vllanmto := 57.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87675099;
  v_dados(v_dados.last()).vr_nrctremp := 6400551;
  v_dados(v_dados.last()).vr_vllanmto := 530.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87675099;
  v_dados(v_dados.last()).vr_nrctremp := 7073135;
  v_dados(v_dados.last()).vr_vllanmto := 3848.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87674360;
  v_dados(v_dados.last()).vr_nrctremp := 3599984;
  v_dados(v_dados.last()).vr_vllanmto := 10.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87659069;
  v_dados(v_dados.last()).vr_nrctremp := 7940162;
  v_dados(v_dados.last()).vr_vllanmto := 22.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87639955;
  v_dados(v_dados.last()).vr_nrctremp := 5290818;
  v_dados(v_dados.last()).vr_vllanmto := 694.12;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87637162;
  v_dados(v_dados.last()).vr_nrctremp := 3742862;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87635240;
  v_dados(v_dados.last()).vr_nrctremp := 3572209;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87602687;
  v_dados(v_dados.last()).vr_nrctremp := 3600273;
  v_dados(v_dados.last()).vr_vllanmto := 3970.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87602687;
  v_dados(v_dados.last()).vr_nrctremp := 6375383;
  v_dados(v_dados.last()).vr_vllanmto := 890.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87594870;
  v_dados(v_dados.last()).vr_nrctremp := 3602629;
  v_dados(v_dados.last()).vr_vllanmto := 12.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87582198;
  v_dados(v_dados.last()).vr_nrctremp := 3614655;
  v_dados(v_dados.last()).vr_vllanmto := 2913.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87579995;
  v_dados(v_dados.last()).vr_nrctremp := 3618344;
  v_dados(v_dados.last()).vr_vllanmto := 15.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87560348;
  v_dados(v_dados.last()).vr_nrctremp := 4760725;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87544750;
  v_dados(v_dados.last()).vr_nrctremp := 3655624;
  v_dados(v_dados.last()).vr_vllanmto := 11.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87537052;
  v_dados(v_dados.last()).vr_nrctremp := 4022402;
  v_dados(v_dados.last()).vr_vllanmto := 948.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87534614;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 7040.78;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87527162;
  v_dados(v_dados.last()).vr_nrctremp := 6732213;
  v_dados(v_dados.last()).vr_vllanmto := 17.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87524120;
  v_dados(v_dados.last()).vr_nrctremp := 5702554;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87498693;
  v_dados(v_dados.last()).vr_nrctremp := 7505459;
  v_dados(v_dados.last()).vr_vllanmto := 12.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87484234;
  v_dados(v_dados.last()).vr_nrctremp := 7531580;
  v_dados(v_dados.last()).vr_vllanmto := 13.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87480514;
  v_dados(v_dados.last()).vr_nrctremp := 3726006;
  v_dados(v_dados.last()).vr_vllanmto := 142.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87480514;
  v_dados(v_dados.last()).vr_nrctremp := 4059743;
  v_dados(v_dados.last()).vr_vllanmto := 20.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87479575;
  v_dados(v_dados.last()).vr_nrctremp := 3726902;
  v_dados(v_dados.last()).vr_vllanmto := 22.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87459388;
  v_dados(v_dados.last()).vr_nrctremp := 3741052;
  v_dados(v_dados.last()).vr_vllanmto := 397.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87456931;
  v_dados(v_dados.last()).vr_nrctremp := 3869309;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87451280;
  v_dados(v_dados.last()).vr_nrctremp := 3753649;
  v_dados(v_dados.last()).vr_vllanmto := 15.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87442051;
  v_dados(v_dados.last()).vr_nrctremp := 3762595;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87438178;
  v_dados(v_dados.last()).vr_nrctremp := 4109959;
  v_dados(v_dados.last()).vr_vllanmto := 6894.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87431483;
  v_dados(v_dados.last()).vr_nrctremp := 3774764;
  v_dados(v_dados.last()).vr_vllanmto := 14.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87427222;
  v_dados(v_dados.last()).vr_nrctremp := 3795640;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87415399;
  v_dados(v_dados.last()).vr_nrctremp := 6245755;
  v_dados(v_dados.last()).vr_vllanmto := 11.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87409453;
  v_dados(v_dados.last()).vr_nrctremp := 7387886;
  v_dados(v_dados.last()).vr_vllanmto := 25.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87404567;
  v_dados(v_dados.last()).vr_nrctremp := 8121940;
  v_dados(v_dados.last()).vr_vllanmto := 16.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87397960;
  v_dados(v_dados.last()).vr_nrctremp := 4029953;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87396726;
  v_dados(v_dados.last()).vr_nrctremp := 7317080;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87382938;
  v_dados(v_dados.last()).vr_nrctremp := 3827456;
  v_dados(v_dados.last()).vr_vllanmto := 148.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87379546;
  v_dados(v_dados.last()).vr_nrctremp := 3830750;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87372380;
  v_dados(v_dados.last()).vr_nrctremp := 7880925;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87326779;
  v_dados(v_dados.last()).vr_nrctremp := 4052613;
  v_dados(v_dados.last()).vr_vllanmto := 18.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87305399;
  v_dados(v_dados.last()).vr_nrctremp := 4133615;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87300745;
  v_dados(v_dados.last()).vr_nrctremp := 5916683;
  v_dados(v_dados.last()).vr_vllanmto := 196.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87300745;
  v_dados(v_dados.last()).vr_nrctremp := 5916746;
  v_dados(v_dados.last()).vr_vllanmto := 68.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87298414;
  v_dados(v_dados.last()).vr_nrctremp := 3997739;
  v_dados(v_dados.last()).vr_vllanmto := 13.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87294664;
  v_dados(v_dados.last()).vr_nrctremp := 7552138;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87293463;
  v_dados(v_dados.last()).vr_nrctremp := 4016118;
  v_dados(v_dados.last()).vr_vllanmto := 14.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87293412;
  v_dados(v_dados.last()).vr_nrctremp := 4160235;
  v_dados(v_dados.last()).vr_vllanmto := 18.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87289849;
  v_dados(v_dados.last()).vr_nrctremp := 3935842;
  v_dados(v_dados.last()).vr_vllanmto := 17.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87289377;
  v_dados(v_dados.last()).vr_nrctremp := 4075169;
  v_dados(v_dados.last()).vr_vllanmto := 12.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87274450;
  v_dados(v_dados.last()).vr_nrctremp := 4202145;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87273454;
  v_dados(v_dados.last()).vr_nrctremp := 5493045;
  v_dados(v_dados.last()).vr_vllanmto := 14.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87262290;
  v_dados(v_dados.last()).vr_nrctremp := 4038250;
  v_dados(v_dados.last()).vr_vllanmto := 22.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87260840;
  v_dados(v_dados.last()).vr_nrctremp := 4102671;
  v_dados(v_dados.last()).vr_vllanmto := 27.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87260840;
  v_dados(v_dados.last()).vr_nrctremp := 5545715;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87244357;
  v_dados(v_dados.last()).vr_nrctremp := 8076864;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87243474;
  v_dados(v_dados.last()).vr_nrctremp := 4210230;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87236133;
  v_dados(v_dados.last()).vr_nrctremp := 5898980;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92988342;
  v_dados(v_dados.last()).vr_nrctremp := 7458013;
  v_dados(v_dados.last()).vr_vllanmto := 35.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 92044670;
  v_dados(v_dados.last()).vr_nrctremp := 6712054;
  v_dados(v_dados.last()).vr_vllanmto := 13.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 91095565;
  v_dados(v_dados.last()).vr_nrctremp := 7392255;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90805909;
  v_dados(v_dados.last()).vr_nrctremp := 7281254;
  v_dados(v_dados.last()).vr_vllanmto := 30.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90805569;
  v_dados(v_dados.last()).vr_nrctremp := 3700170;
  v_dados(v_dados.last()).vr_vllanmto := 120.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90555228;
  v_dados(v_dados.last()).vr_nrctremp := 7264443;
  v_dados(v_dados.last()).vr_vllanmto := 116.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90555228;
  v_dados(v_dados.last()).vr_nrctremp := 7461434;
  v_dados(v_dados.last()).vr_vllanmto := 60.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90555228;
  v_dados(v_dados.last()).vr_nrctremp := 8051077;
  v_dados(v_dados.last()).vr_vllanmto := 18.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 89746759;
  v_dados(v_dados.last()).vr_nrctremp := 8008988;
  v_dados(v_dados.last()).vr_vllanmto := 16.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 88896986;
  v_dados(v_dados.last()).vr_nrctremp := 6608081;
  v_dados(v_dados.last()).vr_vllanmto := 13.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87990512;
  v_dados(v_dados.last()).vr_nrctremp := 7471425;
  v_dados(v_dados.last()).vr_vllanmto := 16.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87944898;
  v_dados(v_dados.last()).vr_nrctremp := 3238779;
  v_dados(v_dados.last()).vr_vllanmto := 15.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87853060;
  v_dados(v_dados.last()).vr_nrctremp := 3383461;
  v_dados(v_dados.last()).vr_vllanmto := 10801.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87853060;
  v_dados(v_dados.last()).vr_nrctremp := 4251082;
  v_dados(v_dados.last()).vr_vllanmto := 2418.64;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87716186;
  v_dados(v_dados.last()).vr_nrctremp := 7648443;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87446022;
  v_dados(v_dados.last()).vr_nrctremp := 3758627;
  v_dados(v_dados.last()).vr_vllanmto := 11.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87417375;
  v_dados(v_dados.last()).vr_nrctremp := 3986201;
  v_dados(v_dados.last()).vr_vllanmto := 13.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87317150;
  v_dados(v_dados.last()).vr_nrctremp := 6402310;
  v_dados(v_dados.last()).vr_vllanmto := 23.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87214571;
  v_dados(v_dados.last()).vr_nrctremp := 4083531;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87215306;
  v_dados(v_dados.last()).vr_nrctremp := 5782397;
  v_dados(v_dados.last()).vr_vllanmto := 14.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87213265;
  v_dados(v_dados.last()).vr_nrctremp := 4243736;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87209861;
  v_dados(v_dados.last()).vr_nrctremp := 4349720;
  v_dados(v_dados.last()).vr_vllanmto := 18.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87198282;
  v_dados(v_dados.last()).vr_nrctremp := 5077570;
  v_dados(v_dados.last()).vr_vllanmto := 82.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87189402;
  v_dados(v_dados.last()).vr_nrctremp := 4245483;
  v_dados(v_dados.last()).vr_vllanmto := 1416.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87182262;
  v_dados(v_dados.last()).vr_nrctremp := 4256682;
  v_dados(v_dados.last()).vr_vllanmto := 15.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87174723;
  v_dados(v_dados.last()).vr_nrctremp := 4576380;
  v_dados(v_dados.last()).vr_vllanmto := 14.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87166143;
  v_dados(v_dados.last()).vr_nrctremp := 4181782;
  v_dados(v_dados.last()).vr_vllanmto := 11.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87126303;
  v_dados(v_dados.last()).vr_nrctremp := 4085979;
  v_dados(v_dados.last()).vr_vllanmto := 5046.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87106647;
  v_dados(v_dados.last()).vr_nrctremp := 7142175;
  v_dados(v_dados.last()).vr_vllanmto := 11.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87101289;
  v_dados(v_dados.last()).vr_nrctremp := 4188743;
  v_dados(v_dados.last()).vr_vllanmto := 14.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87056011;
  v_dados(v_dados.last()).vr_nrctremp := 5246245;
  v_dados(v_dados.last()).vr_vllanmto := 5676.71;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87057115;
  v_dados(v_dados.last()).vr_nrctremp := 7251150;
  v_dados(v_dados.last()).vr_vllanmto := 342.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87042479;
  v_dados(v_dados.last()).vr_nrctremp := 4349766;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87041553;
  v_dados(v_dados.last()).vr_nrctremp := 7057088;
  v_dados(v_dados.last()).vr_vllanmto := 32.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87035995;
  v_dados(v_dados.last()).vr_nrctremp := 4232365;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87031981;
  v_dados(v_dados.last()).vr_nrctremp := 6942688;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87023580;
  v_dados(v_dados.last()).vr_nrctremp := 5845377;
  v_dados(v_dados.last()).vr_vllanmto := 1263.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87018063;
  v_dados(v_dados.last()).vr_nrctremp := 5200658;
  v_dados(v_dados.last()).vr_vllanmto := 250.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87018705;
  v_dados(v_dados.last()).vr_nrctremp := 6400299;
  v_dados(v_dados.last()).vr_vllanmto := 511.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87017130;
  v_dados(v_dados.last()).vr_nrctremp := 7920561;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 87001462;
  v_dados(v_dados.last()).vr_nrctremp := 7533612;
  v_dados(v_dados.last()).vr_vllanmto := 48.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86990551;
  v_dados(v_dados.last()).vr_nrctremp := 4348153;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86990551;
  v_dados(v_dados.last()).vr_nrctremp := 7885529;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86981137;
  v_dados(v_dados.last()).vr_nrctremp := 8058389;
  v_dados(v_dados.last()).vr_vllanmto := 15.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86971093;
  v_dados(v_dados.last()).vr_nrctremp := 4256265;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86971697;
  v_dados(v_dados.last()).vr_nrctremp := 6919014;
  v_dados(v_dados.last()).vr_vllanmto := 16.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86977628;
  v_dados(v_dados.last()).vr_nrctremp := 6759409;
  v_dados(v_dados.last()).vr_vllanmto := 20420.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86954130;
  v_dados(v_dados.last()).vr_nrctremp := 7452804;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86946790;
  v_dados(v_dados.last()).vr_nrctremp := 5779480;
  v_dados(v_dados.last()).vr_vllanmto := 629.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86946790;
  v_dados(v_dados.last()).vr_nrctremp := 5863094;
  v_dados(v_dados.last()).vr_vllanmto := 526.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86912410;
  v_dados(v_dados.last()).vr_nrctremp := 4375284;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86907107;
  v_dados(v_dados.last()).vr_nrctremp := 7923959;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86903233;
  v_dados(v_dados.last()).vr_nrctremp := 4346981;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86889427;
  v_dados(v_dados.last()).vr_nrctremp := 4375141;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86875817;
  v_dados(v_dados.last()).vr_nrctremp := 4502808;
  v_dados(v_dados.last()).vr_vllanmto := 14.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86848852;
  v_dados(v_dados.last()).vr_nrctremp := 4375227;
  v_dados(v_dados.last()).vr_vllanmto := 19.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86815660;
  v_dados(v_dados.last()).vr_nrctremp := 4313478;
  v_dados(v_dados.last()).vr_vllanmto := 11136.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86801970;
  v_dados(v_dados.last()).vr_nrctremp := 4536802;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86782410;
  v_dados(v_dados.last()).vr_nrctremp := 4692786;
  v_dados(v_dados.last()).vr_vllanmto := 23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86776819;
  v_dados(v_dados.last()).vr_nrctremp := 4499370;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86774794;
  v_dados(v_dados.last()).vr_nrctremp := 4950218;
  v_dados(v_dados.last()).vr_vllanmto := 17.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86750852;
  v_dados(v_dados.last()).vr_nrctremp := 7940412;
  v_dados(v_dados.last()).vr_vllanmto := 15.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86746804;
  v_dados(v_dados.last()).vr_nrctremp := 4434759;
  v_dados(v_dados.last()).vr_vllanmto := 14.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86737287;
  v_dados(v_dados.last()).vr_nrctremp := 7210381;
  v_dados(v_dados.last()).vr_vllanmto := 15313.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86733362;
  v_dados(v_dados.last()).vr_nrctremp := 4829270;
  v_dados(v_dados.last()).vr_vllanmto := 14.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86701720;
  v_dados(v_dados.last()).vr_nrctremp := 4662710;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86694650;
  v_dados(v_dados.last()).vr_nrctremp := 4407480;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86693808;
  v_dados(v_dados.last()).vr_nrctremp := 4901939;
  v_dados(v_dados.last()).vr_vllanmto := 13.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86690612;
  v_dados(v_dados.last()).vr_nrctremp := 7792894;
  v_dados(v_dados.last()).vr_vllanmto := 19.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86683527;
  v_dados(v_dados.last()).vr_nrctremp := 4575351;
  v_dados(v_dados.last()).vr_vllanmto := 12.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86664476;
  v_dados(v_dados.last()).vr_nrctremp := 4617398;
  v_dados(v_dados.last()).vr_vllanmto := 13.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86657437;
  v_dados(v_dados.last()).vr_nrctremp := 4463416;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86655892;
  v_dados(v_dados.last()).vr_nrctremp := 4462768;
  v_dados(v_dados.last()).vr_vllanmto := 16.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86647059;
  v_dados(v_dados.last()).vr_nrctremp := 4602620;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86610538;
  v_dados(v_dados.last()).vr_nrctremp := 4639193;
  v_dados(v_dados.last()).vr_vllanmto := 18.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86586165;
  v_dados(v_dados.last()).vr_nrctremp := 4665968;
  v_dados(v_dados.last()).vr_vllanmto := 20.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86574868;
  v_dados(v_dados.last()).vr_nrctremp := 7954097;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86559699;
  v_dados(v_dados.last()).vr_nrctremp := 4672702;
  v_dados(v_dados.last()).vr_vllanmto := 13.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86544500;
  v_dados(v_dados.last()).vr_nrctremp := 4674078;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86518313;
  v_dados(v_dados.last()).vr_nrctremp := 4650705;
  v_dados(v_dados.last()).vr_vllanmto := 13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86463640;
  v_dados(v_dados.last()).vr_nrctremp := 4708727;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86429124;
  v_dados(v_dados.last()).vr_nrctremp := 7367000;
  v_dados(v_dados.last()).vr_vllanmto := 143.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86427792;
  v_dados(v_dados.last()).vr_nrctremp := 8029878;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86418785;
  v_dados(v_dados.last()).vr_nrctremp := 4921029;
  v_dados(v_dados.last()).vr_vllanmto := 16.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86417002;
  v_dados(v_dados.last()).vr_nrctremp := 4605327;
  v_dados(v_dados.last()).vr_vllanmto := 11.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86417339;
  v_dados(v_dados.last()).vr_nrctremp := 6485397;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86417002;
  v_dados(v_dados.last()).vr_nrctremp := 4605658;
  v_dados(v_dados.last()).vr_vllanmto := 13.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86415719;
  v_dados(v_dados.last()).vr_nrctremp := 4658343;
  v_dados(v_dados.last()).vr_vllanmto := 13.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86415719;
  v_dados(v_dados.last()).vr_nrctremp := 7486662;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86360850;
  v_dados(v_dados.last()).vr_nrctremp := 7721530;
  v_dados(v_dados.last()).vr_vllanmto := 14.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86351958;
  v_dados(v_dados.last()).vr_nrctremp := 5547013;
  v_dados(v_dados.last()).vr_vllanmto := 54.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86351958;
  v_dados(v_dados.last()).vr_nrctremp := 6791618;
  v_dados(v_dados.last()).vr_vllanmto := 56.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86340905;
  v_dados(v_dados.last()).vr_nrctremp := 6994301;
  v_dados(v_dados.last()).vr_vllanmto := 16.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86310550;
  v_dados(v_dados.last()).vr_nrctremp := 6931608;
  v_dados(v_dados.last()).vr_vllanmto := 17.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86310321;
  v_dados(v_dados.last()).vr_nrctremp := 7377291;
  v_dados(v_dados.last()).vr_vllanmto := 85.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86310321;
  v_dados(v_dados.last()).vr_nrctremp := 7703197;
  v_dados(v_dados.last()).vr_vllanmto := 728.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86297643;
  v_dados(v_dados.last()).vr_nrctremp := 5833525;
  v_dados(v_dados.last()).vr_vllanmto := 8950.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86290916;
  v_dados(v_dados.last()).vr_nrctremp := 5222855;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86281429;
  v_dados(v_dados.last()).vr_nrctremp := 7392446;
  v_dados(v_dados.last()).vr_vllanmto := 25.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86274350;
  v_dados(v_dados.last()).vr_nrctremp := 4885820;
  v_dados(v_dados.last()).vr_vllanmto := 13.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86260626;
  v_dados(v_dados.last()).vr_nrctremp := 6682498;
  v_dados(v_dados.last()).vr_vllanmto := 592.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86260510;
  v_dados(v_dados.last()).vr_nrctremp := 5531174;
  v_dados(v_dados.last()).vr_vllanmto := 6340.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86231421;
  v_dados(v_dados.last()).vr_nrctremp := 7238642;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86228277;
  v_dados(v_dados.last()).vr_nrctremp := 7885860;
  v_dados(v_dados.last()).vr_vllanmto := 153.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86205919;
  v_dados(v_dados.last()).vr_nrctremp := 7795288;
  v_dados(v_dados.last()).vr_vllanmto := 31.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86196839;
  v_dados(v_dados.last()).vr_nrctremp := 6647967;
  v_dados(v_dados.last()).vr_vllanmto := 2927.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86186469;
  v_dados(v_dados.last()).vr_nrctremp := 7526659;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86144391;
  v_dados(v_dados.last()).vr_nrctremp := 4814043;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86141171;
  v_dados(v_dados.last()).vr_nrctremp := 6422136;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86108972;
  v_dados(v_dados.last()).vr_nrctremp := 6274076;
  v_dados(v_dados.last()).vr_vllanmto := 100.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86095072;
  v_dados(v_dados.last()).vr_nrctremp := 6697017;
  v_dados(v_dados.last()).vr_vllanmto := 12.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86077880;
  v_dados(v_dados.last()).vr_nrctremp := 7396221;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86059947;
  v_dados(v_dados.last()).vr_nrctremp := 7040222;
  v_dados(v_dados.last()).vr_vllanmto := 1219.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86038443;
  v_dados(v_dados.last()).vr_nrctremp := 7361397;
  v_dados(v_dados.last()).vr_vllanmto := 14.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 86020285;
  v_dados(v_dados.last()).vr_nrctremp := 7790313;
  v_dados(v_dados.last()).vr_vllanmto := 16.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85982857;
  v_dados(v_dados.last()).vr_nrctremp := 8084845;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85956430;
  v_dados(v_dados.last()).vr_nrctremp := 8109903;
  v_dados(v_dados.last()).vr_vllanmto := 11.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85929921;
  v_dados(v_dados.last()).vr_nrctremp := 8170736;
  v_dados(v_dados.last()).vr_vllanmto := 39.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85866270;
  v_dados(v_dados.last()).vr_nrctremp := 7581591;
  v_dados(v_dados.last()).vr_vllanmto := 21.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85857580;
  v_dados(v_dados.last()).vr_nrctremp := 5611560;
  v_dados(v_dados.last()).vr_vllanmto := 19.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85853682;
  v_dados(v_dados.last()).vr_nrctremp := 7373926;
  v_dados(v_dados.last()).vr_vllanmto := 13.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85819166;
  v_dados(v_dados.last()).vr_nrctremp := 7089998;
  v_dados(v_dados.last()).vr_vllanmto := 287.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85778320;
  v_dados(v_dados.last()).vr_nrctremp := 6911986;
  v_dados(v_dados.last()).vr_vllanmto := 96.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85761079;
  v_dados(v_dados.last()).vr_nrctremp := 6019047;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85717568;
  v_dados(v_dados.last()).vr_nrctremp := 7547854;
  v_dados(v_dados.last()).vr_vllanmto := 10.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85604330;
  v_dados(v_dados.last()).vr_nrctremp := 7153809;
  v_dados(v_dados.last()).vr_vllanmto := 10.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85602388;
  v_dados(v_dados.last()).vr_nrctremp := 7376637;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85577545;
  v_dados(v_dados.last()).vr_nrctremp := 7333609;
  v_dados(v_dados.last()).vr_vllanmto := 13.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85527912;
  v_dados(v_dados.last()).vr_nrctremp := 6756532;
  v_dados(v_dados.last()).vr_vllanmto := 12.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85518328;
  v_dados(v_dados.last()).vr_nrctremp := 5341434;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85495492;
  v_dados(v_dados.last()).vr_nrctremp := 7254507;
  v_dados(v_dados.last()).vr_vllanmto := 31.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85457566;
  v_dados(v_dados.last()).vr_nrctremp := 8012058;
  v_dados(v_dados.last()).vr_vllanmto := 11.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85457760;
  v_dados(v_dados.last()).vr_nrctremp := 6443680;
  v_dados(v_dados.last()).vr_vllanmto := 141.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85424951;
  v_dados(v_dados.last()).vr_nrctremp := 8016886;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85418196;
  v_dados(v_dados.last()).vr_nrctremp := 6585401;
  v_dados(v_dados.last()).vr_vllanmto := 18.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85409561;
  v_dados(v_dados.last()).vr_nrctremp := 8163055;
  v_dados(v_dados.last()).vr_vllanmto := 14.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85401595;
  v_dados(v_dados.last()).vr_nrctremp := 6520485;
  v_dados(v_dados.last()).vr_vllanmto := 1413.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85314234;
  v_dados(v_dados.last()).vr_nrctremp := 7867240;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85206814;
  v_dados(v_dados.last()).vr_nrctremp := 6608071;
  v_dados(v_dados.last()).vr_vllanmto := 29.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85189723;
  v_dados(v_dados.last()).vr_nrctremp := 7089569;
  v_dados(v_dados.last()).vr_vllanmto := 21.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85176133;
  v_dados(v_dados.last()).vr_nrctremp := 7389599;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85115266;
  v_dados(v_dados.last()).vr_nrctremp := 6635487;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85092711;
  v_dados(v_dados.last()).vr_nrctremp := 6406922;
  v_dados(v_dados.last()).vr_vllanmto := 102.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85074373;
  v_dados(v_dados.last()).vr_nrctremp := 7987822;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85050458;
  v_dados(v_dados.last()).vr_nrctremp := 5691194;
  v_dados(v_dados.last()).vr_vllanmto := 845.2;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 85027006;
  v_dados(v_dados.last()).vr_nrctremp := 6257310;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84984902;
  v_dados(v_dados.last()).vr_nrctremp := 7488065;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84828587;
  v_dados(v_dados.last()).vr_nrctremp := 6753807;
  v_dados(v_dados.last()).vr_vllanmto := 1313.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84808896;
  v_dados(v_dados.last()).vr_nrctremp := 7584686;
  v_dados(v_dados.last()).vr_vllanmto := 10906.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84792400;
  v_dados(v_dados.last()).vr_nrctremp := 7224738;
  v_dados(v_dados.last()).vr_vllanmto := 29.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84783940;
  v_dados(v_dados.last()).vr_nrctremp := 6679265;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84767197;
  v_dados(v_dados.last()).vr_nrctremp := 7179211;
  v_dados(v_dados.last()).vr_vllanmto := 19.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84737956;
  v_dados(v_dados.last()).vr_nrctremp := 7068082;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84737956;
  v_dados(v_dados.last()).vr_nrctremp := 7395511;
  v_dados(v_dados.last()).vr_vllanmto := 16.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84737883;
  v_dados(v_dados.last()).vr_nrctremp := 6646599;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84735201;
  v_dados(v_dados.last()).vr_nrctremp := 6627036;
  v_dados(v_dados.last()).vr_vllanmto := 755.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84733586;
  v_dados(v_dados.last()).vr_nrctremp := 6921135;
  v_dados(v_dados.last()).vr_vllanmto := 14.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84721316;
  v_dados(v_dados.last()).vr_nrctremp := 7710583;
  v_dados(v_dados.last()).vr_vllanmto := 64.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84682990;
  v_dados(v_dados.last()).vr_nrctremp := 6699401;
  v_dados(v_dados.last()).vr_vllanmto := 19.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84650338;
  v_dados(v_dados.last()).vr_nrctremp := 7097777;
  v_dados(v_dados.last()).vr_vllanmto := 29.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84574984;
  v_dados(v_dados.last()).vr_nrctremp := 7781429;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84544651;
  v_dados(v_dados.last()).vr_nrctremp := 7935480;
  v_dados(v_dados.last()).vr_vllanmto := 19.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84548215;
  v_dados(v_dados.last()).vr_nrctremp := 7204447;
  v_dados(v_dados.last()).vr_vllanmto := 3447.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84534125;
  v_dados(v_dados.last()).vr_nrctremp := 7850513;
  v_dados(v_dados.last()).vr_vllanmto := 14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84529920;
  v_dados(v_dados.last()).vr_nrctremp := 6317891;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84525380;
  v_dados(v_dados.last()).vr_nrctremp := 7773189;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84420413;
  v_dados(v_dados.last()).vr_nrctremp := 7895220;
  v_dados(v_dados.last()).vr_vllanmto := 32499.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84346132;
  v_dados(v_dados.last()).vr_nrctremp := 6191815;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84266139;
  v_dados(v_dados.last()).vr_nrctremp := 7155786;
  v_dados(v_dados.last()).vr_vllanmto := 3470.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84247711;
  v_dados(v_dados.last()).vr_nrctremp := 8067640;
  v_dados(v_dados.last()).vr_vllanmto := 23.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84232811;
  v_dados(v_dados.last()).vr_nrctremp := 6267194;
  v_dados(v_dados.last()).vr_vllanmto := 25.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84233982;
  v_dados(v_dados.last()).vr_nrctremp := 7008494;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84209682;
  v_dados(v_dados.last()).vr_nrctremp := 6707637;
  v_dados(v_dados.last()).vr_vllanmto := 20.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84148179;
  v_dados(v_dados.last()).vr_nrctremp := 6337886;
  v_dados(v_dados.last()).vr_vllanmto := 4925.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84135166;
  v_dados(v_dados.last()).vr_nrctremp := 7801413;
  v_dados(v_dados.last()).vr_vllanmto := 18458.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84142766;
  v_dados(v_dados.last()).vr_nrctremp := 7304942;
  v_dados(v_dados.last()).vr_vllanmto := 12.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84135166;
  v_dados(v_dados.last()).vr_nrctremp := 7808362;
  v_dados(v_dados.last()).vr_vllanmto := 26875.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84129980;
  v_dados(v_dados.last()).vr_nrctremp := 7020060;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84076070;
  v_dados(v_dados.last()).vr_nrctremp := 7098131;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84063939;
  v_dados(v_dados.last()).vr_nrctremp := 6677713;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84050381;
  v_dados(v_dados.last()).vr_nrctremp := 6394083;
  v_dados(v_dados.last()).vr_vllanmto := 5145.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84017180;
  v_dados(v_dados.last()).vr_nrctremp := 7584625;
  v_dados(v_dados.last()).vr_vllanmto := 34.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 84011386;
  v_dados(v_dados.last()).vr_nrctremp := 7010783;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83956123;
  v_dados(v_dados.last()).vr_nrctremp := 6468398;
  v_dados(v_dados.last()).vr_vllanmto := 1459.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83920862;
  v_dados(v_dados.last()).vr_nrctremp := 8037548;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83861890;
  v_dados(v_dados.last()).vr_nrctremp := 7460277;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83856390;
  v_dados(v_dados.last()).vr_nrctremp := 6537132;
  v_dados(v_dados.last()).vr_vllanmto := 1235.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83821597;
  v_dados(v_dados.last()).vr_nrctremp := 6968793;
  v_dados(v_dados.last()).vr_vllanmto := 2470.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83795561;
  v_dados(v_dados.last()).vr_nrctremp := 6973807;
  v_dados(v_dados.last()).vr_vllanmto := 464.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83783598;
  v_dados(v_dados.last()).vr_nrctremp := 6578175;
  v_dados(v_dados.last()).vr_vllanmto := 15.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83776451;
  v_dados(v_dados.last()).vr_nrctremp := 7539225;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83676643;
  v_dados(v_dados.last()).vr_nrctremp := 7955535;
  v_dados(v_dados.last()).vr_vllanmto := 11.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83653198;
  v_dados(v_dados.last()).vr_nrctremp := 7956695;
  v_dados(v_dados.last()).vr_vllanmto := 13.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83593853;
  v_dados(v_dados.last()).vr_nrctremp := 6812280;
  v_dados(v_dados.last()).vr_vllanmto := 24.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83575677;
  v_dados(v_dados.last()).vr_nrctremp := 7703248;
  v_dados(v_dados.last()).vr_vllanmto := 23.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83413812;
  v_dados(v_dados.last()).vr_nrctremp := 7659298;
  v_dados(v_dados.last()).vr_vllanmto := 14.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83373225;
  v_dados(v_dados.last()).vr_nrctremp := 6842761;
  v_dados(v_dados.last()).vr_vllanmto := 29.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83348468;
  v_dados(v_dados.last()).vr_nrctremp := 7632149;
  v_dados(v_dados.last()).vr_vllanmto := 20.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83352589;
  v_dados(v_dados.last()).vr_nrctremp := 6880760;
  v_dados(v_dados.last()).vr_vllanmto := 27.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83345663;
  v_dados(v_dados.last()).vr_nrctremp := 6860528;
  v_dados(v_dados.last()).vr_vllanmto := 1103.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83326294;
  v_dados(v_dados.last()).vr_nrctremp := 8151658;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83296930;
  v_dados(v_dados.last()).vr_nrctremp := 6993826;
  v_dados(v_dados.last()).vr_vllanmto := 422.47;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83263993;
  v_dados(v_dados.last()).vr_nrctremp := 6912730;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83272968;
  v_dados(v_dados.last()).vr_nrctremp := 6908266;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83200258;
  v_dados(v_dados.last()).vr_nrctremp := 7918017;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83165886;
  v_dados(v_dados.last()).vr_nrctremp := 6974556;
  v_dados(v_dados.last()).vr_vllanmto := 758.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83128689;
  v_dados(v_dados.last()).vr_nrctremp := 8139313;
  v_dados(v_dados.last()).vr_vllanmto := 12.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83109692;
  v_dados(v_dados.last()).vr_nrctremp := 7477015;
  v_dados(v_dados.last()).vr_vllanmto := 12.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83109692;
  v_dados(v_dados.last()).vr_nrctremp := 8121138;
  v_dados(v_dados.last()).vr_vllanmto := 20.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83078010;
  v_dados(v_dados.last()).vr_nrctremp := 8011243;
  v_dados(v_dados.last()).vr_vllanmto := 19.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83055487;
  v_dados(v_dados.last()).vr_nrctremp := 7730157;
  v_dados(v_dados.last()).vr_vllanmto := 597.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 83028668;
  v_dados(v_dados.last()).vr_nrctremp := 7740691;
  v_dados(v_dados.last()).vr_vllanmto := 13.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82957932;
  v_dados(v_dados.last()).vr_nrctremp := 8163150;
  v_dados(v_dados.last()).vr_vllanmto := 15.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82928916;
  v_dados(v_dados.last()).vr_nrctremp := 7762825;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82893098;
  v_dados(v_dados.last()).vr_nrctremp := 8031272;
  v_dados(v_dados.last()).vr_vllanmto := 15.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82841861;
  v_dados(v_dados.last()).vr_nrctremp := 7688768;
  v_dados(v_dados.last()).vr_vllanmto := 38.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82700818;
  v_dados(v_dados.last()).vr_nrctremp := 7260659;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82633800;
  v_dados(v_dados.last()).vr_nrctremp := 8069188;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82634661;
  v_dados(v_dados.last()).vr_nrctremp := 7980340;
  v_dados(v_dados.last()).vr_vllanmto := 36.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82619557;
  v_dados(v_dados.last()).vr_nrctremp := 7536616;
  v_dados(v_dados.last()).vr_vllanmto := 49.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82594104;
  v_dados(v_dados.last()).vr_nrctremp := 7347363;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82552258;
  v_dados(v_dados.last()).vr_nrctremp := 7618797;
  v_dados(v_dados.last()).vr_vllanmto := 29973.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82504830;
  v_dados(v_dados.last()).vr_nrctremp := 8042798;
  v_dados(v_dados.last()).vr_vllanmto := 14.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82485445;
  v_dados(v_dados.last()).vr_nrctremp := 8094516;
  v_dados(v_dados.last()).vr_vllanmto := 29.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82448183;
  v_dados(v_dados.last()).vr_nrctremp := 8069252;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82363161;
  v_dados(v_dados.last()).vr_nrctremp := 7468803;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82322414;
  v_dados(v_dados.last()).vr_nrctremp := 8057580;
  v_dados(v_dados.last()).vr_vllanmto := 16.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82304483;
  v_dados(v_dados.last()).vr_nrctremp := 7511234;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82256390;
  v_dados(v_dados.last()).vr_nrctremp := 7538792;
  v_dados(v_dados.last()).vr_vllanmto := 21.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82198969;
  v_dados(v_dados.last()).vr_nrctremp := 7576771;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 82086664;
  v_dados(v_dados.last()).vr_nrctremp := 7745107;
  v_dados(v_dados.last()).vr_vllanmto := 27023.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 81899521;
  v_dados(v_dados.last()).vr_nrctremp := 7810862;
  v_dados(v_dados.last()).vr_vllanmto := 18.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 81663595;
  v_dados(v_dados.last()).vr_nrctremp := 7940446;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 81620675;
  v_dados(v_dados.last()).vr_nrctremp := 8035643;
  v_dados(v_dados.last()).vr_vllanmto := 16.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 81571089;
  v_dados(v_dados.last()).vr_nrctremp := 7987621;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 81592477;
  v_dados(v_dados.last()).vr_nrctremp := 7989840;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19933126;
  v_dados(v_dados.last()).vr_nrctremp := 5793704;
  v_dados(v_dados.last()).vr_vllanmto := 11.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19931255;
  v_dados(v_dados.last()).vr_nrctremp := 6243277;
  v_dados(v_dados.last()).vr_vllanmto := 117.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19900627;
  v_dados(v_dados.last()).vr_nrctremp := 8153376;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19900554;
  v_dados(v_dados.last()).vr_nrctremp := 7986926;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19909098;
  v_dados(v_dados.last()).vr_nrctremp := 5204912;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19889933;
  v_dados(v_dados.last()).vr_nrctremp := 8079786;
  v_dados(v_dados.last()).vr_vllanmto := 28.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19825293;
  v_dados(v_dados.last()).vr_nrctremp := 7977294;
  v_dados(v_dados.last()).vr_vllanmto := 19.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19785461;
  v_dados(v_dados.last()).vr_nrctremp := 4921364;
  v_dados(v_dados.last()).vr_vllanmto := 14.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19757433;
  v_dados(v_dados.last()).vr_nrctremp := 6747896;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19724276;
  v_dados(v_dados.last()).vr_nrctremp := 7609874;
  v_dados(v_dados.last()).vr_vllanmto := 34.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19722117;
  v_dados(v_dados.last()).vr_nrctremp := 6693146;
  v_dados(v_dados.last()).vr_vllanmto := 12.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19721137;
  v_dados(v_dados.last()).vr_nrctremp := 6793742;
  v_dados(v_dados.last()).vr_vllanmto := 25.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19710658;
  v_dados(v_dados.last()).vr_nrctremp := 6844392;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19665172;
  v_dados(v_dados.last()).vr_nrctremp := 3858963;
  v_dados(v_dados.last()).vr_vllanmto := 5643.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19661410;
  v_dados(v_dados.last()).vr_nrctremp := 5672938;
  v_dados(v_dados.last()).vr_vllanmto := 1643.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19575203;
  v_dados(v_dados.last()).vr_nrctremp := 7345673;
  v_dados(v_dados.last()).vr_vllanmto := 22.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19580479;
  v_dados(v_dados.last()).vr_nrctremp := 6943420;
  v_dados(v_dados.last()).vr_vllanmto := 13.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19562977;
  v_dados(v_dados.last()).vr_nrctremp := 7482898;
  v_dados(v_dados.last()).vr_vllanmto := 10.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19523289;
  v_dados(v_dados.last()).vr_nrctremp := 4558023;
  v_dados(v_dados.last()).vr_vllanmto := 960.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 19519184;
  v_dados(v_dados.last()).vr_nrctremp := 7956703;
  v_dados(v_dados.last()).vr_vllanmto := 10.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9924558;
  v_dados(v_dados.last()).vr_nrctremp := 7799813;
  v_dados(v_dados.last()).vr_vllanmto := 28.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9738096;
  v_dados(v_dados.last()).vr_nrctremp := 7921127;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99784491;
  v_dados(v_dados.last()).vr_nrctremp := 501184;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99657325;
  v_dados(v_dados.last()).vr_nrctremp := 435842;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99625202;
  v_dados(v_dados.last()).vr_nrctremp := 522734;
  v_dados(v_dados.last()).vr_vllanmto := 15.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99589974;
  v_dados(v_dados.last()).vr_nrctremp := 303878;
  v_dados(v_dados.last()).vr_vllanmto := 52.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99589974;
  v_dados(v_dados.last()).vr_nrctremp := 536862;
  v_dados(v_dados.last()).vr_vllanmto := 53.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99495104;
  v_dados(v_dados.last()).vr_nrctremp := 472649;
  v_dados(v_dados.last()).vr_vllanmto := 12.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99490846;
  v_dados(v_dados.last()).vr_nrctremp := 395508;
  v_dados(v_dados.last()).vr_vllanmto := 80.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99463008;
  v_dados(v_dados.last()).vr_nrctremp := 480009;
  v_dados(v_dados.last()).vr_vllanmto := 31.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99424894;
  v_dados(v_dados.last()).vr_nrctremp := 383395;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99400073;
  v_dados(v_dados.last()).vr_nrctremp := 493816;
  v_dados(v_dados.last()).vr_vllanmto := 43.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99398460;
  v_dados(v_dados.last()).vr_nrctremp := 376735;
  v_dados(v_dados.last()).vr_vllanmto := 13.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99362112;
  v_dados(v_dados.last()).vr_nrctremp := 368400;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99360853;
  v_dados(v_dados.last()).vr_nrctremp := 527126;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99356929;
  v_dados(v_dados.last()).vr_nrctremp := 534974;
  v_dados(v_dados.last()).vr_vllanmto := 54.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99341204;
  v_dados(v_dados.last()).vr_nrctremp := 440677;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99336685;
  v_dados(v_dados.last()).vr_nrctremp := 444313;
  v_dados(v_dados.last()).vr_vllanmto := 19.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99336162;
  v_dados(v_dados.last()).vr_nrctremp := 336241;
  v_dados(v_dados.last()).vr_vllanmto := 158.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99322498;
  v_dados(v_dados.last()).vr_nrctremp := 382071;
  v_dados(v_dados.last()).vr_vllanmto := 2683.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99315203;
  v_dados(v_dados.last()).vr_nrctremp := 378559;
  v_dados(v_dados.last()).vr_vllanmto := 20.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99302357;
  v_dados(v_dados.last()).vr_nrctremp := 474347;
  v_dados(v_dados.last()).vr_vllanmto := 19.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99300770;
  v_dados(v_dados.last()).vr_nrctremp := 486560;
  v_dados(v_dados.last()).vr_vllanmto := 28.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99294052;
  v_dados(v_dados.last()).vr_nrctremp := 491578;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99291479;
  v_dados(v_dados.last()).vr_nrctremp := 353095;
  v_dados(v_dados.last()).vr_vllanmto := 328.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99286718;
  v_dados(v_dados.last()).vr_nrctremp := 404068;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99263173;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 1356.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99254697;
  v_dados(v_dados.last()).vr_nrctremp := 488334;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99242575;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 148.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99233703;
  v_dados(v_dados.last()).vr_nrctremp := 440287;
  v_dados(v_dados.last()).vr_vllanmto := 10.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99228424;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 1132.27;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99213770;
  v_dados(v_dados.last()).vr_nrctremp := 526843;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99198975;
  v_dados(v_dados.last()).vr_nrctremp := 385817;
  v_dados(v_dados.last()).vr_vllanmto := 16.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99133393;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 2182.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99129825;
  v_dados(v_dados.last()).vr_nrctremp := 535422;
  v_dados(v_dados.last()).vr_vllanmto := 43.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99126664;
  v_dados(v_dados.last()).vr_nrctremp := 462064;
  v_dados(v_dados.last()).vr_vllanmto := 16.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99122510;
  v_dados(v_dados.last()).vr_nrctremp := 525128;
  v_dados(v_dados.last()).vr_vllanmto := 12.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99113880;
  v_dados(v_dados.last()).vr_nrctremp := 382587;
  v_dados(v_dados.last()).vr_vllanmto := 1924.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99107198;
  v_dados(v_dados.last()).vr_nrctremp := 533139;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99097427;
  v_dados(v_dados.last()).vr_nrctremp := 318129;
  v_dados(v_dados.last()).vr_vllanmto := 2562.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99091640;
  v_dados(v_dados.last()).vr_nrctremp := 487434;
  v_dados(v_dados.last()).vr_vllanmto := 19.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99068621;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := 3079.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99068745;
  v_dados(v_dados.last()).vr_nrctremp := 524502;
  v_dados(v_dados.last()).vr_vllanmto := 18.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99041057;
  v_dados(v_dados.last()).vr_nrctremp := 329872;
  v_dados(v_dados.last()).vr_vllanmto := 206.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99036797;
  v_dados(v_dados.last()).vr_nrctremp := 330810;
  v_dados(v_dados.last()).vr_vllanmto := 108.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99021048;
  v_dados(v_dados.last()).vr_nrctremp := 500268;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99021498;
  v_dados(v_dados.last()).vr_nrctremp := 367150;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99016273;
  v_dados(v_dados.last()).vr_nrctremp := 532789;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99010704;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 2182.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99012030;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 26661.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84119136;
  v_dados(v_dados.last()).vr_nrctremp := 426071;
  v_dados(v_dados.last()).vr_vllanmto := 997.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82230536;
  v_dados(v_dados.last()).vr_nrctremp := 502464;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98985000;
  v_dados(v_dados.last()).vr_nrctremp := 348292;
  v_dados(v_dados.last()).vr_vllanmto := 1962.06;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98985000;
  v_dados(v_dados.last()).vr_nrctremp := 374317;
  v_dados(v_dados.last()).vr_vllanmto := 1275.85;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98973851;
  v_dados(v_dados.last()).vr_nrctremp := 399005;
  v_dados(v_dados.last()).vr_vllanmto := 1978.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98936778;
  v_dados(v_dados.last()).vr_nrctremp := 448080;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98920820;
  v_dados(v_dados.last()).vr_nrctremp := 531434;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98908790;
  v_dados(v_dados.last()).vr_nrctremp := 467278;
  v_dados(v_dados.last()).vr_vllanmto := 14.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98878760;
  v_dados(v_dados.last()).vr_nrctremp := 465246;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98867725;
  v_dados(v_dados.last()).vr_nrctremp := 506242;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98869159;
  v_dados(v_dados.last()).vr_nrctremp := 356325;
  v_dados(v_dados.last()).vr_vllanmto := 110.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98848925;
  v_dados(v_dados.last()).vr_nrctremp := 373912;
  v_dados(v_dados.last()).vr_vllanmto := 22.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98843478;
  v_dados(v_dados.last()).vr_nrctremp := 384151;
  v_dados(v_dados.last()).vr_vllanmto := 4483.41;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98818546;
  v_dados(v_dados.last()).vr_nrctremp := 450500;
  v_dados(v_dados.last()).vr_vllanmto := 796.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98808117;
  v_dados(v_dados.last()).vr_nrctremp := 429429;
  v_dados(v_dados.last()).vr_vllanmto := 10.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98806602;
  v_dados(v_dados.last()).vr_nrctremp := 524856;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98794140;
  v_dados(v_dados.last()).vr_nrctremp := 499489;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98785591;
  v_dados(v_dados.last()).vr_nrctremp := 506870;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98763717;
  v_dados(v_dados.last()).vr_nrctremp := 495659;
  v_dados(v_dados.last()).vr_vllanmto := 21.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98762648;
  v_dados(v_dados.last()).vr_nrctremp := 522443;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85710857;
  v_dados(v_dados.last()).vr_nrctremp := 409576;
  v_dados(v_dados.last()).vr_vllanmto := 5147.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85606332;
  v_dados(v_dados.last()).vr_nrctremp := 464368;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85533696;
  v_dados(v_dados.last()).vr_nrctremp := 363449;
  v_dados(v_dados.last()).vr_vllanmto := 25.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85398772;
  v_dados(v_dados.last()).vr_nrctremp := 378298;
  v_dados(v_dados.last()).vr_vllanmto := 105.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85301213;
  v_dados(v_dados.last()).vr_nrctremp := 379118;
  v_dados(v_dados.last()).vr_vllanmto := 44.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85244953;
  v_dados(v_dados.last()).vr_nrctremp := 472974;
  v_dados(v_dados.last()).vr_vllanmto := 161.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84731419;
  v_dados(v_dados.last()).vr_nrctremp := 500587;
  v_dados(v_dados.last()).vr_vllanmto := 23.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84763388;
  v_dados(v_dados.last()).vr_nrctremp := 398871;
  v_dados(v_dados.last()).vr_vllanmto := 18.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84731141;
  v_dados(v_dados.last()).vr_nrctremp := 474688;
  v_dados(v_dados.last()).vr_vllanmto := 10.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84479108;
  v_dados(v_dados.last()).vr_nrctremp := 526539;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84508698;
  v_dados(v_dados.last()).vr_nrctremp := 410375;
  v_dados(v_dados.last()).vr_vllanmto := 1085.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84370114;
  v_dados(v_dados.last()).vr_nrctremp := 415902;
  v_dados(v_dados.last()).vr_vllanmto := 76.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84376180;
  v_dados(v_dados.last()).vr_nrctremp := 415668;
  v_dados(v_dados.last()).vr_vllanmto := 24707.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84300019;
  v_dados(v_dados.last()).vr_nrctremp := 427146;
  v_dados(v_dados.last()).vr_vllanmto := 1469.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84223871;
  v_dados(v_dados.last()).vr_nrctremp := 421630;
  v_dados(v_dados.last()).vr_vllanmto := 1475.28;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84244712;
  v_dados(v_dados.last()).vr_nrctremp := 420713;
  v_dados(v_dados.last()).vr_vllanmto := 972.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84244445;
  v_dados(v_dados.last()).vr_nrctremp := 420674;
  v_dados(v_dados.last()).vr_vllanmto := 191.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84244445;
  v_dados(v_dados.last()).vr_nrctremp := 445923;
  v_dados(v_dados.last()).vr_vllanmto := 236.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84214031;
  v_dados(v_dados.last()).vr_nrctremp := 421960;
  v_dados(v_dados.last()).vr_vllanmto := 1606.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84186640;
  v_dados(v_dados.last()).vr_nrctremp := 423196;
  v_dados(v_dados.last()).vr_vllanmto := 29.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84186640;
  v_dados(v_dados.last()).vr_nrctremp := 435418;
  v_dados(v_dados.last()).vr_vllanmto := 11.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84015870;
  v_dados(v_dados.last()).vr_nrctremp := 430175;
  v_dados(v_dados.last()).vr_vllanmto := 45.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84019310;
  v_dados(v_dados.last()).vr_nrctremp := 429868;
  v_dados(v_dados.last()).vr_vllanmto := 210;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84013184;
  v_dados(v_dados.last()).vr_nrctremp := 435801;
  v_dados(v_dados.last()).vr_vllanmto := 817.56;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83734651;
  v_dados(v_dados.last()).vr_nrctremp := 440729;
  v_dados(v_dados.last()).vr_vllanmto := 16.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83669515;
  v_dados(v_dados.last()).vr_nrctremp := 501616;
  v_dados(v_dados.last()).vr_vllanmto := 44339.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83664688;
  v_dados(v_dados.last()).vr_nrctremp := 443506;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83589619;
  v_dados(v_dados.last()).vr_nrctremp := 489317;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83460390;
  v_dados(v_dados.last()).vr_nrctremp := 450619;
  v_dados(v_dados.last()).vr_vllanmto := 35.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83446400;
  v_dados(v_dados.last()).vr_nrctremp := 450924;
  v_dados(v_dados.last()).vr_vllanmto := 18.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83426272;
  v_dados(v_dados.last()).vr_nrctremp := 493339;
  v_dados(v_dados.last()).vr_vllanmto := 15.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83383646;
  v_dados(v_dados.last()).vr_nrctremp := 453566;
  v_dados(v_dados.last()).vr_vllanmto := 20509.83;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83394257;
  v_dados(v_dados.last()).vr_nrctremp := 453031;
  v_dados(v_dados.last()).vr_vllanmto := 10.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83235744;
  v_dados(v_dados.last()).vr_nrctremp := 458967;
  v_dados(v_dados.last()).vr_vllanmto := 10552.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83192697;
  v_dados(v_dados.last()).vr_nrctremp := 538137;
  v_dados(v_dados.last()).vr_vllanmto := 21.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83197095;
  v_dados(v_dados.last()).vr_nrctremp := 518072;
  v_dados(v_dados.last()).vr_vllanmto := 17.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83099530;
  v_dados(v_dados.last()).vr_nrctremp := 463986;
  v_dados(v_dados.last()).vr_vllanmto := 13.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82867895;
  v_dados(v_dados.last()).vr_nrctremp := 472296;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82774498;
  v_dados(v_dados.last()).vr_nrctremp := 475523;
  v_dados(v_dados.last()).vr_vllanmto := 71.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82683026;
  v_dados(v_dados.last()).vr_nrctremp := 479116;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82669198;
  v_dados(v_dados.last()).vr_nrctremp := 479757;
  v_dados(v_dados.last()).vr_vllanmto := 15.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82566593;
  v_dados(v_dados.last()).vr_nrctremp := 483948;
  v_dados(v_dados.last()).vr_vllanmto := 11.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82624380;
  v_dados(v_dados.last()).vr_nrctremp := 505269;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82538697;
  v_dados(v_dados.last()).vr_nrctremp := 486582;
  v_dados(v_dados.last()).vr_vllanmto := 32.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82294038;
  v_dados(v_dados.last()).vr_nrctremp := 495652;
  v_dados(v_dados.last()).vr_vllanmto := 12.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82321698;
  v_dados(v_dados.last()).vr_nrctremp := 514655;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82266565;
  v_dados(v_dados.last()).vr_nrctremp := 525112;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82229406;
  v_dados(v_dados.last()).vr_nrctremp := 509402;
  v_dados(v_dados.last()).vr_vllanmto := 22.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82222240;
  v_dados(v_dados.last()).vr_nrctremp := 526059;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82219702;
  v_dados(v_dados.last()).vr_nrctremp := 536159;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82218870;
  v_dados(v_dados.last()).vr_nrctremp := 513709;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82052263;
  v_dados(v_dados.last()).vr_nrctremp := 505762;
  v_dados(v_dados.last()).vr_vllanmto := 11.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82070040;
  v_dados(v_dados.last()).vr_nrctremp := 507122;
  v_dados(v_dados.last()).vr_vllanmto := 11.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 82000468;
  v_dados(v_dados.last()).vr_nrctremp := 507925;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81793952;
  v_dados(v_dados.last()).vr_nrctremp := 516648;
  v_dados(v_dados.last()).vr_vllanmto := 21.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81740948;
  v_dados(v_dados.last()).vr_nrctremp := 519505;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81589646;
  v_dados(v_dados.last()).vr_nrctremp := 528807;
  v_dados(v_dados.last()).vr_vllanmto := 13.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81669364;
  v_dados(v_dados.last()).vr_nrctremp := 531704;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81663714;
  v_dados(v_dados.last()).vr_nrctremp := 522360;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81562616;
  v_dados(v_dados.last()).vr_nrctremp := 533689;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 81569629;
  v_dados(v_dados.last()).vr_nrctremp := 525807;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99996235;
  v_dados(v_dados.last()).vr_nrctremp := 25233;
  v_dados(v_dados.last()).vr_vllanmto := 223.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99999056;
  v_dados(v_dados.last()).vr_nrctremp := 24536;
  v_dados(v_dados.last()).vr_vllanmto := 1379.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99996227;
  v_dados(v_dados.last()).vr_nrctremp := 88605;
  v_dados(v_dados.last()).vr_vllanmto := 27.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99979926;
  v_dados(v_dados.last()).vr_nrctremp := 78448;
  v_dados(v_dados.last()).vr_vllanmto := 972.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99979926;
  v_dados(v_dados.last()).vr_nrctremp := 81837;
  v_dados(v_dados.last()).vr_vllanmto := 579.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99965208;
  v_dados(v_dados.last()).vr_nrctremp := 24502;
  v_dados(v_dados.last()).vr_vllanmto := 543.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99960907;
  v_dados(v_dados.last()).vr_nrctremp := 76410;
  v_dados(v_dados.last()).vr_vllanmto := 20.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99940396;
  v_dados(v_dados.last()).vr_nrctremp := 106670;
  v_dados(v_dados.last()).vr_vllanmto := 35.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99890593;
  v_dados(v_dados.last()).vr_nrctremp := 118842;
  v_dados(v_dados.last()).vr_vllanmto := 19.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99888203;
  v_dados(v_dados.last()).vr_nrctremp := 117875;
  v_dados(v_dados.last()).vr_vllanmto := 27.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99883902;
  v_dados(v_dados.last()).vr_nrctremp := 117352;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99869373;
  v_dados(v_dados.last()).vr_nrctremp := 111242;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99866390;
  v_dados(v_dados.last()).vr_nrctremp := 141236;
  v_dados(v_dados.last()).vr_vllanmto := 23.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99858568;
  v_dados(v_dados.last()).vr_nrctremp := 27934;
  v_dados(v_dados.last()).vr_vllanmto := 166.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99852241;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 2214.37;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99849895;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 3647.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99844915;
  v_dados(v_dados.last()).vr_nrctremp := 102339;
  v_dados(v_dados.last()).vr_vllanmto := 23.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99834081;
  v_dados(v_dados.last()).vr_nrctremp := 115385;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99809591;
  v_dados(v_dados.last()).vr_nrctremp := 80775;
  v_dados(v_dados.last()).vr_vllanmto := 251.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99775875;
  v_dados(v_dados.last()).vr_nrctremp := 146101;
  v_dados(v_dados.last()).vr_vllanmto := 47.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99742519;
  v_dados(v_dados.last()).vr_nrctremp := 59721;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99730910;
  v_dados(v_dados.last()).vr_nrctremp := 116557;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99728524;
  v_dados(v_dados.last()).vr_nrctremp := 122861;
  v_dados(v_dados.last()).vr_vllanmto := 12.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99726882;
  v_dados(v_dados.last()).vr_nrctremp := 83042;
  v_dados(v_dados.last()).vr_vllanmto := 32.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99713365;
  v_dados(v_dados.last()).vr_nrctremp := 63200;
  v_dados(v_dados.last()).vr_vllanmto := 10914.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99713365;
  v_dados(v_dados.last()).vr_nrctremp := 55893;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99703971;
  v_dados(v_dados.last()).vr_nrctremp := 85137;
  v_dados(v_dados.last()).vr_vllanmto := 27.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99700590;
  v_dados(v_dados.last()).vr_nrctremp := 91176;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99695766;
  v_dados(v_dados.last()).vr_nrctremp := 99070;
  v_dados(v_dados.last()).vr_vllanmto := 10.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99689502;
  v_dados(v_dados.last()).vr_nrctremp := 101735;
  v_dados(v_dados.last()).vr_vllanmto := 186.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99684420;
  v_dados(v_dados.last()).vr_nrctremp := 95930;
  v_dados(v_dados.last()).vr_vllanmto := 30.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99677369;
  v_dados(v_dados.last()).vr_nrctremp := 79948;
  v_dados(v_dados.last()).vr_vllanmto := 517.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99676486;
  v_dados(v_dados.last()).vr_nrctremp := 95971;
  v_dados(v_dados.last()).vr_vllanmto := 1382.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99652277;
  v_dados(v_dados.last()).vr_nrctremp := 117332;
  v_dados(v_dados.last()).vr_vllanmto := 18452.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99651203;
  v_dados(v_dados.last()).vr_nrctremp := 59739;
  v_dados(v_dados.last()).vr_vllanmto := 38.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99650258;
  v_dados(v_dados.last()).vr_nrctremp := 60356;
  v_dados(v_dados.last()).vr_vllanmto := 990.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99650223;
  v_dados(v_dados.last()).vr_nrctremp := 60062;
  v_dados(v_dados.last()).vr_vllanmto := 34.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99649144;
  v_dados(v_dados.last()).vr_nrctremp := 103907;
  v_dados(v_dados.last()).vr_vllanmto := 634.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99648288;
  v_dados(v_dados.last()).vr_nrctremp := 66094;
  v_dados(v_dados.last()).vr_vllanmto := 12539.33;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99648105;
  v_dados(v_dados.last()).vr_nrctremp := 61604;
  v_dados(v_dados.last()).vr_vllanmto := 14.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99630079;
  v_dados(v_dados.last()).vr_nrctremp := 133924;
  v_dados(v_dados.last()).vr_vllanmto := 12.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84000635;
  v_dados(v_dados.last()).vr_nrctremp := 138385;
  v_dados(v_dados.last()).vr_vllanmto := 11.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83072535;
  v_dados(v_dados.last()).vr_nrctremp := 113288;
  v_dados(v_dados.last()).vr_vllanmto := 22.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85836117;
  v_dados(v_dados.last()).vr_nrctremp := 109004;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85776343;
  v_dados(v_dados.last()).vr_nrctremp := 138515;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85569763;
  v_dados(v_dados.last()).vr_nrctremp := 65975;
  v_dados(v_dados.last()).vr_vllanmto := 3614.11;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85482986;
  v_dados(v_dados.last()).vr_nrctremp := 71862;
  v_dados(v_dados.last()).vr_vllanmto := 1080;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85406350;
  v_dados(v_dados.last()).vr_nrctremp := 149502;
  v_dados(v_dados.last()).vr_vllanmto := 21.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85125601;
  v_dados(v_dados.last()).vr_nrctremp := 97364;
  v_dados(v_dados.last()).vr_vllanmto := 3263.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84845414;
  v_dados(v_dados.last()).vr_nrctremp := 92379;
  v_dados(v_dados.last()).vr_vllanmto := 9759.79;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84456930;
  v_dados(v_dados.last()).vr_nrctremp := 84735;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84241438;
  v_dados(v_dados.last()).vr_nrctremp := 112669;
  v_dados(v_dados.last()).vr_vllanmto := 11.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84157399;
  v_dados(v_dados.last()).vr_nrctremp := 136560;
  v_dados(v_dados.last()).vr_vllanmto := 15.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83817271;
  v_dados(v_dados.last()).vr_nrctremp := 99917;
  v_dados(v_dados.last()).vr_vllanmto := 335.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83757481;
  v_dados(v_dados.last()).vr_nrctremp := 100840;
  v_dados(v_dados.last()).vr_vllanmto := 13.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83577793;
  v_dados(v_dados.last()).vr_nrctremp := 143051;
  v_dados(v_dados.last()).vr_vllanmto := 10.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83426710;
  v_dados(v_dados.last()).vr_nrctremp := 145587;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83114130;
  v_dados(v_dados.last()).vr_nrctremp := 115959;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 83108785;
  v_dados(v_dados.last()).vr_nrctremp := 144131;
  v_dados(v_dados.last()).vr_vllanmto := 19.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 82573700;
  v_dados(v_dados.last()).vr_nrctremp := 144399;
  v_dados(v_dados.last()).vr_vllanmto := 10.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 82235864;
  v_dados(v_dados.last()).vr_nrctremp := 129676;
  v_dados(v_dados.last()).vr_vllanmto := 13.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 82191972;
  v_dados(v_dados.last()).vr_nrctremp := 130591;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 82187703;
  v_dados(v_dados.last()).vr_nrctremp := 130388;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 82101388;
  v_dados(v_dados.last()).vr_nrctremp := 132150;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 81856962;
  v_dados(v_dados.last()).vr_nrctremp := 137223;
  v_dados(v_dados.last()).vr_vllanmto := 20.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 81412630;
  v_dados(v_dados.last()).vr_nrctremp := 148205;
  v_dados(v_dados.last()).vr_vllanmto := 69.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 81249608;
  v_dados(v_dados.last()).vr_nrctremp := 149487;
  v_dados(v_dados.last()).vr_vllanmto := 23.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99985543;
  v_dados(v_dados.last()).vr_nrctremp := 281739;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99954923;
  v_dados(v_dados.last()).vr_nrctremp := 283799;
  v_dados(v_dados.last()).vr_vllanmto := 28.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99927748;
  v_dados(v_dados.last()).vr_nrctremp := 272745;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99882000;
  v_dados(v_dados.last()).vr_nrctremp := 283668;
  v_dados(v_dados.last()).vr_vllanmto := 15.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99875705;
  v_dados(v_dados.last()).vr_nrctremp := 270409;
  v_dados(v_dados.last()).vr_vllanmto := 32.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99853760;
  v_dados(v_dados.last()).vr_nrctremp := 284827;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99814250;
  v_dados(v_dados.last()).vr_nrctremp := 269186;
  v_dados(v_dados.last()).vr_vllanmto := 217.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 99748274;
  v_dados(v_dados.last()).vr_nrctremp := 276952;
  v_dados(v_dados.last()).vr_vllanmto := 11.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 83594027;
  v_dados(v_dados.last()).vr_nrctremp := 270949;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 83557350;
  v_dados(v_dados.last()).vr_nrctremp := 271645;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 83517308;
  v_dados(v_dados.last()).vr_nrctremp := 272437;
  v_dados(v_dados.last()).vr_vllanmto := 43.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82636206;
  v_dados(v_dados.last()).vr_nrctremp := 277876;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82581320;
  v_dados(v_dados.last()).vr_nrctremp := 280632;
  v_dados(v_dados.last()).vr_vllanmto := 93.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82568960;
  v_dados(v_dados.last()).vr_nrctremp := 283211;
  v_dados(v_dados.last()).vr_vllanmto := 28.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82465320;
  v_dados(v_dados.last()).vr_nrctremp := 277920;
  v_dados(v_dados.last()).vr_vllanmto := 48.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82465320;
  v_dados(v_dados.last()).vr_nrctremp := 278347;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82290644;
  v_dados(v_dados.last()).vr_nrctremp := 279043;
  v_dados(v_dados.last()).vr_vllanmto := 14.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82223939;
  v_dados(v_dados.last()).vr_nrctremp := 279351;
  v_dados(v_dados.last()).vr_vllanmto := 52.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82216606;
  v_dados(v_dados.last()).vr_nrctremp := 280862;
  v_dados(v_dados.last()).vr_vllanmto := 25.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82216606;
  v_dados(v_dados.last()).vr_nrctremp := 280865;
  v_dados(v_dados.last()).vr_vllanmto := 34.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82156310;
  v_dados(v_dados.last()).vr_nrctremp := 279877;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 82042209;
  v_dados(v_dados.last()).vr_nrctremp := 280698;
  v_dados(v_dados.last()).vr_vllanmto := 15.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81712189;
  v_dados(v_dados.last()).vr_nrctremp := 283416;
  v_dados(v_dados.last()).vr_vllanmto := 34.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81712189;
  v_dados(v_dados.last()).vr_nrctremp := 283417;
  v_dados(v_dados.last()).vr_vllanmto := 28.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81657226;
  v_dados(v_dados.last()).vr_nrctremp := 283055;
  v_dados(v_dados.last()).vr_vllanmto := 14.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81583710;
  v_dados(v_dados.last()).vr_nrctremp := 283413;
  v_dados(v_dados.last()).vr_vllanmto := 41.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81574835;
  v_dados(v_dados.last()).vr_nrctremp := 283648;
  v_dados(v_dados.last()).vr_vllanmto := 13.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81568304;
  v_dados(v_dados.last()).vr_nrctremp := 284077;
  v_dados(v_dados.last()).vr_vllanmto := 43.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 81536585;
  v_dados(v_dados.last()).vr_nrctremp := 283904;
  v_dados(v_dados.last()).vr_vllanmto := 32.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99997290;
  v_dados(v_dados.last()).vr_nrctremp := 90721;
  v_dados(v_dados.last()).vr_vllanmto := 24.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99996995;
  v_dados(v_dados.last()).vr_nrctremp := 91516;
  v_dados(v_dados.last()).vr_vllanmto := 19.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99996995;
  v_dados(v_dados.last()).vr_nrctremp := 101662;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99995956;
  v_dados(v_dados.last()).vr_nrctremp := 92017;
  v_dados(v_dados.last()).vr_vllanmto := 18.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99995808;
  v_dados(v_dados.last()).vr_nrctremp := 106692;
  v_dados(v_dados.last()).vr_vllanmto := 19.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99995417;
  v_dados(v_dados.last()).vr_nrctremp := 110661;
  v_dados(v_dados.last()).vr_vllanmto := 40.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99979136;
  v_dados(v_dados.last()).vr_nrctremp := 90708;
  v_dados(v_dados.last()).vr_vllanmto := 25.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99972336;
  v_dados(v_dados.last()).vr_nrctremp := 114125;
  v_dados(v_dados.last()).vr_vllanmto := 30.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99684136;
  v_dados(v_dados.last()).vr_nrctremp := 91660;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99972271;
  v_dados(v_dados.last()).vr_nrctremp := 110731;
  v_dados(v_dados.last()).vr_vllanmto := 56.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99973570;
  v_dados(v_dados.last()).vr_nrctremp := 103205;
  v_dados(v_dados.last()).vr_vllanmto := 26.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99973537;
  v_dados(v_dados.last()).vr_nrctremp := 80039;
  v_dados(v_dados.last()).vr_vllanmto := 11.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99970422;
  v_dados(v_dados.last()).vr_nrctremp := 90748;
  v_dados(v_dados.last()).vr_vllanmto := 22.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99969742;
  v_dados(v_dados.last()).vr_nrctremp := 57566;
  v_dados(v_dados.last()).vr_vllanmto := 19.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99949938;
  v_dados(v_dados.last()).vr_nrctremp := 122364;
  v_dados(v_dados.last()).vr_vllanmto := 14.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99937620;
  v_dados(v_dados.last()).vr_nrctremp := 104611;
  v_dados(v_dados.last()).vr_vllanmto := 65.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99935953;
  v_dados(v_dados.last()).vr_nrctremp := 108987;
  v_dados(v_dados.last()).vr_vllanmto := 24.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99934701;
  v_dados(v_dados.last()).vr_nrctremp := 123737;
  v_dados(v_dados.last()).vr_vllanmto := 50;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99933217;
  v_dados(v_dados.last()).vr_nrctremp := 97175;
  v_dados(v_dados.last()).vr_vllanmto := 41.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99926237;
  v_dados(v_dados.last()).vr_nrctremp := 121724;
  v_dados(v_dados.last()).vr_vllanmto := 25.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99909820;
  v_dados(v_dados.last()).vr_nrctremp := 56274;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99867745;
  v_dados(v_dados.last()).vr_nrctremp := 102798;
  v_dados(v_dados.last()).vr_vllanmto := 119.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99841860;
  v_dados(v_dados.last()).vr_nrctremp := 126374;
  v_dados(v_dados.last()).vr_vllanmto := 16.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99837331;
  v_dados(v_dados.last()).vr_nrctremp := 116240;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99807106;
  v_dados(v_dados.last()).vr_nrctremp := 126765;
  v_dados(v_dados.last()).vr_vllanmto := 17.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99789639;
  v_dados(v_dados.last()).vr_nrctremp := 118306;
  v_dados(v_dados.last()).vr_vllanmto := 25.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99746450;
  v_dados(v_dados.last()).vr_nrctremp := 119092;
  v_dados(v_dados.last()).vr_vllanmto := 55.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99746450;
  v_dados(v_dados.last()).vr_nrctremp := 126312;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99714132;
  v_dados(v_dados.last()).vr_nrctremp := 101130;
  v_dados(v_dados.last()).vr_vllanmto := 2513.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99711990;
  v_dados(v_dados.last()).vr_nrctremp := 116153;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99705656;
  v_dados(v_dados.last()).vr_nrctremp := 104973;
  v_dados(v_dados.last()).vr_vllanmto := 21.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99690578;
  v_dados(v_dados.last()).vr_nrctremp := 107939;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99662493;
  v_dados(v_dados.last()).vr_nrctremp := 131636;
  v_dados(v_dados.last()).vr_vllanmto := 10.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99632357;
  v_dados(v_dados.last()).vr_nrctremp := 129624;
  v_dados(v_dados.last()).vr_vllanmto := 26.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99619881;
  v_dados(v_dados.last()).vr_nrctremp := 95652;
  v_dados(v_dados.last()).vr_vllanmto := 20.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99618532;
  v_dados(v_dados.last()).vr_nrctremp := 65947;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99610825;
  v_dados(v_dados.last()).vr_nrctremp := 91051;
  v_dados(v_dados.last()).vr_vllanmto := 17.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99610906;
  v_dados(v_dados.last()).vr_nrctremp := 110729;
  v_dados(v_dados.last()).vr_vllanmto := 28887.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99607190;
  v_dados(v_dados.last()).vr_nrctremp := 72380;
  v_dados(v_dados.last()).vr_vllanmto := 17.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99603837;
  v_dados(v_dados.last()).vr_nrctremp := 92585;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99603683;
  v_dados(v_dados.last()).vr_nrctremp := 90868;
  v_dados(v_dados.last()).vr_vllanmto := 838.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99600323;
  v_dados(v_dados.last()).vr_nrctremp := 91233;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99600919;
  v_dados(v_dados.last()).vr_nrctremp := 131025;
  v_dados(v_dados.last()).vr_vllanmto := 11.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99599376;
  v_dados(v_dados.last()).vr_nrctremp := 109205;
  v_dados(v_dados.last()).vr_vllanmto := 14.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99587823;
  v_dados(v_dados.last()).vr_nrctremp := 109366;
  v_dados(v_dados.last()).vr_vllanmto := 18.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99585383;
  v_dados(v_dados.last()).vr_nrctremp := 123796;
  v_dados(v_dados.last()).vr_vllanmto := 27.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99585855;
  v_dados(v_dados.last()).vr_nrctremp := 88622;
  v_dados(v_dados.last()).vr_vllanmto := 1793.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99575949;
  v_dados(v_dados.last()).vr_nrctremp := 107369;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99571390;
  v_dados(v_dados.last()).vr_nrctremp := 92165;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99572443;
  v_dados(v_dados.last()).vr_nrctremp := 68493;
  v_dados(v_dados.last()).vr_vllanmto := 13.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99553198;
  v_dados(v_dados.last()).vr_nrctremp := 82971;
  v_dados(v_dados.last()).vr_vllanmto := 36.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99554011;
  v_dados(v_dados.last()).vr_nrctremp := 103100;
  v_dados(v_dados.last()).vr_vllanmto := 29.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99553996;
  v_dados(v_dados.last()).vr_nrctremp := 82037;
  v_dados(v_dados.last()).vr_vllanmto := 2690.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99553910;
  v_dados(v_dados.last()).vr_nrctremp := 83056;
  v_dados(v_dados.last()).vr_vllanmto := 748.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99536285;
  v_dados(v_dados.last()).vr_nrctremp := 127494;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99527278;
  v_dados(v_dados.last()).vr_nrctremp := 108793;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99529513;
  v_dados(v_dados.last()).vr_nrctremp := 106504;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99526301;
  v_dados(v_dados.last()).vr_nrctremp := 109937;
  v_dados(v_dados.last()).vr_vllanmto := 24.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99525445;
  v_dados(v_dados.last()).vr_nrctremp := 118813;
  v_dados(v_dados.last()).vr_vllanmto := 18.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99522861;
  v_dados(v_dados.last()).vr_nrctremp := 113803;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99522861;
  v_dados(v_dados.last()).vr_nrctremp := 117565;
  v_dados(v_dados.last()).vr_vllanmto := 18.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85856835;
  v_dados(v_dados.last()).vr_nrctremp := 97646;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84786736;
  v_dados(v_dados.last()).vr_nrctremp := 95436;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84216336;
  v_dados(v_dados.last()).vr_nrctremp := 99663;
  v_dados(v_dados.last()).vr_vllanmto := 12.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84216336;
  v_dados(v_dados.last()).vr_nrctremp := 106125;
  v_dados(v_dados.last()).vr_vllanmto := 40.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 86116886;
  v_dados(v_dados.last()).vr_nrctremp := 112188;
  v_dados(v_dados.last()).vr_vllanmto := 30.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82349436;
  v_dados(v_dados.last()).vr_nrctremp := 118437;
  v_dados(v_dados.last()).vr_vllanmto := 110.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85914037;
  v_dados(v_dados.last()).vr_nrctremp := 130285;
  v_dados(v_dados.last()).vr_vllanmto := 7115.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85887072;
  v_dados(v_dados.last()).vr_nrctremp := 103950;
  v_dados(v_dados.last()).vr_vllanmto := 16.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85886491;
  v_dados(v_dados.last()).vr_nrctremp := 71178;
  v_dados(v_dados.last()).vr_vllanmto := 496.72;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85883697;
  v_dados(v_dados.last()).vr_nrctremp := 108059;
  v_dados(v_dados.last()).vr_vllanmto := 17.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85878723;
  v_dados(v_dados.last()).vr_nrctremp := 91657;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85877522;
  v_dados(v_dados.last()).vr_nrctremp := 121584;
  v_dados(v_dados.last()).vr_vllanmto := 33.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85867101;
  v_dados(v_dados.last()).vr_nrctremp := 110893;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85859087;
  v_dados(v_dados.last()).vr_nrctremp := 118815;
  v_dados(v_dados.last()).vr_vllanmto := 36.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85859052;
  v_dados(v_dados.last()).vr_nrctremp := 106454;
  v_dados(v_dados.last()).vr_vllanmto := 880.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85852821;
  v_dados(v_dados.last()).vr_nrctremp := 88553;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85835480;
  v_dados(v_dados.last()).vr_nrctremp := 102640;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85834149;
  v_dados(v_dados.last()).vr_nrctremp := 99439;
  v_dados(v_dados.last()).vr_vllanmto := 24.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85833622;
  v_dados(v_dados.last()).vr_nrctremp := 73261;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85796611;
  v_dados(v_dados.last()).vr_nrctremp := 72406;
  v_dados(v_dados.last()).vr_vllanmto := 2215.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85812560;
  v_dados(v_dados.last()).vr_nrctremp := 112505;
  v_dados(v_dados.last()).vr_vllanmto := 17.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85806978;
  v_dados(v_dados.last()).vr_nrctremp := 72270;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85796832;
  v_dados(v_dados.last()).vr_nrctremp := 113182;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85796611;
  v_dados(v_dados.last()).vr_nrctremp := 85135;
  v_dados(v_dados.last()).vr_vllanmto := 2769.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85795828;
  v_dados(v_dados.last()).vr_nrctremp := 128165;
  v_dados(v_dados.last()).vr_vllanmto := 22.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85795666;
  v_dados(v_dados.last()).vr_nrctremp := 125764;
  v_dados(v_dados.last()).vr_vllanmto := 51.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85794287;
  v_dados(v_dados.last()).vr_nrctremp := 85268;
  v_dados(v_dados.last()).vr_vllanmto := 241.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85773573;
  v_dados(v_dados.last()).vr_nrctremp := 113354;
  v_dados(v_dados.last()).vr_vllanmto := 11.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85772429;
  v_dados(v_dados.last()).vr_nrctremp := 73418;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85772429;
  v_dados(v_dados.last()).vr_nrctremp := 73422;
  v_dados(v_dados.last()).vr_vllanmto := 165.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85771732;
  v_dados(v_dados.last()).vr_nrctremp := 130059;
  v_dados(v_dados.last()).vr_vllanmto := 28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85750557;
  v_dados(v_dados.last()).vr_nrctremp := 100206;
  v_dados(v_dados.last()).vr_vllanmto := 40.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85729230;
  v_dados(v_dados.last()).vr_nrctremp := 72996;
  v_dados(v_dados.last()).vr_vllanmto := 86.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85700401;
  v_dados(v_dados.last()).vr_nrctremp := 97212;
  v_dados(v_dados.last()).vr_vllanmto := 6248.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85716510;
  v_dados(v_dados.last()).vr_nrctremp := 131798;
  v_dados(v_dados.last()).vr_vllanmto := 10.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85714232;
  v_dados(v_dados.last()).vr_nrctremp := 74338;
  v_dados(v_dados.last()).vr_vllanmto := 95.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85699802;
  v_dados(v_dados.last()).vr_nrctremp := 74775;
  v_dados(v_dados.last()).vr_vllanmto := 176.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85492191;
  v_dados(v_dados.last()).vr_nrctremp := 77826;
  v_dados(v_dados.last()).vr_vllanmto := 344.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85580996;
  v_dados(v_dados.last()).vr_nrctremp := 75101;
  v_dados(v_dados.last()).vr_vllanmto := 2772.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85580759;
  v_dados(v_dados.last()).vr_nrctremp := 91178;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85491837;
  v_dados(v_dados.last()).vr_nrctremp := 96151;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85489905;
  v_dados(v_dados.last()).vr_nrctremp := 101028;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85488801;
  v_dados(v_dados.last()).vr_nrctremp := 98255;
  v_dados(v_dados.last()).vr_vllanmto := 17164.5;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85467448;
  v_dados(v_dados.last()).vr_nrctremp := 116677;
  v_dados(v_dados.last()).vr_vllanmto := 13.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85454486;
  v_dados(v_dados.last()).vr_nrctremp := 117503;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85420220;
  v_dados(v_dados.last()).vr_nrctremp := 127210;
  v_dados(v_dados.last()).vr_vllanmto := 25.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85447730;
  v_dados(v_dados.last()).vr_nrctremp := 129056;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85420042;
  v_dados(v_dados.last()).vr_nrctremp := 80162;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85213055;
  v_dados(v_dados.last()).vr_nrctremp := 81413;
  v_dados(v_dados.last()).vr_vllanmto := 25.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85211320;
  v_dados(v_dados.last()).vr_nrctremp := 82634;
  v_dados(v_dados.last()).vr_vllanmto := 95.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85202282;
  v_dados(v_dados.last()).vr_nrctremp := 80671;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85043125;
  v_dados(v_dados.last()).vr_nrctremp := 123747;
  v_dados(v_dados.last()).vr_vllanmto := 38.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85161470;
  v_dados(v_dados.last()).vr_nrctremp := 81031;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85000876;
  v_dados(v_dados.last()).vr_nrctremp := 83702;
  v_dados(v_dados.last()).vr_vllanmto := 365.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85000531;
  v_dados(v_dados.last()).vr_nrctremp := 106614;
  v_dados(v_dados.last()).vr_vllanmto := 18.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84964120;
  v_dados(v_dados.last()).vr_nrctremp := 127935;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84960655;
  v_dados(v_dados.last()).vr_nrctremp := 85491;
  v_dados(v_dados.last()).vr_vllanmto := 67.47;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84960655;
  v_dados(v_dados.last()).vr_nrctremp := 85493;
  v_dados(v_dados.last()).vr_vllanmto := 105.15;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84960655;
  v_dados(v_dados.last()).vr_nrctremp := 85494;
  v_dados(v_dados.last()).vr_vllanmto := 174.8;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84960655;
  v_dados(v_dados.last()).vr_nrctremp := 85495;
  v_dados(v_dados.last()).vr_vllanmto := 143.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84954400;
  v_dados(v_dados.last()).vr_nrctremp := 84301;
  v_dados(v_dados.last()).vr_vllanmto := 96.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84953810;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 21.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84952130;
  v_dados(v_dados.last()).vr_nrctremp := 84306;
  v_dados(v_dados.last()).vr_vllanmto := 129.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84950897;
  v_dados(v_dados.last()).vr_nrctremp := 109386;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84931671;
  v_dados(v_dados.last()).vr_nrctremp := 112826;
  v_dados(v_dados.last()).vr_vllanmto := 13.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84868171;
  v_dados(v_dados.last()).vr_nrctremp := 125655;
  v_dados(v_dados.last()).vr_vllanmto := 59.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84867760;
  v_dados(v_dados.last()).vr_nrctremp := 85404;
  v_dados(v_dados.last()).vr_vllanmto := 431.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84799595;
  v_dados(v_dados.last()).vr_nrctremp := 126895;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84760621;
  v_dados(v_dados.last()).vr_nrctremp := 114608;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84754079;
  v_dados(v_dados.last()).vr_nrctremp := 86919;
  v_dados(v_dados.last()).vr_vllanmto := 7097.35;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84742615;
  v_dados(v_dados.last()).vr_nrctremp := 87201;
  v_dados(v_dados.last()).vr_vllanmto := 2478.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84742615;
  v_dados(v_dados.last()).vr_nrctremp := 87202;
  v_dados(v_dados.last()).vr_vllanmto := 579.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84742615;
  v_dados(v_dados.last()).vr_nrctremp := 91962;
  v_dados(v_dados.last()).vr_vllanmto := 2163.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84697946;
  v_dados(v_dados.last()).vr_nrctremp := 87717;
  v_dados(v_dados.last()).vr_vllanmto := 12.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84685840;
  v_dados(v_dados.last()).vr_nrctremp := 106406;
  v_dados(v_dados.last()).vr_vllanmto := 18.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84526858;
  v_dados(v_dados.last()).vr_nrctremp := 107235;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84627441;
  v_dados(v_dados.last()).vr_nrctremp := 104977;
  v_dados(v_dados.last()).vr_vllanmto := 19.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84624434;
  v_dados(v_dados.last()).vr_nrctremp := 91551;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84526858;
  v_dados(v_dados.last()).vr_nrctremp := 115811;
  v_dados(v_dados.last()).vr_vllanmto := 17.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84436743;
  v_dados(v_dados.last()).vr_nrctremp := 93355;
  v_dados(v_dados.last()).vr_vllanmto := 1257.02;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84457406;
  v_dados(v_dados.last()).vr_nrctremp := 105554;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84371900;
  v_dados(v_dados.last()).vr_nrctremp := 115507;
  v_dados(v_dados.last()).vr_vllanmto := 28.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84352620;
  v_dados(v_dados.last()).vr_nrctremp := 91958;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84281499;
  v_dados(v_dados.last()).vr_nrctremp := 127149;
  v_dados(v_dados.last()).vr_vllanmto := 20.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84325496;
  v_dados(v_dados.last()).vr_nrctremp := 98271;
  v_dados(v_dados.last()).vr_vllanmto := 16.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84317370;
  v_dados(v_dados.last()).vr_nrctremp := 92366;
  v_dados(v_dados.last()).vr_vllanmto := 39.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84280433;
  v_dados(v_dados.last()).vr_nrctremp := 127076;
  v_dados(v_dados.last()).vr_vllanmto := 10.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84273992;
  v_dados(v_dados.last()).vr_nrctremp := 93189;
  v_dados(v_dados.last()).vr_vllanmto := 20.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84261820;
  v_dados(v_dados.last()).vr_nrctremp := 93183;
  v_dados(v_dados.last()).vr_vllanmto := 263.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84213337;
  v_dados(v_dados.last()).vr_nrctremp := 128493;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84145013;
  v_dados(v_dados.last()).vr_nrctremp := 94696;
  v_dados(v_dados.last()).vr_vllanmto := 31.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84149795;
  v_dados(v_dados.last()).vr_nrctremp := 97214;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84137118;
  v_dados(v_dados.last()).vr_nrctremp := 94656;
  v_dados(v_dados.last()).vr_vllanmto := 1169.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84137118;
  v_dados(v_dados.last()).vr_nrctremp := 95863;
  v_dados(v_dados.last()).vr_vllanmto := 184.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84137029;
  v_dados(v_dados.last()).vr_nrctremp := 119987;
  v_dados(v_dados.last()).vr_vllanmto := 10.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84136863;
  v_dados(v_dados.last()).vr_nrctremp := 131083;
  v_dados(v_dados.last()).vr_vllanmto := 35.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84136618;
  v_dados(v_dados.last()).vr_nrctremp := 94670;
  v_dados(v_dados.last()).vr_vllanmto := 61.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84136332;
  v_dados(v_dados.last()).vr_nrctremp := 95984;
  v_dados(v_dados.last()).vr_vllanmto := 24.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84135875;
  v_dados(v_dados.last()).vr_nrctremp := 97094;
  v_dados(v_dados.last()).vr_vllanmto := 919.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84135417;
  v_dados(v_dados.last()).vr_nrctremp := 94677;
  v_dados(v_dados.last()).vr_vllanmto := 579.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84134933;
  v_dados(v_dados.last()).vr_nrctremp := 131283;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84130970;
  v_dados(v_dados.last()).vr_nrctremp := 96518;
  v_dados(v_dados.last()).vr_vllanmto := 12.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84130970;
  v_dados(v_dados.last()).vr_nrctremp := 96522;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84130970;
  v_dados(v_dados.last()).vr_nrctremp := 100559;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84130970;
  v_dados(v_dados.last()).vr_nrctremp := 109666;
  v_dados(v_dados.last()).vr_vllanmto := 20.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84123869;
  v_dados(v_dados.last()).vr_nrctremp := 96641;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84095237;
  v_dados(v_dados.last()).vr_nrctremp := 97668;
  v_dados(v_dados.last()).vr_vllanmto := 33.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84096020;
  v_dados(v_dados.last()).vr_nrctremp := 97640;
  v_dados(v_dados.last()).vr_vllanmto := 325.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84087293;
  v_dados(v_dados.last()).vr_nrctremp := 95590;
  v_dados(v_dados.last()).vr_vllanmto := 13.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84085789;
  v_dados(v_dados.last()).vr_nrctremp := 127566;
  v_dados(v_dados.last()).vr_vllanmto := 10.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84083549;
  v_dados(v_dados.last()).vr_nrctremp := 101061;
  v_dados(v_dados.last()).vr_vllanmto := 3811.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84082453;
  v_dados(v_dados.last()).vr_nrctremp := 98933;
  v_dados(v_dados.last()).vr_vllanmto := 10.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84082453;
  v_dados(v_dados.last()).vr_nrctremp := 108704;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84064773;
  v_dados(v_dados.last()).vr_nrctremp := 96527;
  v_dados(v_dados.last()).vr_vllanmto := 74321.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84064773;
  v_dados(v_dados.last()).vr_nrctremp := 126376;
  v_dados(v_dados.last()).vr_vllanmto := 30994.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84058609;
  v_dados(v_dados.last()).vr_nrctremp := 96634;
  v_dados(v_dados.last()).vr_vllanmto := 27.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84050187;
  v_dados(v_dados.last()).vr_nrctremp := 96529;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84010649;
  v_dados(v_dados.last()).vr_nrctremp := 97016;
  v_dados(v_dados.last()).vr_vllanmto := 873.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84018763;
  v_dados(v_dados.last()).vr_nrctremp := 98041;
  v_dados(v_dados.last()).vr_vllanmto := 51.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84006714;
  v_dados(v_dados.last()).vr_nrctremp := 97852;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83978623;
  v_dados(v_dados.last()).vr_nrctremp := 129607;
  v_dados(v_dados.last()).vr_vllanmto := 66.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83976850;
  v_dados(v_dados.last()).vr_nrctremp := 100243;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83911049;
  v_dados(v_dados.last()).vr_nrctremp := 102646;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83902201;
  v_dados(v_dados.last()).vr_nrctremp := 98089;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83876685;
  v_dados(v_dados.last()).vr_nrctremp := 106448;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83862757;
  v_dados(v_dados.last()).vr_nrctremp := 125313;
  v_dados(v_dados.last()).vr_vllanmto := 78.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83716220;
  v_dados(v_dados.last()).vr_nrctremp := 101132;
  v_dados(v_dados.last()).vr_vllanmto := 78.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83839577;
  v_dados(v_dados.last()).vr_nrctremp := 101364;
  v_dados(v_dados.last()).vr_vllanmto := 1952.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83802878;
  v_dados(v_dados.last()).vr_nrctremp := 99199;
  v_dados(v_dados.last()).vr_vllanmto := 483.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83716220;
  v_dados(v_dados.last()).vr_nrctremp := 101137;
  v_dados(v_dados.last()).vr_vllanmto := 154.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83691308;
  v_dados(v_dados.last()).vr_nrctremp := 102501;
  v_dados(v_dados.last()).vr_vllanmto := 19.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83686045;
  v_dados(v_dados.last()).vr_nrctremp := 100585;
  v_dados(v_dados.last()).vr_vllanmto := 16.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83555811;
  v_dados(v_dados.last()).vr_nrctremp := 102136;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83670947;
  v_dados(v_dados.last()).vr_nrctremp := 111222;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83669850;
  v_dados(v_dados.last()).vr_nrctremp := 101848;
  v_dados(v_dados.last()).vr_vllanmto := 13.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83667393;
  v_dados(v_dados.last()).vr_nrctremp := 129754;
  v_dados(v_dados.last()).vr_vllanmto := 66.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83555811;
  v_dados(v_dados.last()).vr_nrctremp := 126733;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83552880;
  v_dados(v_dados.last()).vr_nrctremp := 119427;
  v_dados(v_dados.last()).vr_vllanmto := 40.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83516727;
  v_dados(v_dados.last()).vr_nrctremp := 109929;
  v_dados(v_dados.last()).vr_vllanmto := 13.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83521615;
  v_dados(v_dados.last()).vr_nrctremp := 102406;
  v_dados(v_dados.last()).vr_vllanmto := 2106.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83452567;
  v_dados(v_dados.last()).vr_nrctremp := 118085;
  v_dados(v_dados.last()).vr_vllanmto := 33.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83450521;
  v_dados(v_dados.last()).vr_nrctremp := 109334;
  v_dados(v_dados.last()).vr_vllanmto := 589.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83381309;
  v_dados(v_dados.last()).vr_nrctremp := 103993;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83164014;
  v_dados(v_dados.last()).vr_nrctremp := 108106;
  v_dados(v_dados.last()).vr_vllanmto := 10.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83184945;
  v_dados(v_dados.last()).vr_nrctremp := 118234;
  v_dados(v_dados.last()).vr_vllanmto := 1172.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83183230;
  v_dados(v_dados.last()).vr_nrctremp := 108148;
  v_dados(v_dados.last()).vr_vllanmto := 15.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83144447;
  v_dados(v_dados.last()).vr_nrctremp := 111594;
  v_dados(v_dados.last()).vr_vllanmto := 20.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83142843;
  v_dados(v_dados.last()).vr_nrctremp := 107160;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83104984;
  v_dados(v_dados.last()).vr_nrctremp := 116312;
  v_dados(v_dados.last()).vr_vllanmto := 22.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83127470;
  v_dados(v_dados.last()).vr_nrctremp := 121957;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83127470;
  v_dados(v_dados.last()).vr_nrctremp := 129965;
  v_dados(v_dados.last()).vr_vllanmto := 13.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83104984;
  v_dados(v_dados.last()).vr_nrctremp := 123465;
  v_dados(v_dados.last()).vr_vllanmto := 36.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83080597;
  v_dados(v_dados.last()).vr_nrctremp := 109944;
  v_dados(v_dados.last()).vr_vllanmto := 13.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83078541;
  v_dados(v_dados.last()).vr_nrctremp := 111185;
  v_dados(v_dados.last()).vr_vllanmto := 21.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83073264;
  v_dados(v_dados.last()).vr_nrctremp := 127914;
  v_dados(v_dados.last()).vr_vllanmto := 13.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83071067;
  v_dados(v_dados.last()).vr_nrctremp := 108284;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83002626;
  v_dados(v_dados.last()).vr_nrctremp := 128912;
  v_dados(v_dados.last()).vr_vllanmto := 42.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82999759;
  v_dados(v_dados.last()).vr_nrctremp := 109513;
  v_dados(v_dados.last()).vr_vllanmto := 13.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82987572;
  v_dados(v_dados.last()).vr_nrctremp := 109058;
  v_dados(v_dados.last()).vr_vllanmto := 2247.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82932859;
  v_dados(v_dados.last()).vr_nrctremp := 110811;
  v_dados(v_dados.last()).vr_vllanmto := 27.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82971277;
  v_dados(v_dados.last()).vr_nrctremp := 110723;
  v_dados(v_dados.last()).vr_vllanmto := 11.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82957371;
  v_dados(v_dados.last()).vr_nrctremp := 115982;
  v_dados(v_dados.last()).vr_vllanmto := 33.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82932859;
  v_dados(v_dados.last()).vr_nrctremp := 126301;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82928789;
  v_dados(v_dados.last()).vr_nrctremp := 110453;
  v_dados(v_dados.last()).vr_vllanmto := 15.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82913633;
  v_dados(v_dados.last()).vr_nrctremp := 110529;
  v_dados(v_dados.last()).vr_vllanmto := 40.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82913633;
  v_dados(v_dados.last()).vr_nrctremp := 125408;
  v_dados(v_dados.last()).vr_vllanmto := 25.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82910138;
  v_dados(v_dados.last()).vr_nrctremp := 117443;
  v_dados(v_dados.last()).vr_vllanmto := 33.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82894523;
  v_dados(v_dados.last()).vr_nrctremp := 122623;
  v_dados(v_dados.last()).vr_vllanmto := 14.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82801061;
  v_dados(v_dados.last()).vr_nrctremp := 115126;
  v_dados(v_dados.last()).vr_vllanmto := 20.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82822000;
  v_dados(v_dados.last()).vr_nrctremp := 111922;
  v_dados(v_dados.last()).vr_vllanmto := 22.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82817952;
  v_dados(v_dados.last()).vr_nrctremp := 116670;
  v_dados(v_dados.last()).vr_vllanmto := 40.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82801061;
  v_dados(v_dados.last()).vr_nrctremp := 126390;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82731713;
  v_dados(v_dados.last()).vr_nrctremp := 127976;
  v_dados(v_dados.last()).vr_vllanmto := 11.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82730040;
  v_dados(v_dados.last()).vr_nrctremp := 113204;
  v_dados(v_dados.last()).vr_vllanmto := 54.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82611645;
  v_dados(v_dados.last()).vr_nrctremp := 113599;
  v_dados(v_dados.last()).vr_vllanmto := 35.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82612846;
  v_dados(v_dados.last()).vr_nrctremp := 116447;
  v_dados(v_dados.last()).vr_vllanmto := 20.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82583781;
  v_dados(v_dados.last()).vr_nrctremp := 113894;
  v_dados(v_dados.last()).vr_vllanmto := 11.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82564086;
  v_dados(v_dados.last()).vr_nrctremp := 114185;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82495920;
  v_dados(v_dados.last()).vr_nrctremp := 114979;
  v_dados(v_dados.last()).vr_vllanmto := 21.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82536252;
  v_dados(v_dados.last()).vr_nrctremp := 115519;
  v_dados(v_dados.last()).vr_vllanmto := 17.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82514151;
  v_dados(v_dados.last()).vr_nrctremp := 114959;
  v_dados(v_dados.last()).vr_vllanmto := 25.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82513562;
  v_dados(v_dados.last()).vr_nrctremp := 115753;
  v_dados(v_dados.last()).vr_vllanmto := 40.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82429740;
  v_dados(v_dados.last()).vr_nrctremp := 115949;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82351538;
  v_dados(v_dados.last()).vr_nrctremp := 116627;
  v_dados(v_dados.last()).vr_vllanmto := 22.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82349339;
  v_dados(v_dados.last()).vr_nrctremp := 116640;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82255881;
  v_dados(v_dados.last()).vr_nrctremp := 118404;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82262454;
  v_dados(v_dados.last()).vr_nrctremp := 117966;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82232679;
  v_dados(v_dados.last()).vr_nrctremp := 118947;
  v_dados(v_dados.last()).vr_vllanmto := 15.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82189803;
  v_dados(v_dados.last()).vr_nrctremp := 119290;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82168830;
  v_dados(v_dados.last()).vr_nrctremp := 120292;
  v_dados(v_dados.last()).vr_vllanmto := 33.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82049904;
  v_dados(v_dados.last()).vr_nrctremp := 123183;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82042373;
  v_dados(v_dados.last()).vr_nrctremp := 122637;
  v_dados(v_dados.last()).vr_vllanmto := 12.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81795106;
  v_dados(v_dados.last()).vr_nrctremp := 129451;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81894317;
  v_dados(v_dados.last()).vr_nrctremp := 123963;
  v_dados(v_dados.last()).vr_vllanmto := 25.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81761015;
  v_dados(v_dados.last()).vr_nrctremp := 129686;
  v_dados(v_dados.last()).vr_vllanmto := 18.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81746849;
  v_dados(v_dados.last()).vr_nrctremp := 125761;
  v_dados(v_dados.last()).vr_vllanmto := 21.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81739249;
  v_dados(v_dados.last()).vr_nrctremp := 126212;
  v_dados(v_dados.last()).vr_vllanmto := 11.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81717601;
  v_dados(v_dados.last()).vr_nrctremp := 125829;
  v_dados(v_dados.last()).vr_vllanmto := 20.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81711956;
  v_dados(v_dados.last()).vr_nrctremp := 126574;
  v_dados(v_dados.last()).vr_vllanmto := 18.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81647964;
  v_dados(v_dados.last()).vr_nrctremp := 127269;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81487649;
  v_dados(v_dados.last()).vr_nrctremp := 129281;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81520859;
  v_dados(v_dados.last()).vr_nrctremp := 128967;
  v_dados(v_dados.last()).vr_vllanmto := 39.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81490364;
  v_dados(v_dados.last()).vr_nrctremp := 129123;
  v_dados(v_dados.last()).vr_vllanmto := 16.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81488165;
  v_dados(v_dados.last()).vr_nrctremp := 129168;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81446101;
  v_dados(v_dados.last()).vr_nrctremp := 129776;
  v_dados(v_dados.last()).vr_vllanmto := 15.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81443129;
  v_dados(v_dados.last()).vr_nrctremp := 129890;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81422822;
  v_dados(v_dados.last()).vr_nrctremp := 131404;
  v_dados(v_dados.last()).vr_vllanmto := 11.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81387091;
  v_dados(v_dados.last()).vr_nrctremp := 130973;
  v_dados(v_dados.last()).vr_vllanmto := 13.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81371608;
  v_dados(v_dados.last()).vr_nrctremp := 132176;
  v_dados(v_dados.last()).vr_vllanmto := 21.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81323484;
  v_dados(v_dados.last()).vr_nrctremp := 131922;
  v_dados(v_dados.last()).vr_vllanmto := 10.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 81261918;
  v_dados(v_dados.last()).vr_nrctremp := 132869;
  v_dados(v_dados.last()).vr_vllanmto := 10.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99871106;
  v_dados(v_dados.last()).vr_nrctremp := 73341;
  v_dados(v_dados.last()).vr_vllanmto := 21801.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99871106;
  v_dados(v_dados.last()).vr_nrctremp := 83688;
  v_dados(v_dados.last()).vr_vllanmto := 7233.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99839245;
  v_dados(v_dados.last()).vr_nrctremp := 79313;
  v_dados(v_dados.last()).vr_vllanmto := 12.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99837684;
  v_dados(v_dados.last()).vr_nrctremp := 107161;
  v_dados(v_dados.last()).vr_vllanmto := 34.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99811707;
  v_dados(v_dados.last()).vr_nrctremp := 85134;
  v_dados(v_dados.last()).vr_vllanmto := 22.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99772388;
  v_dados(v_dados.last()).vr_nrctremp := 92894;
  v_dados(v_dados.last()).vr_vllanmto := 37.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99739283;
  v_dados(v_dados.last()).vr_nrctremp := 107217;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99686759;
  v_dados(v_dados.last()).vr_nrctremp := 109032;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99685710;
  v_dados(v_dados.last()).vr_nrctremp := 95461;
  v_dados(v_dados.last()).vr_vllanmto := 13.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99661306;
  v_dados(v_dados.last()).vr_nrctremp := 103790;
  v_dados(v_dados.last()).vr_vllanmto := 10142.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99645750;
  v_dados(v_dados.last()).vr_nrctremp := 70257;
  v_dados(v_dados.last()).vr_vllanmto := 14.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99612160;
  v_dados(v_dados.last()).vr_nrctremp := 85855;
  v_dados(v_dados.last()).vr_vllanmto := 1224.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99592894;
  v_dados(v_dados.last()).vr_nrctremp := 101796;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99573547;
  v_dados(v_dados.last()).vr_nrctremp := 75628;
  v_dados(v_dados.last()).vr_vllanmto := 10.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99561549;
  v_dados(v_dados.last()).vr_nrctremp := 86797;
  v_dados(v_dados.last()).vr_vllanmto := 31.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99553074;
  v_dados(v_dados.last()).vr_nrctremp := 91552;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99498162;
  v_dados(v_dados.last()).vr_nrctremp := 91224;
  v_dados(v_dados.last()).vr_vllanmto := 5022.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99493829;
  v_dados(v_dados.last()).vr_nrctremp := 93232;
  v_dados(v_dados.last()).vr_vllanmto := 21.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99475642;
  v_dados(v_dados.last()).vr_nrctremp := 106902;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99472325;
  v_dados(v_dados.last()).vr_nrctremp := 91460;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99470497;
  v_dados(v_dados.last()).vr_nrctremp := 102499;
  v_dados(v_dados.last()).vr_vllanmto := 11.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99470659;
  v_dados(v_dados.last()).vr_nrctremp := 96860;
  v_dados(v_dados.last()).vr_vllanmto := 2263.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99456010;
  v_dados(v_dados.last()).vr_nrctremp := 87566;
  v_dados(v_dados.last()).vr_vllanmto := 15.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99450470;
  v_dados(v_dados.last()).vr_nrctremp := 81619;
  v_dados(v_dados.last()).vr_vllanmto := 2667.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99436906;
  v_dados(v_dados.last()).vr_nrctremp := 88791;
  v_dados(v_dados.last()).vr_vllanmto := 21.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99412268;
  v_dados(v_dados.last()).vr_nrctremp := 98363;
  v_dados(v_dados.last()).vr_vllanmto := 80.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82833036;
  v_dados(v_dados.last()).vr_nrctremp := 103578;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 85496561;
  v_dados(v_dados.last()).vr_nrctremp := 104121;
  v_dados(v_dados.last()).vr_vllanmto := 12.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 85077186;
  v_dados(v_dados.last()).vr_nrctremp := 100566;
  v_dados(v_dados.last()).vr_vllanmto := 16.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 84844485;
  v_dados(v_dados.last()).vr_nrctremp := 101557;
  v_dados(v_dados.last()).vr_vllanmto := 17.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 84757329;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 1939.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 84624299;
  v_dados(v_dados.last()).vr_nrctremp := 86265;
  v_dados(v_dados.last()).vr_vllanmto := 21571.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 84187212;
  v_dados(v_dados.last()).vr_nrctremp := 82593;
  v_dados(v_dados.last()).vr_vllanmto := 55.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 83675493;
  v_dados(v_dados.last()).vr_nrctremp := 90822;
  v_dados(v_dados.last()).vr_vllanmto := 55.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 83760407;
  v_dados(v_dados.last()).vr_nrctremp := 89734;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 83457852;
  v_dados(v_dados.last()).vr_nrctremp := 92191;
  v_dados(v_dados.last()).vr_vllanmto := 62.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 83293752;
  v_dados(v_dados.last()).vr_nrctremp := 97427;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82892547;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 99.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 83112049;
  v_dados(v_dados.last()).vr_nrctremp := 99136;
  v_dados(v_dados.last()).vr_vllanmto := 13.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82892016;
  v_dados(v_dados.last()).vr_nrctremp := 96028;
  v_dados(v_dados.last()).vr_vllanmto := 11.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82887179;
  v_dados(v_dados.last()).vr_nrctremp := 108112;
  v_dados(v_dados.last()).vr_vllanmto := 23.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82760756;
  v_dados(v_dados.last()).vr_nrctremp := 90531;
  v_dados(v_dados.last()).vr_vllanmto := 133.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82648271;
  v_dados(v_dados.last()).vr_nrctremp := 98969;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82430683;
  v_dados(v_dados.last()).vr_nrctremp := 99645;
  v_dados(v_dados.last()).vr_vllanmto := 27.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82317658;
  v_dados(v_dados.last()).vr_nrctremp := 95649;
  v_dados(v_dados.last()).vr_vllanmto := 865.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82037396;
  v_dados(v_dados.last()).vr_nrctremp := 98697;
  v_dados(v_dados.last()).vr_vllanmto := 27.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99996936;
  v_dados(v_dados.last()).vr_nrctremp := 394114;
  v_dados(v_dados.last()).vr_vllanmto := 23.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99994569;
  v_dados(v_dados.last()).vr_nrctremp := 179380;
  v_dados(v_dados.last()).vr_vllanmto := 105.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99994569;
  v_dados(v_dados.last()).vr_nrctremp := 339054;
  v_dados(v_dados.last()).vr_vllanmto := 72.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99186535;
  v_dados(v_dados.last()).vr_nrctremp := 408332;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99985080;
  v_dados(v_dados.last()).vr_nrctremp := 388478;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99984784;
  v_dados(v_dados.last()).vr_nrctremp := 435025;
  v_dados(v_dados.last()).vr_vllanmto := 40.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99982455;
  v_dados(v_dados.last()).vr_nrctremp := 392051;
  v_dados(v_dados.last()).vr_vllanmto := 17.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99982455;
  v_dados(v_dados.last()).vr_nrctremp := 440292;
  v_dados(v_dados.last()).vr_vllanmto := 16.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99980460;
  v_dados(v_dados.last()).vr_nrctremp := 320518;
  v_dados(v_dados.last()).vr_vllanmto := 11.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99949750;
  v_dados(v_dados.last()).vr_nrctremp := 353542;
  v_dados(v_dados.last()).vr_vllanmto := 30.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99942402;
  v_dados(v_dados.last()).vr_nrctremp := 309787;
  v_dados(v_dados.last()).vr_vllanmto := 35.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99937158;
  v_dados(v_dados.last()).vr_nrctremp := 328300;
  v_dados(v_dados.last()).vr_vllanmto := 31.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99911876;
  v_dados(v_dados.last()).vr_nrctremp := 364198;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99901730;
  v_dados(v_dados.last()).vr_nrctremp := 334391;
  v_dados(v_dados.last()).vr_vllanmto := 27.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99866676;
  v_dados(v_dados.last()).vr_nrctremp := 197299;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99866676;
  v_dados(v_dados.last()).vr_nrctremp := 393151;
  v_dados(v_dados.last()).vr_vllanmto := 38.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99850885;
  v_dados(v_dados.last()).vr_nrctremp := 380787;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99850885;
  v_dados(v_dados.last()).vr_nrctremp := 441636;
  v_dados(v_dados.last()).vr_vllanmto := 19.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99846519;
  v_dados(v_dados.last()).vr_nrctremp := 384040;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99835568;
  v_dados(v_dados.last()).vr_nrctremp := 436305;
  v_dados(v_dados.last()).vr_vllanmto := 25.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99803119;
  v_dados(v_dados.last()).vr_nrctremp := 343231;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99791897;
  v_dados(v_dados.last()).vr_nrctremp := 439036;
  v_dados(v_dados.last()).vr_vllanmto := 26.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99788977;
  v_dados(v_dados.last()).vr_nrctremp := 287253;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99771993;
  v_dados(v_dados.last()).vr_nrctremp := 304044;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99763990;
  v_dados(v_dados.last()).vr_nrctremp := 318809;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99739100;
  v_dados(v_dados.last()).vr_nrctremp := 358054;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99724022;
  v_dados(v_dados.last()).vr_nrctremp := 162805;
  v_dados(v_dados.last()).vr_vllanmto := 341.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99690624;
  v_dados(v_dados.last()).vr_nrctremp := 341377;
  v_dados(v_dados.last()).vr_vllanmto := 10.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99680769;
  v_dados(v_dados.last()).vr_nrctremp := 353004;
  v_dados(v_dados.last()).vr_vllanmto := 14.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99654750;
  v_dados(v_dados.last()).vr_nrctremp := 358595;
  v_dados(v_dados.last()).vr_vllanmto := 12.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99651858;
  v_dados(v_dados.last()).vr_nrctremp := 339377;
  v_dados(v_dados.last()).vr_vllanmto := 31.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99648210;
  v_dados(v_dados.last()).vr_nrctremp := 354164;
  v_dados(v_dados.last()).vr_vllanmto := 10.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99638797;
  v_dados(v_dados.last()).vr_nrctremp := 330933;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99628023;
  v_dados(v_dados.last()).vr_nrctremp := 424607;
  v_dados(v_dados.last()).vr_vllanmto := 19057.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99628007;
  v_dados(v_dados.last()).vr_nrctremp := 251597;
  v_dados(v_dados.last()).vr_vllanmto := 13.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99593610;
  v_dados(v_dados.last()).vr_nrctremp := 376966;
  v_dados(v_dados.last()).vr_vllanmto := 27907.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99593610;
  v_dados(v_dados.last()).vr_nrctremp := 430756;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99584212;
  v_dados(v_dados.last()).vr_nrctremp := 339020;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99583976;
  v_dados(v_dados.last()).vr_nrctremp := 355454;
  v_dados(v_dados.last()).vr_vllanmto := 32.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99575400;
  v_dados(v_dados.last()).vr_nrctremp := 204085;
  v_dados(v_dados.last()).vr_vllanmto := 12.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99555409;
  v_dados(v_dados.last()).vr_nrctremp := 327557;
  v_dados(v_dados.last()).vr_vllanmto := 19.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99543168;
  v_dados(v_dados.last()).vr_nrctremp := 400086;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99538296;
  v_dados(v_dados.last()).vr_nrctremp := 389889;
  v_dados(v_dados.last()).vr_vllanmto := 12.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99536072;
  v_dados(v_dados.last()).vr_nrctremp := 396365;
  v_dados(v_dados.last()).vr_vllanmto := 33.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99533413;
  v_dados(v_dados.last()).vr_nrctremp := 327048;
  v_dados(v_dados.last()).vr_vllanmto := 30.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99529009;
  v_dados(v_dados.last()).vr_nrctremp := 422275;
  v_dados(v_dados.last()).vr_vllanmto := 19.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99498367;
  v_dados(v_dados.last()).vr_nrctremp := 359321;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99493560;
  v_dados(v_dados.last()).vr_nrctremp := 179782;
  v_dados(v_dados.last()).vr_vllanmto := 444.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99481642;
  v_dados(v_dados.last()).vr_nrctremp := 320766;
  v_dados(v_dados.last()).vr_vllanmto := 16.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99470128;
  v_dados(v_dados.last()).vr_nrctremp := 402365;
  v_dados(v_dados.last()).vr_vllanmto := 14.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99458640;
  v_dados(v_dados.last()).vr_nrctremp := 428491;
  v_dados(v_dados.last()).vr_vllanmto := 39.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99450518;
  v_dados(v_dados.last()).vr_nrctremp := 292376;
  v_dados(v_dados.last()).vr_vllanmto := 15.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99449676;
  v_dados(v_dados.last()).vr_nrctremp := 342784;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99444569;
  v_dados(v_dados.last()).vr_nrctremp := 410136;
  v_dados(v_dados.last()).vr_vllanmto := 11.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99433850;
  v_dados(v_dados.last()).vr_nrctremp := 291453;
  v_dados(v_dados.last()).vr_vllanmto := 7908.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99429721;
  v_dados(v_dados.last()).vr_nrctremp := 289844;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99419769;
  v_dados(v_dados.last()).vr_nrctremp := 410519;
  v_dados(v_dados.last()).vr_vllanmto := 13.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99409968;
  v_dados(v_dados.last()).vr_nrctremp := 208448;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99391562;
  v_dados(v_dados.last()).vr_nrctremp := 440344;
  v_dados(v_dados.last()).vr_vllanmto := 33.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99387948;
  v_dados(v_dados.last()).vr_nrctremp := 192831;
  v_dados(v_dados.last()).vr_vllanmto := 8464.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99382482;
  v_dados(v_dados.last()).vr_nrctremp := 169526;
  v_dados(v_dados.last()).vr_vllanmto := 10.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99381222;
  v_dados(v_dados.last()).vr_nrctremp := 403195;
  v_dados(v_dados.last()).vr_vllanmto := 20.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99379538;
  v_dados(v_dados.last()).vr_nrctremp := 396342;
  v_dados(v_dados.last()).vr_vllanmto := 42.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99378345;
  v_dados(v_dados.last()).vr_nrctremp := 404040;
  v_dados(v_dados.last()).vr_vllanmto := 10.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99373564;
  v_dados(v_dados.last()).vr_nrctremp := 263358;
  v_dados(v_dados.last()).vr_vllanmto := 7014.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99359626;
  v_dados(v_dados.last()).vr_nrctremp := 306569;
  v_dados(v_dados.last()).vr_vllanmto := 26.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99352303;
  v_dados(v_dados.last()).vr_nrctremp := 312362;
  v_dados(v_dados.last()).vr_vllanmto := 14.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99352303;
  v_dados(v_dados.last()).vr_nrctremp := 422073;
  v_dados(v_dados.last()).vr_vllanmto := 15.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99332116;
  v_dados(v_dados.last()).vr_nrctremp := 432051;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99328194;
  v_dados(v_dados.last()).vr_nrctremp := 410800;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99323770;
  v_dados(v_dados.last()).vr_nrctremp := 377031;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99321637;
  v_dados(v_dados.last()).vr_nrctremp := 161727;
  v_dados(v_dados.last()).vr_vllanmto := 27.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99301199;
  v_dados(v_dados.last()).vr_nrctremp := 433175;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99300850;
  v_dados(v_dados.last()).vr_nrctremp := 266458;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99278812;
  v_dados(v_dados.last()).vr_nrctremp := 381380;
  v_dados(v_dados.last()).vr_vllanmto := 20.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99274779;
  v_dados(v_dados.last()).vr_nrctremp := 326127;
  v_dados(v_dados.last()).vr_vllanmto := 11.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99273918;
  v_dados(v_dados.last()).vr_nrctremp := 158732;
  v_dados(v_dados.last()).vr_vllanmto := 51.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99270730;
  v_dados(v_dados.last()).vr_nrctremp := 309697;
  v_dados(v_dados.last()).vr_vllanmto := 348.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99270358;
  v_dados(v_dados.last()).vr_nrctremp := 237608;
  v_dados(v_dados.last()).vr_vllanmto := 2401.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99244357;
  v_dados(v_dados.last()).vr_nrctremp := 331019;
  v_dados(v_dados.last()).vr_vllanmto := 18.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99220148;
  v_dados(v_dados.last()).vr_nrctremp := 432549;
  v_dados(v_dados.last()).vr_vllanmto := 18.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99183099;
  v_dados(v_dados.last()).vr_nrctremp := 387685;
  v_dados(v_dados.last()).vr_vllanmto := 12.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99176912;
  v_dados(v_dados.last()).vr_nrctremp := 213460;
  v_dados(v_dados.last()).vr_vllanmto := 571.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99167760;
  v_dados(v_dados.last()).vr_nrctremp := 202073;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99141655;
  v_dados(v_dados.last()).vr_nrctremp := 341906;
  v_dados(v_dados.last()).vr_vllanmto := 18.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99140292;
  v_dados(v_dados.last()).vr_nrctremp := 420954;
  v_dados(v_dados.last()).vr_vllanmto := 20.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99095017;
  v_dados(v_dados.last()).vr_nrctremp := 439924;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99094703;
  v_dados(v_dados.last()).vr_nrctremp := 364086;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99088932;
  v_dados(v_dados.last()).vr_nrctremp := 432919;
  v_dados(v_dados.last()).vr_vllanmto := 44.87;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99079755;
  v_dados(v_dados.last()).vr_nrctremp := 416025;
  v_dados(v_dados.last()).vr_vllanmto := 770.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99079550;
  v_dados(v_dados.last()).vr_nrctremp := 432140;
  v_dados(v_dados.last()).vr_vllanmto := 48.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99075717;
  v_dados(v_dados.last()).vr_nrctremp := 280692;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99075644;
  v_dados(v_dados.last()).vr_nrctremp := 366422;
  v_dados(v_dados.last()).vr_vllanmto := 19.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99070626;
  v_dados(v_dados.last()).vr_nrctremp := 374461;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99065533;
  v_dados(v_dados.last()).vr_nrctremp := 278165;
  v_dados(v_dados.last()).vr_vllanmto := 20.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99065320;
  v_dados(v_dados.last()).vr_nrctremp := 269482;
  v_dados(v_dados.last()).vr_vllanmto := 69.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99063441;
  v_dados(v_dados.last()).vr_nrctremp := 263351;
  v_dados(v_dados.last()).vr_vllanmto := 37.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99063441;
  v_dados(v_dados.last()).vr_nrctremp := 270772;
  v_dados(v_dados.last()).vr_vllanmto := 36.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99063077;
  v_dados(v_dados.last()).vr_nrctremp := 366483;
  v_dados(v_dados.last()).vr_vllanmto := 21002.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99047012;
  v_dados(v_dados.last()).vr_nrctremp := 416630;
  v_dados(v_dados.last()).vr_vllanmto := 19.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99043807;
  v_dados(v_dados.last()).vr_nrctremp := 348788;
  v_dados(v_dados.last()).vr_vllanmto := 288.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99040573;
  v_dados(v_dados.last()).vr_nrctremp := 249604;
  v_dados(v_dados.last()).vr_vllanmto := 21.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99038609;
  v_dados(v_dados.last()).vr_nrctremp := 414458;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99037750;
  v_dados(v_dados.last()).vr_nrctremp := 380720;
  v_dados(v_dados.last()).vr_vllanmto := 19.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99032368;
  v_dados(v_dados.last()).vr_nrctremp := 357161;
  v_dados(v_dados.last()).vr_vllanmto := 19.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99030438;
  v_dados(v_dados.last()).vr_nrctremp := 322654;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99027585;
  v_dados(v_dados.last()).vr_nrctremp := 423960;
  v_dados(v_dados.last()).vr_vllanmto := 39.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99027585;
  v_dados(v_dados.last()).vr_nrctremp := 442649;
  v_dados(v_dados.last()).vr_vllanmto := 39.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99023814;
  v_dados(v_dados.last()).vr_nrctremp := 368801;
  v_dados(v_dados.last()).vr_vllanmto := 15.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99015463;
  v_dados(v_dados.last()).vr_nrctremp := 352169;
  v_dados(v_dados.last()).vr_vllanmto := 24.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99012359;
  v_dados(v_dados.last()).vr_nrctremp := 359973;
  v_dados(v_dados.last()).vr_vllanmto := 4963.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83698736;
  v_dados(v_dados.last()).vr_nrctremp := 326663;
  v_dados(v_dados.last()).vr_vllanmto := 212.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83698736;
  v_dados(v_dados.last()).vr_nrctremp := 396174;
  v_dados(v_dados.last()).vr_vllanmto := 15.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83391436;
  v_dados(v_dados.last()).vr_nrctremp := 424620;
  v_dados(v_dados.last()).vr_vllanmto := 16.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82846936;
  v_dados(v_dados.last()).vr_nrctremp := 358837;
  v_dados(v_dados.last()).vr_vllanmto := 22.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82342636;
  v_dados(v_dados.last()).vr_nrctremp := 384601;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82258635;
  v_dados(v_dados.last()).vr_nrctremp := 389071;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81359535;
  v_dados(v_dados.last()).vr_nrctremp := 442116;
  v_dados(v_dados.last()).vr_vllanmto := 32.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 98980734;
  v_dados(v_dados.last()).vr_nrctremp := 369887;
  v_dados(v_dados.last()).vr_vllanmto := 15.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 98979973;
  v_dados(v_dados.last()).vr_nrctremp := 422978;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 98972618;
  v_dados(v_dados.last()).vr_nrctremp := 433538;
  v_dados(v_dados.last()).vr_vllanmto := 13.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 86000772;
  v_dados(v_dados.last()).vr_nrctremp := 357395;
  v_dados(v_dados.last()).vr_vllanmto := 17.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85959472;
  v_dados(v_dados.last()).vr_nrctremp := 320381;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85909050;
  v_dados(v_dados.last()).vr_nrctremp := 199550;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85909050;
  v_dados(v_dados.last()).vr_nrctremp := 290499;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85909050;
  v_dados(v_dados.last()).vr_nrctremp := 356668;
  v_dados(v_dados.last()).vr_vllanmto := 52.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85896764;
  v_dados(v_dados.last()).vr_nrctremp := 197303;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85759791;
  v_dados(v_dados.last()).vr_nrctremp := 381166;
  v_dados(v_dados.last()).vr_vllanmto := 6259.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85707180;
  v_dados(v_dados.last()).vr_nrctremp := 372611;
  v_dados(v_dados.last()).vr_vllanmto := 13.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85707180;
  v_dados(v_dados.last()).vr_nrctremp := 395358;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85681482;
  v_dados(v_dados.last()).vr_nrctremp := 370081;
  v_dados(v_dados.last()).vr_vllanmto := 21.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85178080;
  v_dados(v_dados.last()).vr_nrctremp := 306862;
  v_dados(v_dados.last()).vr_vllanmto := 12.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85097896;
  v_dados(v_dados.last()).vr_nrctremp := 304761;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85051349;
  v_dados(v_dados.last()).vr_nrctremp := 316695;
  v_dados(v_dados.last()).vr_vllanmto := 11.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 85031755;
  v_dados(v_dados.last()).vr_nrctremp := 274419;
  v_dados(v_dados.last()).vr_vllanmto := 19.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84909994;
  v_dados(v_dados.last()).vr_nrctremp := 256236;
  v_dados(v_dados.last()).vr_vllanmto := 22.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84909994;
  v_dados(v_dados.last()).vr_nrctremp := 301181;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84885777;
  v_dados(v_dados.last()).vr_nrctremp := 301193;
  v_dados(v_dados.last()).vr_vllanmto := 15.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84871148;
  v_dados(v_dados.last()).vr_nrctremp := 398471;
  v_dados(v_dados.last()).vr_vllanmto := 20.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84840161;
  v_dados(v_dados.last()).vr_nrctremp := 397977;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84782404;
  v_dados(v_dados.last()).vr_nrctremp := 370620;
  v_dados(v_dados.last()).vr_vllanmto := 20.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84707470;
  v_dados(v_dados.last()).vr_nrctremp := 417795;
  v_dados(v_dados.last()).vr_vllanmto := 52.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84704667;
  v_dados(v_dados.last()).vr_nrctremp := 402086;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84683813;
  v_dados(v_dados.last()).vr_nrctremp := 318693;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84683201;
  v_dados(v_dados.last()).vr_nrctremp := 317120;
  v_dados(v_dados.last()).vr_vllanmto := 3279.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84682477;
  v_dados(v_dados.last()).vr_nrctremp := 328523;
  v_dados(v_dados.last()).vr_vllanmto := 38.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84678690;
  v_dados(v_dados.last()).vr_nrctremp := 418711;
  v_dados(v_dados.last()).vr_vllanmto := 15.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84664673;
  v_dados(v_dados.last()).vr_nrctremp := 345016;
  v_dados(v_dados.last()).vr_vllanmto := 12.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84664673;
  v_dados(v_dados.last()).vr_nrctremp := 394030;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84583622;
  v_dados(v_dados.last()).vr_nrctremp := 269786;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84507390;
  v_dados(v_dados.last()).vr_nrctremp := 441922;
  v_dados(v_dados.last()).vr_vllanmto := 23.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84438665;
  v_dados(v_dados.last()).vr_nrctremp := 277190;
  v_dados(v_dados.last()).vr_vllanmto := 10.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84438665;
  v_dados(v_dados.last()).vr_nrctremp := 281591;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84325178;
  v_dados(v_dados.last()).vr_nrctremp := 353427;
  v_dados(v_dados.last()).vr_vllanmto := 15.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84284641;
  v_dados(v_dados.last()).vr_nrctremp := 321102;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84147091;
  v_dados(v_dados.last()).vr_nrctremp := 326444;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84121130;
  v_dados(v_dados.last()).vr_nrctremp := 295261;
  v_dados(v_dados.last()).vr_vllanmto := 13.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84115467;
  v_dados(v_dados.last()).vr_nrctremp := 304703;
  v_dados(v_dados.last()).vr_vllanmto := 31.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84063475;
  v_dados(v_dados.last()).vr_nrctremp := 300274;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84036761;
  v_dados(v_dados.last()).vr_nrctremp := 300118;
  v_dados(v_dados.last()).vr_vllanmto := 11.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84033215;
  v_dados(v_dados.last()).vr_nrctremp := 300141;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 84022639;
  v_dados(v_dados.last()).vr_nrctremp := 300448;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83984828;
  v_dados(v_dados.last()).vr_nrctremp := 335393;
  v_dados(v_dados.last()).vr_vllanmto := 15.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83981241;
  v_dados(v_dados.last()).vr_nrctremp := 303062;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83954775;
  v_dados(v_dados.last()).vr_nrctremp := 310680;
  v_dados(v_dados.last()).vr_vllanmto := 19.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83948023;
  v_dados(v_dados.last()).vr_nrctremp := 420181;
  v_dados(v_dados.last()).vr_vllanmto := 60.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83939296;
  v_dados(v_dados.last()).vr_nrctremp := 312606;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83912371;
  v_dados(v_dados.last()).vr_nrctremp := 312066;
  v_dados(v_dados.last()).vr_vllanmto := 12235.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83903410;
  v_dados(v_dados.last()).vr_nrctremp := 308323;
  v_dados(v_dados.last()).vr_vllanmto := 17.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83899782;
  v_dados(v_dados.last()).vr_nrctremp := 307918;
  v_dados(v_dados.last()).vr_vllanmto := 21.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83887954;
  v_dados(v_dados.last()).vr_nrctremp := 419529;
  v_dados(v_dados.last()).vr_vllanmto := 28.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83887350;
  v_dados(v_dados.last()).vr_nrctremp := 311955;
  v_dados(v_dados.last()).vr_vllanmto := 15.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83874267;
  v_dados(v_dados.last()).vr_nrctremp := 309197;
  v_dados(v_dados.last()).vr_vllanmto := 4409.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83862390;
  v_dados(v_dados.last()).vr_nrctremp := 438198;
  v_dados(v_dados.last()).vr_vllanmto := 47.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83860347;
  v_dados(v_dados.last()).vr_nrctremp := 309414;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83854800;
  v_dados(v_dados.last()).vr_nrctremp := 309667;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83847073;
  v_dados(v_dados.last()).vr_nrctremp := 310012;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83844791;
  v_dados(v_dados.last()).vr_nrctremp := 310112;
  v_dados(v_dados.last()).vr_vllanmto := 17.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83839968;
  v_dados(v_dados.last()).vr_nrctremp := 310331;
  v_dados(v_dados.last()).vr_vllanmto := 13.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83835644;
  v_dados(v_dados.last()).vr_nrctremp := 310722;
  v_dados(v_dados.last()).vr_vllanmto := 20.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83829296;
  v_dados(v_dados.last()).vr_nrctremp := 310696;
  v_dados(v_dados.last()).vr_vllanmto := 23.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83827790;
  v_dados(v_dados.last()).vr_nrctremp := 433348;
  v_dados(v_dados.last()).vr_vllanmto := 19.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83819061;
  v_dados(v_dados.last()).vr_nrctremp := 311317;
  v_dados(v_dados.last()).vr_vllanmto := 23.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83804250;
  v_dados(v_dados.last()).vr_nrctremp := 437230;
  v_dados(v_dados.last()).vr_vllanmto := 27.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83803955;
  v_dados(v_dados.last()).vr_nrctremp := 312163;
  v_dados(v_dados.last()).vr_vllanmto := 22.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83803491;
  v_dados(v_dados.last()).vr_nrctremp := 435795;
  v_dados(v_dados.last()).vr_vllanmto := 11.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83799575;
  v_dados(v_dados.last()).vr_nrctremp := 375365;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83789820;
  v_dados(v_dados.last()).vr_nrctremp := 312722;
  v_dados(v_dados.last()).vr_vllanmto := 18.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83769625;
  v_dados(v_dados.last()).vr_nrctremp := 313803;
  v_dados(v_dados.last()).vr_vllanmto := 23.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83768181;
  v_dados(v_dados.last()).vr_nrctremp := 313821;
  v_dados(v_dados.last()).vr_vllanmto := 29.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83761659;
  v_dados(v_dados.last()).vr_nrctremp := 314032;
  v_dados(v_dados.last()).vr_vllanmto := 48.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83737731;
  v_dados(v_dados.last()).vr_nrctremp := 315124;
  v_dados(v_dados.last()).vr_vllanmto := 21.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83737359;
  v_dados(v_dados.last()).vr_nrctremp := 429101;
  v_dados(v_dados.last()).vr_vllanmto := 43.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83736310;
  v_dados(v_dados.last()).vr_nrctremp := 315121;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83733957;
  v_dados(v_dados.last()).vr_nrctremp := 315190;
  v_dados(v_dados.last()).vr_vllanmto := 139.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83716947;
  v_dados(v_dados.last()).vr_nrctremp := 316148;
  v_dados(v_dados.last()).vr_vllanmto := 19.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83715681;
  v_dados(v_dados.last()).vr_nrctremp := 316174;
  v_dados(v_dados.last()).vr_vllanmto := 18.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83715452;
  v_dados(v_dados.last()).vr_nrctremp := 360629;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83712895;
  v_dados(v_dados.last()).vr_nrctremp := 316373;
  v_dados(v_dados.last()).vr_vllanmto := 19.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83710663;
  v_dados(v_dados.last()).vr_nrctremp := 316440;
  v_dados(v_dados.last()).vr_vllanmto := 14.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83705716;
  v_dados(v_dados.last()).vr_nrctremp := 316675;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83702865;
  v_dados(v_dados.last()).vr_nrctremp := 316738;
  v_dados(v_dados.last()).vr_vllanmto := 10.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83698531;
  v_dados(v_dados.last()).vr_nrctremp := 399503;
  v_dados(v_dados.last()).vr_vllanmto := 14.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83698256;
  v_dados(v_dados.last()).vr_nrctremp := 404161;
  v_dados(v_dados.last()).vr_vllanmto := 14.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83692649;
  v_dados(v_dados.last()).vr_nrctremp := 329190;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83691154;
  v_dados(v_dados.last()).vr_nrctremp := 318661;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83686380;
  v_dados(v_dados.last()).vr_nrctremp := 318061;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83686320;
  v_dados(v_dados.last()).vr_nrctremp := 357284;
  v_dados(v_dados.last()).vr_vllanmto := 21.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83679898;
  v_dados(v_dados.last()).vr_nrctremp := 319906;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83649174;
  v_dados(v_dados.last()).vr_nrctremp := 320034;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83635645;
  v_dados(v_dados.last()).vr_nrctremp := 322722;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83631720;
  v_dados(v_dados.last()).vr_nrctremp := 436150;
  v_dados(v_dados.last()).vr_vllanmto := 29.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83631550;
  v_dados(v_dados.last()).vr_nrctremp := 320759;
  v_dados(v_dados.last()).vr_vllanmto := 17.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83627367;
  v_dados(v_dados.last()).vr_nrctremp := 320966;
  v_dados(v_dados.last()).vr_vllanmto := 20.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83621920;
  v_dados(v_dados.last()).vr_nrctremp := 321869;
  v_dados(v_dados.last()).vr_vllanmto := 29.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83619356;
  v_dados(v_dados.last()).vr_nrctremp := 323260;
  v_dados(v_dados.last()).vr_vllanmto := 21.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83611649;
  v_dados(v_dados.last()).vr_nrctremp := 321725;
  v_dados(v_dados.last()).vr_vllanmto := 19.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83602267;
  v_dados(v_dados.last()).vr_nrctremp := 350572;
  v_dados(v_dados.last()).vr_vllanmto := 14.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83602127;
  v_dados(v_dados.last()).vr_nrctremp := 322133;
  v_dados(v_dados.last()).vr_vllanmto := 50.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83597964;
  v_dados(v_dados.last()).vr_nrctremp := 322295;
  v_dados(v_dados.last()).vr_vllanmto := 10.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83597050;
  v_dados(v_dados.last()).vr_nrctremp := 322326;
  v_dados(v_dados.last()).vr_vllanmto := 29.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83594485;
  v_dados(v_dados.last()).vr_nrctremp := 322661;
  v_dados(v_dados.last()).vr_vllanmto := 30.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83594485;
  v_dados(v_dados.last()).vr_nrctremp := 392511;
  v_dados(v_dados.last()).vr_vllanmto := 21.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83591710;
  v_dados(v_dados.last()).vr_nrctremp := 326771;
  v_dados(v_dados.last()).vr_vllanmto := 35.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83586849;
  v_dados(v_dados.last()).vr_nrctremp := 323794;
  v_dados(v_dados.last()).vr_vllanmto := 24.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83576487;
  v_dados(v_dados.last()).vr_nrctremp := 323182;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83555684;
  v_dados(v_dados.last()).vr_nrctremp := 324902;
  v_dados(v_dados.last()).vr_vllanmto := 392.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83543260;
  v_dados(v_dados.last()).vr_nrctremp := 324786;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83542124;
  v_dados(v_dados.last()).vr_nrctremp := 333386;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83529950;
  v_dados(v_dados.last()).vr_nrctremp := 325325;
  v_dados(v_dados.last()).vr_vllanmto := 22.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83519025;
  v_dados(v_dados.last()).vr_nrctremp := 439592;
  v_dados(v_dados.last()).vr_vllanmto := 48.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83511148;
  v_dados(v_dados.last()).vr_nrctremp := 326467;
  v_dados(v_dados.last()).vr_vllanmto := 25.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83508597;
  v_dados(v_dados.last()).vr_nrctremp := 326590;
  v_dados(v_dados.last()).vr_vllanmto := 18.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83506519;
  v_dados(v_dados.last()).vr_nrctremp := 432915;
  v_dados(v_dados.last()).vr_vllanmto := 24.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83501070;
  v_dados(v_dados.last()).vr_nrctremp := 327684;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83495681;
  v_dados(v_dados.last()).vr_nrctremp := 327210;
  v_dados(v_dados.last()).vr_vllanmto := 25.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83494464;
  v_dados(v_dados.last()).vr_nrctremp := 327255;
  v_dados(v_dados.last()).vr_vllanmto := 39.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83481818;
  v_dados(v_dados.last()).vr_nrctremp := 431961;
  v_dados(v_dados.last()).vr_vllanmto := 38.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83460810;
  v_dados(v_dados.last()).vr_nrctremp := 441614;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83452451;
  v_dados(v_dados.last()).vr_nrctremp := 329243;
  v_dados(v_dados.last()).vr_vllanmto := 12.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83450203;
  v_dados(v_dados.last()).vr_nrctremp := 329379;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83448080;
  v_dados(v_dados.last()).vr_nrctremp := 429496;
  v_dados(v_dados.last()).vr_vllanmto := 32612.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83426388;
  v_dados(v_dados.last()).vr_nrctremp := 330687;
  v_dados(v_dados.last()).vr_vllanmto := 34.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83426019;
  v_dados(v_dados.last()).vr_nrctremp := 330678;
  v_dados(v_dados.last()).vr_vllanmto := 21.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83419993;
  v_dados(v_dados.last()).vr_nrctremp := 331638;
  v_dados(v_dados.last()).vr_vllanmto := 13.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83417699;
  v_dados(v_dados.last()).vr_nrctremp := 420742;
  v_dados(v_dados.last()).vr_vllanmto := 29.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83401539;
  v_dados(v_dados.last()).vr_nrctremp := 331616;
  v_dados(v_dados.last()).vr_vllanmto := 18.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83390553;
  v_dados(v_dados.last()).vr_nrctremp := 332548;
  v_dados(v_dados.last()).vr_vllanmto := 1518.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83387609;
  v_dados(v_dados.last()).vr_nrctremp := 332687;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83387226;
  v_dados(v_dados.last()).vr_nrctremp := 333270;
  v_dados(v_dados.last()).vr_vllanmto := 10.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83376364;
  v_dados(v_dados.last()).vr_nrctremp := 424025;
  v_dados(v_dados.last()).vr_vllanmto := 27.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83373543;
  v_dados(v_dados.last()).vr_nrctremp := 333436;
  v_dados(v_dados.last()).vr_vllanmto := 17.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83373217;
  v_dados(v_dados.last()).vr_nrctremp := 429208;
  v_dados(v_dados.last()).vr_vllanmto := 18.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83355847;
  v_dados(v_dados.last()).vr_nrctremp := 334323;
  v_dados(v_dados.last()).vr_vllanmto := 17.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99501880;
  v_dados(v_dados.last()).vr_nrctremp := 340569;
  v_dados(v_dados.last()).vr_vllanmto := 553.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 99350572;
  v_dados(v_dados.last()).vr_nrctremp := 352742;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83361936;
  v_dados(v_dados.last()).vr_nrctremp := 344337;
  v_dados(v_dados.last()).vr_vllanmto := 26.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83335935;
  v_dados(v_dados.last()).vr_nrctremp := 377978;
  v_dados(v_dados.last()).vr_vllanmto := 26.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83368604;
  v_dados(v_dados.last()).vr_nrctremp := 377813;
  v_dados(v_dados.last()).vr_vllanmto := 40.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83364196;
  v_dados(v_dados.last()).vr_nrctremp := 333757;
  v_dados(v_dados.last()).vr_vllanmto := 1832.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83357416;
  v_dados(v_dados.last()).vr_nrctremp := 334276;
  v_dados(v_dados.last()).vr_vllanmto := 18.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83343598;
  v_dados(v_dados.last()).vr_nrctremp := 334965;
  v_dados(v_dados.last()).vr_vllanmto := 17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83339230;
  v_dados(v_dados.last()).vr_nrctremp := 335113;
  v_dados(v_dados.last()).vr_vllanmto := 20.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83335811;
  v_dados(v_dados.last()).vr_nrctremp := 335217;
  v_dados(v_dados.last()).vr_vllanmto := 20.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83335668;
  v_dados(v_dados.last()).vr_nrctremp := 420189;
  v_dados(v_dados.last()).vr_vllanmto := 15.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83335382;
  v_dados(v_dados.last()).vr_nrctremp := 335232;
  v_dados(v_dados.last()).vr_vllanmto := 25.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83331328;
  v_dados(v_dados.last()).vr_nrctremp := 335421;
  v_dados(v_dados.last()).vr_vllanmto := 70064.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83301461;
  v_dados(v_dados.last()).vr_nrctremp := 337370;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83322957;
  v_dados(v_dados.last()).vr_nrctremp := 344388;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83314717;
  v_dados(v_dados.last()).vr_nrctremp := 336421;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83314709;
  v_dados(v_dados.last()).vr_nrctremp := 336418;
  v_dados(v_dados.last()).vr_vllanmto := 14.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83301275;
  v_dados(v_dados.last()).vr_nrctremp := 337267;
  v_dados(v_dados.last()).vr_vllanmto := 37602.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83290320;
  v_dados(v_dados.last()).vr_nrctremp := 341925;
  v_dados(v_dados.last()).vr_vllanmto := 616.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83277706;
  v_dados(v_dados.last()).vr_nrctremp := 338532;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83272917;
  v_dados(v_dados.last()).vr_nrctremp := 339072;
  v_dados(v_dados.last()).vr_vllanmto := 44427.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83270019;
  v_dados(v_dados.last()).vr_nrctremp := 374488;
  v_dados(v_dados.last()).vr_vllanmto := 21.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83270019;
  v_dados(v_dados.last()).vr_nrctremp := 383383;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83260056;
  v_dados(v_dados.last()).vr_nrctremp := 339291;
  v_dados(v_dados.last()).vr_vllanmto := 26.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83258540;
  v_dados(v_dados.last()).vr_nrctremp := 339527;
  v_dados(v_dados.last()).vr_vllanmto := 15.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83256962;
  v_dados(v_dados.last()).vr_nrctremp := 351524;
  v_dados(v_dados.last()).vr_vllanmto := 26.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83255346;
  v_dados(v_dados.last()).vr_nrctremp := 376479;
  v_dados(v_dados.last()).vr_vllanmto := 56.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83253971;
  v_dados(v_dados.last()).vr_nrctremp := 339590;
  v_dados(v_dados.last()).vr_vllanmto := 966.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83253416;
  v_dados(v_dados.last()).vr_nrctremp := 339602;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83253106;
  v_dados(v_dados.last()).vr_nrctremp := 339605;
  v_dados(v_dados.last()).vr_vllanmto := 24.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83252797;
  v_dados(v_dados.last()).vr_nrctremp := 441957;
  v_dados(v_dados.last()).vr_vllanmto := 26.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83251855;
  v_dados(v_dados.last()).vr_nrctremp := 339586;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83242376;
  v_dados(v_dados.last()).vr_nrctremp := 391062;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83242058;
  v_dados(v_dados.last()).vr_nrctremp := 413569;
  v_dados(v_dados.last()).vr_vllanmto := 11.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83225269;
  v_dados(v_dados.last()).vr_nrctremp := 393690;
  v_dados(v_dados.last()).vr_vllanmto := 17.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83221786;
  v_dados(v_dados.last()).vr_nrctremp := 344900;
  v_dados(v_dados.last()).vr_vllanmto := 13.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83217959;
  v_dados(v_dados.last()).vr_nrctremp := 400150;
  v_dados(v_dados.last()).vr_vllanmto := 11.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83217959;
  v_dados(v_dados.last()).vr_nrctremp := 401459;
  v_dados(v_dados.last()).vr_vllanmto := 29.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83217959;
  v_dados(v_dados.last()).vr_nrctremp := 401460;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83213325;
  v_dados(v_dados.last()).vr_nrctremp := 348862;
  v_dados(v_dados.last()).vr_vllanmto := 34.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83176683;
  v_dados(v_dados.last()).vr_nrctremp := 344780;
  v_dados(v_dados.last()).vr_vllanmto := 24.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83159142;
  v_dados(v_dados.last()).vr_nrctremp := 354644;
  v_dados(v_dados.last()).vr_vllanmto := 40.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83159142;
  v_dados(v_dados.last()).vr_nrctremp := 357776;
  v_dados(v_dados.last()).vr_vllanmto := 14.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83150889;
  v_dados(v_dados.last()).vr_nrctremp := 374273;
  v_dados(v_dados.last()).vr_vllanmto := 13.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83150889;
  v_dados(v_dados.last()).vr_nrctremp := 424951;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83146792;
  v_dados(v_dados.last()).vr_nrctremp := 344791;
  v_dados(v_dados.last()).vr_vllanmto := 29.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83129510;
  v_dados(v_dados.last()).vr_nrctremp := 420211;
  v_dados(v_dados.last()).vr_vllanmto := 11.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83107827;
  v_dados(v_dados.last()).vr_nrctremp := 348669;
  v_dados(v_dados.last()).vr_vllanmto := 10.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83098518;
  v_dados(v_dados.last()).vr_nrctremp := 347163;
  v_dados(v_dados.last()).vr_vllanmto := 189.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83079858;
  v_dados(v_dados.last()).vr_nrctremp := 439450;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83063676;
  v_dados(v_dados.last()).vr_nrctremp := 423976;
  v_dados(v_dados.last()).vr_vllanmto := 22.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83052054;
  v_dados(v_dados.last()).vr_nrctremp := 349223;
  v_dados(v_dados.last()).vr_vllanmto := 23.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83051040;
  v_dados(v_dados.last()).vr_nrctremp := 349473;
  v_dados(v_dados.last()).vr_vllanmto := 21.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 83027920;
  v_dados(v_dados.last()).vr_nrctremp := 351678;
  v_dados(v_dados.last()).vr_vllanmto := 11.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82939446;
  v_dados(v_dados.last()).vr_nrctremp := 369457;
  v_dados(v_dados.last()).vr_vllanmto := 20.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82935050;
  v_dados(v_dados.last()).vr_nrctremp := 354841;
  v_dados(v_dados.last()).vr_vllanmto := 37.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82927677;
  v_dados(v_dados.last()).vr_nrctremp := 421611;
  v_dados(v_dados.last()).vr_vllanmto := 16.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82916390;
  v_dados(v_dados.last()).vr_nrctremp := 355468;
  v_dados(v_dados.last()).vr_vllanmto := 16.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82910634;
  v_dados(v_dados.last()).vr_nrctremp := 388110;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82900124;
  v_dados(v_dados.last()).vr_nrctremp := 368275;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82899460;
  v_dados(v_dados.last()).vr_nrctremp := 409463;
  v_dados(v_dados.last()).vr_vllanmto := 16.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82889597;
  v_dados(v_dados.last()).vr_nrctremp := 356926;
  v_dados(v_dados.last()).vr_vllanmto := 18.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82873046;
  v_dados(v_dados.last()).vr_nrctremp := 357846;
  v_dados(v_dados.last()).vr_vllanmto := 28.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82863210;
  v_dados(v_dados.last()).vr_nrctremp := 358179;
  v_dados(v_dados.last()).vr_vllanmto := 28.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82853169;
  v_dados(v_dados.last()).vr_nrctremp := 358932;
  v_dados(v_dados.last()).vr_vllanmto := 10.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82851433;
  v_dados(v_dados.last()).vr_nrctremp := 424366;
  v_dados(v_dados.last()).vr_vllanmto := 128913.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82847100;
  v_dados(v_dados.last()).vr_nrctremp := 358958;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82846197;
  v_dados(v_dados.last()).vr_nrctremp := 379235;
  v_dados(v_dados.last()).vr_vllanmto := 40.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82846197;
  v_dados(v_dados.last()).vr_nrctremp := 379237;
  v_dados(v_dados.last()).vr_vllanmto := 10.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82846197;
  v_dados(v_dados.last()).vr_nrctremp := 400176;
  v_dados(v_dados.last()).vr_vllanmto := 14.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82796343;
  v_dados(v_dados.last()).vr_nrctremp := 361445;
  v_dados(v_dados.last()).vr_vllanmto := 10.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82793832;
  v_dados(v_dados.last()).vr_nrctremp := 361318;
  v_dados(v_dados.last()).vr_vllanmto := 818.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82761310;
  v_dados(v_dados.last()).vr_nrctremp := 362676;
  v_dados(v_dados.last()).vr_vllanmto := 20.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82746427;
  v_dados(v_dados.last()).vr_nrctremp := 381163;
  v_dados(v_dados.last()).vr_vllanmto := 39.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82738840;
  v_dados(v_dados.last()).vr_nrctremp := 364338;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82733325;
  v_dados(v_dados.last()).vr_nrctremp := 364219;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82714061;
  v_dados(v_dados.last()).vr_nrctremp := 371812;
  v_dados(v_dados.last()).vr_vllanmto := 28.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82709270;
  v_dados(v_dados.last()).vr_nrctremp := 366149;
  v_dados(v_dados.last()).vr_vllanmto := 13.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82709270;
  v_dados(v_dados.last()).vr_nrctremp := 384084;
  v_dados(v_dados.last()).vr_vllanmto := 23.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82706700;
  v_dados(v_dados.last()).vr_nrctremp := 365561;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82696250;
  v_dados(v_dados.last()).vr_nrctremp := 413728;
  v_dados(v_dados.last()).vr_vllanmto := 45.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82690910;
  v_dados(v_dados.last()).vr_nrctremp := 366254;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82675279;
  v_dados(v_dados.last()).vr_nrctremp := 383058;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82674159;
  v_dados(v_dados.last()).vr_nrctremp := 386322;
  v_dados(v_dados.last()).vr_vllanmto := 40.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82670358;
  v_dados(v_dados.last()).vr_nrctremp := 367495;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82669570;
  v_dados(v_dados.last()).vr_nrctremp := 367665;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82666512;
  v_dados(v_dados.last()).vr_nrctremp := 367603;
  v_dados(v_dados.last()).vr_vllanmto := 23.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82634726;
  v_dados(v_dados.last()).vr_nrctremp := 368994;
  v_dados(v_dados.last()).vr_vllanmto := 18.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82622124;
  v_dados(v_dados.last()).vr_nrctremp := 370402;
  v_dados(v_dados.last()).vr_vllanmto := 1356.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82602301;
  v_dados(v_dados.last()).vr_nrctremp := 379458;
  v_dados(v_dados.last()).vr_vllanmto := 16.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82595771;
  v_dados(v_dados.last()).vr_nrctremp := 422701;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82583773;
  v_dados(v_dados.last()).vr_nrctremp := 375893;
  v_dados(v_dados.last()).vr_vllanmto := 41.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82578605;
  v_dados(v_dados.last()).vr_nrctremp := 371849;
  v_dados(v_dados.last()).vr_vllanmto := 23.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82547521;
  v_dados(v_dados.last()).vr_nrctremp := 373572;
  v_dados(v_dados.last()).vr_vllanmto := 14.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82535906;
  v_dados(v_dados.last()).vr_nrctremp := 426651;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82525242;
  v_dados(v_dados.last()).vr_nrctremp := 374975;
  v_dados(v_dados.last()).vr_vllanmto := 25.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82521557;
  v_dados(v_dados.last()).vr_nrctremp := 374827;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82521417;
  v_dados(v_dados.last()).vr_nrctremp := 429459;
  v_dados(v_dados.last()).vr_vllanmto := 36.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82518874;
  v_dados(v_dados.last()).vr_nrctremp := 382063;
  v_dados(v_dados.last()).vr_vllanmto := 12.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82511977;
  v_dados(v_dados.last()).vr_nrctremp := 433280;
  v_dados(v_dados.last()).vr_vllanmto := 13.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82505772;
  v_dados(v_dados.last()).vr_nrctremp := 375883;
  v_dados(v_dados.last()).vr_vllanmto := 15.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82464189;
  v_dados(v_dados.last()).vr_nrctremp := 380712;
  v_dados(v_dados.last()).vr_vllanmto := 48.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82460825;
  v_dados(v_dados.last()).vr_nrctremp := 378482;
  v_dados(v_dados.last()).vr_vllanmto := 51114.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82420629;
  v_dados(v_dados.last()).vr_nrctremp := 385664;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82414432;
  v_dados(v_dados.last()).vr_nrctremp := 380812;
  v_dados(v_dados.last()).vr_vllanmto := 96.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82406111;
  v_dados(v_dados.last()).vr_nrctremp := 382549;
  v_dados(v_dados.last()).vr_vllanmto := 499.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82394822;
  v_dados(v_dados.last()).vr_nrctremp := 381977;
  v_dados(v_dados.last()).vr_vllanmto := 25.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82394407;
  v_dados(v_dados.last()).vr_nrctremp := 381992;
  v_dados(v_dados.last()).vr_vllanmto := 20.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82368783;
  v_dados(v_dados.last()).vr_nrctremp := 387742;
  v_dados(v_dados.last()).vr_vllanmto := 15.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82365270;
  v_dados(v_dados.last()).vr_nrctremp := 383139;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82350078;
  v_dados(v_dados.last()).vr_nrctremp := 384036;
  v_dados(v_dados.last()).vr_vllanmto := 466.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82337365;
  v_dados(v_dados.last()).vr_nrctremp := 385127;
  v_dados(v_dados.last()).vr_vllanmto := 14.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82319502;
  v_dados(v_dados.last()).vr_nrctremp := 388552;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82304033;
  v_dados(v_dados.last()).vr_nrctremp := 434135;
  v_dados(v_dados.last()).vr_vllanmto := 13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82299900;
  v_dados(v_dados.last()).vr_nrctremp := 386948;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82292744;
  v_dados(v_dados.last()).vr_nrctremp := 400321;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82292744;
  v_dados(v_dados.last()).vr_nrctremp := 416091;
  v_dados(v_dados.last()).vr_vllanmto := 11.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82275408;
  v_dados(v_dados.last()).vr_nrctremp := 388639;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82265194;
  v_dados(v_dados.last()).vr_nrctremp := 388644;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82256730;
  v_dados(v_dados.last()).vr_nrctremp := 389024;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82253242;
  v_dados(v_dados.last()).vr_nrctremp := 408360;
  v_dados(v_dados.last()).vr_vllanmto := 39.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82248001;
  v_dados(v_dados.last()).vr_nrctremp := 389430;
  v_dados(v_dados.last()).vr_vllanmto := 45.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82247714;
  v_dados(v_dados.last()).vr_nrctremp := 389396;
  v_dados(v_dados.last()).vr_vllanmto := 55.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82241732;
  v_dados(v_dados.last()).vr_nrctremp := 390188;
  v_dados(v_dados.last()).vr_vllanmto := 29.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82240442;
  v_dados(v_dados.last()).vr_nrctremp := 390238;
  v_dados(v_dados.last()).vr_vllanmto := 515.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82240442;
  v_dados(v_dados.last()).vr_nrctremp := 390735;
  v_dados(v_dados.last()).vr_vllanmto := 12.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82205604;
  v_dados(v_dados.last()).vr_nrctremp := 419900;
  v_dados(v_dados.last()).vr_vllanmto := 22.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82185034;
  v_dados(v_dados.last()).vr_nrctremp := 393629;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82183457;
  v_dados(v_dados.last()).vr_nrctremp := 437498;
  v_dados(v_dados.last()).vr_vllanmto := 54.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82173079;
  v_dados(v_dados.last()).vr_nrctremp := 426169;
  v_dados(v_dados.last()).vr_vllanmto := 21.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82164363;
  v_dados(v_dados.last()).vr_nrctremp := 394131;
  v_dados(v_dados.last()).vr_vllanmto := 392.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82157880;
  v_dados(v_dados.last()).vr_nrctremp := 394532;
  v_dados(v_dados.last()).vr_vllanmto := 14.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82144257;
  v_dados(v_dados.last()).vr_nrctremp := 395361;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82112320;
  v_dados(v_dados.last()).vr_nrctremp := 400681;
  v_dados(v_dados.last()).vr_vllanmto := 41.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82069565;
  v_dados(v_dados.last()).vr_nrctremp := 401662;
  v_dados(v_dados.last()).vr_vllanmto := 15.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82067830;
  v_dados(v_dados.last()).vr_nrctremp := 398999;
  v_dados(v_dados.last()).vr_vllanmto := 12.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82040176;
  v_dados(v_dados.last()).vr_nrctremp := 400394;
  v_dados(v_dados.last()).vr_vllanmto := 144.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82014248;
  v_dados(v_dados.last()).vr_nrctremp := 401982;
  v_dados(v_dados.last()).vr_vllanmto := 272.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81991240;
  v_dados(v_dados.last()).vr_nrctremp := 403327;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81988419;
  v_dados(v_dados.last()).vr_nrctremp := 403442;
  v_dados(v_dados.last()).vr_vllanmto := 17.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81988419;
  v_dados(v_dados.last()).vr_nrctremp := 429852;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81978391;
  v_dados(v_dados.last()).vr_nrctremp := 404029;
  v_dados(v_dados.last()).vr_vllanmto := 12.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81953941;
  v_dados(v_dados.last()).vr_nrctremp := 405779;
  v_dados(v_dados.last()).vr_vllanmto := 14.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81948140;
  v_dados(v_dados.last()).vr_nrctremp := 406908;
  v_dados(v_dados.last()).vr_vllanmto := 54.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81855052;
  v_dados(v_dados.last()).vr_nrctremp := 411184;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81840179;
  v_dados(v_dados.last()).vr_nrctremp := 411749;
  v_dados(v_dados.last()).vr_vllanmto := 20.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81813147;
  v_dados(v_dados.last()).vr_nrctremp := 421008;
  v_dados(v_dados.last()).vr_vllanmto := 62.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81745460;
  v_dados(v_dados.last()).vr_nrctremp := 416629;
  v_dados(v_dados.last()).vr_vllanmto := 59.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81706367;
  v_dados(v_dados.last()).vr_nrctremp := 418618;
  v_dados(v_dados.last()).vr_vllanmto := 18.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81567740;
  v_dados(v_dados.last()).vr_nrctremp := 439568;
  v_dados(v_dados.last()).vr_vllanmto := 23.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81526849;
  v_dados(v_dados.last()).vr_nrctremp := 428377;
  v_dados(v_dados.last()).vr_vllanmto := 11.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81514310;
  v_dados(v_dados.last()).vr_nrctremp := 428303;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81503776;
  v_dados(v_dados.last()).vr_nrctremp := 431510;
  v_dados(v_dados.last()).vr_vllanmto := 24248.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81503776;
  v_dados(v_dados.last()).vr_nrctremp := 440944;
  v_dados(v_dados.last()).vr_vllanmto := 26366.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81487428;
  v_dados(v_dados.last()).vr_nrctremp := 429136;
  v_dados(v_dados.last()).vr_vllanmto := 30.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81480067;
  v_dados(v_dados.last()).vr_nrctremp := 429538;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81441355;
  v_dados(v_dados.last()).vr_nrctremp := 432076;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81431325;
  v_dados(v_dados.last()).vr_nrctremp := 432720;
  v_dados(v_dados.last()).vr_vllanmto := 23.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81424167;
  v_dados(v_dados.last()).vr_nrctremp := 433062;
  v_dados(v_dados.last()).vr_vllanmto := 10.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81421508;
  v_dados(v_dados.last()).vr_nrctremp := 433223;
  v_dados(v_dados.last()).vr_vllanmto := 20.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81420560;
  v_dados(v_dados.last()).vr_nrctremp := 433244;
  v_dados(v_dados.last()).vr_vllanmto := 28.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81360061;
  v_dados(v_dados.last()).vr_nrctremp := 441257;
  v_dados(v_dados.last()).vr_vllanmto := 36.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81317719;
  v_dados(v_dados.last()).vr_nrctremp := 439794;
  v_dados(v_dados.last()).vr_vllanmto := 26.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81303432;
  v_dados(v_dados.last()).vr_nrctremp := 439913;
  v_dados(v_dados.last()).vr_vllanmto := 22.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81287283;
  v_dados(v_dados.last()).vr_nrctremp := 440839;
  v_dados(v_dados.last()).vr_vllanmto := 19.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81267509;
  v_dados(v_dados.last()).vr_nrctremp := 441777;
  v_dados(v_dados.last()).vr_vllanmto := 19.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81254903;
  v_dados(v_dados.last()).vr_nrctremp := 442542;
  v_dados(v_dados.last()).vr_vllanmto := 10.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81249861;
  v_dados(v_dados.last()).vr_nrctremp := 442746;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81249179;
  v_dados(v_dados.last()).vr_nrctremp := 442770;
  v_dados(v_dados.last()).vr_vllanmto := 18.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81248270;
  v_dados(v_dados.last()).vr_nrctremp := 443319;
  v_dados(v_dados.last()).vr_vllanmto := 18.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 81238746;
  v_dados(v_dados.last()).vr_nrctremp := 443346;
  v_dados(v_dados.last()).vr_vllanmto := 18.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82942102;
  v_dados(v_dados.last()).vr_nrctremp := 354523;
  v_dados(v_dados.last()).vr_vllanmto := 19.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82958130;
  v_dados(v_dados.last()).vr_nrctremp := 389796;
  v_dados(v_dados.last()).vr_vllanmto := 21961.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 82955913;
  v_dados(v_dados.last()).vr_nrctremp := 432512;
  v_dados(v_dados.last()).vr_vllanmto := 22.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 99960451;
  v_dados(v_dados.last()).vr_nrctremp := 100056;
  v_dados(v_dados.last()).vr_vllanmto := 32.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 99803186;
  v_dados(v_dados.last()).vr_nrctremp := 72364;
  v_dados(v_dados.last()).vr_vllanmto := 234.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 99803186;
  v_dados(v_dados.last()).vr_nrctremp := 84017;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99999242;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 5046.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99996030;
  v_dados(v_dados.last()).vr_nrctremp := 300931;
  v_dados(v_dados.last()).vr_vllanmto := 1523.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99991713;
  v_dados(v_dados.last()).vr_nrctremp := 325976;
  v_dados(v_dados.last()).vr_vllanmto := 25.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99990580;
  v_dados(v_dados.last()).vr_nrctremp := 358996;
  v_dados(v_dados.last()).vr_vllanmto := 21.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99990458;
  v_dados(v_dados.last()).vr_nrctremp := 330466;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99933136;
  v_dados(v_dados.last()).vr_nrctremp := 356452;
  v_dados(v_dados.last()).vr_vllanmto := 15.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99859335;
  v_dados(v_dados.last()).vr_nrctremp := 269375;
  v_dados(v_dados.last()).vr_vllanmto := 14.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99828235;
  v_dados(v_dados.last()).vr_nrctremp := 324072;
  v_dados(v_dados.last()).vr_vllanmto := 11.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99744635;
  v_dados(v_dados.last()).vr_nrctremp := 57141;
  v_dados(v_dados.last()).vr_vllanmto := 18010.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99744635;
  v_dados(v_dados.last()).vr_nrctremp := 358083;
  v_dados(v_dados.last()).vr_vllanmto := 15.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99578735;
  v_dados(v_dados.last()).vr_nrctremp := 237821;
  v_dados(v_dados.last()).vr_vllanmto := 11.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99985322;
  v_dados(v_dados.last()).vr_nrctremp := 345704;
  v_dados(v_dados.last()).vr_vllanmto := 15.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99984482;
  v_dados(v_dados.last()).vr_nrctremp := 278607;
  v_dados(v_dados.last()).vr_vllanmto := 17.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99981750;
  v_dados(v_dados.last()).vr_nrctremp := 287995;
  v_dados(v_dados.last()).vr_vllanmto := 21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99977370;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 9428.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99976552;
  v_dados(v_dados.last()).vr_nrctremp := 359423;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99973340;
  v_dados(v_dados.last()).vr_nrctremp := 347599;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99973260;
  v_dados(v_dados.last()).vr_nrctremp := 342212;
  v_dados(v_dados.last()).vr_vllanmto := 14.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99968665;
  v_dados(v_dados.last()).vr_nrctremp := 162267;
  v_dados(v_dados.last()).vr_vllanmto := 17.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99968258;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 1316.99;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99967812;
  v_dados(v_dados.last()).vr_nrctremp := 296829;
  v_dados(v_dados.last()).vr_vllanmto := 39.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99966468;
  v_dados(v_dados.last()).vr_nrctremp := 327976;
  v_dados(v_dados.last()).vr_vllanmto := 10.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99964660;
  v_dados(v_dados.last()).vr_nrctremp := 175671;
  v_dados(v_dados.last()).vr_vllanmto := 25.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99964341;
  v_dados(v_dados.last()).vr_nrctremp := 303991;
  v_dados(v_dados.last()).vr_vllanmto := 502.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99955776;
  v_dados(v_dados.last()).vr_nrctremp := 218873;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99955539;
  v_dados(v_dados.last()).vr_nrctremp := 315258;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99955512;
  v_dados(v_dados.last()).vr_nrctremp := 325947;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99952670;
  v_dados(v_dados.last()).vr_nrctremp := 280688;
  v_dados(v_dados.last()).vr_vllanmto := 16.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99943786;
  v_dados(v_dados.last()).vr_nrctremp := 298112;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99941406;
  v_dados(v_dados.last()).vr_nrctremp := 349374;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99939282;
  v_dados(v_dados.last()).vr_nrctremp := 148221;
  v_dados(v_dados.last()).vr_vllanmto := 12.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99938189;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 3722.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99938170;
  v_dados(v_dados.last()).vr_nrctremp := 274745;
  v_dados(v_dados.last()).vr_vllanmto := 85.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99933330;
  v_dados(v_dados.last()).vr_nrctremp := 331690;
  v_dados(v_dados.last()).vr_vllanmto := 32781.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99933268;
  v_dados(v_dados.last()).vr_nrctremp := 294352;
  v_dados(v_dados.last()).vr_vllanmto := 11.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99933403;
  v_dados(v_dados.last()).vr_nrctremp := 238051;
  v_dados(v_dados.last()).vr_vllanmto := 12.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99933110;
  v_dados(v_dados.last()).vr_nrctremp := 284580;
  v_dados(v_dados.last()).vr_vllanmto := 11099.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99932679;
  v_dados(v_dados.last()).vr_nrctremp := 291731;
  v_dados(v_dados.last()).vr_vllanmto := 14.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99931320;
  v_dados(v_dados.last()).vr_nrctremp := 300883;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99929554;
  v_dados(v_dados.last()).vr_nrctremp := 315031;
  v_dados(v_dados.last()).vr_vllanmto := 11.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99929074;
  v_dados(v_dados.last()).vr_nrctremp := 353771;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99924803;
  v_dados(v_dados.last()).vr_nrctremp := 359021;
  v_dados(v_dados.last()).vr_vllanmto := 13.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99922975;
  v_dados(v_dados.last()).vr_nrctremp := 328737;
  v_dados(v_dados.last()).vr_vllanmto := 14.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99921219;
  v_dados(v_dados.last()).vr_nrctremp := 283429;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99921308;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 69.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99920492;
  v_dados(v_dados.last()).vr_nrctremp := 314754;
  v_dados(v_dados.last()).vr_vllanmto := 270.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99919680;
  v_dados(v_dados.last()).vr_nrctremp := 330113;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99919591;
  v_dados(v_dados.last()).vr_nrctremp := 351614;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99914379;
  v_dados(v_dados.last()).vr_nrctremp := 276706;
  v_dados(v_dados.last()).vr_vllanmto := 16.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99913810;
  v_dados(v_dados.last()).vr_nrctremp := 355878;
  v_dados(v_dados.last()).vr_vllanmto := 17.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99909570;
  v_dados(v_dados.last()).vr_nrctremp := 71345;
  v_dados(v_dados.last()).vr_vllanmto := 1361.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99908751;
  v_dados(v_dados.last()).vr_nrctremp := 298106;
  v_dados(v_dados.last()).vr_vllanmto := 27.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99907550;
  v_dados(v_dados.last()).vr_nrctremp := 316572;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99907526;
  v_dados(v_dados.last()).vr_nrctremp := 242872;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99906775;
  v_dados(v_dados.last()).vr_nrctremp := 305633;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99904799;
  v_dados(v_dados.last()).vr_nrctremp := 276915;
  v_dados(v_dados.last()).vr_vllanmto := 30.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99905205;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 1866.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99904209;
  v_dados(v_dados.last()).vr_nrctremp := 345745;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99903733;
  v_dados(v_dados.last()).vr_nrctremp := 349943;
  v_dados(v_dados.last()).vr_vllanmto := 18.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99898950;
  v_dados(v_dados.last()).vr_nrctremp := 351676;
  v_dados(v_dados.last()).vr_vllanmto := 29.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99898616;
  v_dados(v_dados.last()).vr_nrctremp := 325281;
  v_dados(v_dados.last()).vr_vllanmto := 12.53;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99896249;
  v_dados(v_dados.last()).vr_nrctremp := 302626;
  v_dados(v_dados.last()).vr_vllanmto := 13.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99896338;
  v_dados(v_dados.last()).vr_nrctremp := 314824;
  v_dados(v_dados.last()).vr_vllanmto := 14.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99894920;
  v_dados(v_dados.last()).vr_nrctremp := 261154;
  v_dados(v_dados.last()).vr_vllanmto := 20.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883406;
  v_dados(v_dados.last()).vr_nrctremp := 298187;
  v_dados(v_dados.last()).vr_vllanmto := 99.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883449;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 3190.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883406;
  v_dados(v_dados.last()).vr_nrctremp := 67611;
  v_dados(v_dados.last()).vr_vllanmto := 1602.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883406;
  v_dados(v_dados.last()).vr_nrctremp := 247445;
  v_dados(v_dados.last()).vr_vllanmto := 52.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99879328;
  v_dados(v_dados.last()).vr_nrctremp := 327711;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99874954;
  v_dados(v_dados.last()).vr_nrctremp := 348793;
  v_dados(v_dados.last()).vr_vllanmto := 36.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99871629;
  v_dados(v_dados.last()).vr_nrctremp := 262491;
  v_dados(v_dados.last()).vr_vllanmto := 24.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99871602;
  v_dados(v_dados.last()).vr_nrctremp := 174807;
  v_dados(v_dados.last()).vr_vllanmto := 3233.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99869012;
  v_dados(v_dados.last()).vr_nrctremp := 305091;
  v_dados(v_dados.last()).vr_vllanmto := 44207.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99868849;
  v_dados(v_dados.last()).vr_nrctremp := 264793;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99866897;
  v_dados(v_dados.last()).vr_nrctremp := 219930;
  v_dados(v_dados.last()).vr_vllanmto := 15.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99866889;
  v_dados(v_dados.last()).vr_nrctremp := 348846;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99865394;
  v_dados(v_dados.last()).vr_nrctremp := 302408;
  v_dados(v_dados.last()).vr_vllanmto := 15.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99863880;
  v_dados(v_dados.last()).vr_nrctremp := 168147;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99864126;
  v_dados(v_dados.last()).vr_nrctremp := 314531;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99862980;
  v_dados(v_dados.last()).vr_nrctremp := 115239;
  v_dados(v_dados.last()).vr_vllanmto := 41.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99862980;
  v_dados(v_dados.last()).vr_nrctremp := 261434;
  v_dados(v_dados.last()).vr_vllanmto := 12.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99862131;
  v_dados(v_dados.last()).vr_nrctremp := 252706;
  v_dados(v_dados.last()).vr_vllanmto := 11.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99861712;
  v_dados(v_dados.last()).vr_nrctremp := 204399;
  v_dados(v_dados.last()).vr_vllanmto := 1243.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99861739;
  v_dados(v_dados.last()).vr_nrctremp := 320510;
  v_dados(v_dados.last()).vr_vllanmto := 26.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99860430;
  v_dados(v_dados.last()).vr_nrctremp := 359480;
  v_dados(v_dados.last()).vr_vllanmto := 69.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99860910;
  v_dados(v_dados.last()).vr_nrctremp := 187057;
  v_dados(v_dados.last()).vr_vllanmto := 16.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99860910;
  v_dados(v_dados.last()).vr_nrctremp := 341948;
  v_dados(v_dados.last()).vr_vllanmto := 14.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99859777;
  v_dados(v_dados.last()).vr_nrctremp := 338901;
  v_dados(v_dados.last()).vr_vllanmto := 14.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858827;
  v_dados(v_dados.last()).vr_nrctremp := 274882;
  v_dados(v_dados.last()).vr_vllanmto := 13.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99859084;
  v_dados(v_dados.last()).vr_nrctremp := 165756;
  v_dados(v_dados.last()).vr_vllanmto := 13.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858827;
  v_dados(v_dados.last()).vr_nrctremp := 276901;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858827;
  v_dados(v_dados.last()).vr_nrctremp := 279765;
  v_dados(v_dados.last()).vr_vllanmto := 19.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858827;
  v_dados(v_dados.last()).vr_nrctremp := 283956;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858444;
  v_dados(v_dados.last()).vr_nrctremp := 255202;
  v_dados(v_dados.last()).vr_vllanmto := 1095.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99858304;
  v_dados(v_dados.last()).vr_nrctremp := 349917;
  v_dados(v_dados.last()).vr_vllanmto := 12.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99857375;
  v_dados(v_dados.last()).vr_nrctremp := 313991;
  v_dados(v_dados.last()).vr_vllanmto := 17.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99857960;
  v_dados(v_dados.last()).vr_nrctremp := 236257;
  v_dados(v_dados.last()).vr_vllanmto := 43.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99856646;
  v_dados(v_dados.last()).vr_nrctremp := 106135;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99857324;
  v_dados(v_dados.last()).vr_nrctremp := 348713;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99856573;
  v_dados(v_dados.last()).vr_nrctremp := 66735;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99856573;
  v_dados(v_dados.last()).vr_nrctremp := 91148;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99856573;
  v_dados(v_dados.last()).vr_nrctremp := 355010;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99856158;
  v_dados(v_dados.last()).vr_nrctremp := 212459;
  v_dados(v_dados.last()).vr_vllanmto := 19.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99855704;
  v_dados(v_dados.last()).vr_nrctremp := 86096;
  v_dados(v_dados.last()).vr_vllanmto := 22.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99855097;
  v_dados(v_dados.last()).vr_nrctremp := 313769;
  v_dados(v_dados.last()).vr_vllanmto := 17.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99855178;
  v_dados(v_dados.last()).vr_nrctremp := 313396;
  v_dados(v_dados.last()).vr_vllanmto := 36.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99854627;
  v_dados(v_dados.last()).vr_nrctremp := 333521;
  v_dados(v_dados.last()).vr_vllanmto := 26.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99854198;
  v_dados(v_dados.last()).vr_nrctremp := 269860;
  v_dados(v_dados.last()).vr_vllanmto := 12.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99854406;
  v_dados(v_dados.last()).vr_nrctremp := 235307;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99854309;
  v_dados(v_dados.last()).vr_nrctremp := 286829;
  v_dados(v_dados.last()).vr_vllanmto := 10.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99853922;
  v_dados(v_dados.last()).vr_nrctremp := 209282;
  v_dados(v_dados.last()).vr_vllanmto := 12.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99853914;
  v_dados(v_dados.last()).vr_nrctremp := 353519;
  v_dados(v_dados.last()).vr_vllanmto := 16.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99853310;
  v_dados(v_dados.last()).vr_nrctremp := 356035;
  v_dados(v_dados.last()).vr_vllanmto := 21.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99853566;
  v_dados(v_dados.last()).vr_nrctremp := 288598;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99852276;
  v_dados(v_dados.last()).vr_nrctremp := 191788;
  v_dados(v_dados.last()).vr_vllanmto := 13.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99852128;
  v_dados(v_dados.last()).vr_nrctremp := 332987;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99850400;
  v_dados(v_dados.last()).vr_nrctremp := 330867;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99850303;
  v_dados(v_dados.last()).vr_nrctremp := 273460;
  v_dados(v_dados.last()).vr_vllanmto := 19.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99849976;
  v_dados(v_dados.last()).vr_nrctremp := 316972;
  v_dados(v_dados.last()).vr_vllanmto := 44.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99850087;
  v_dados(v_dados.last()).vr_nrctremp := 244797;
  v_dados(v_dados.last()).vr_vllanmto := 31.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99849976;
  v_dados(v_dados.last()).vr_nrctremp := 332861;
  v_dados(v_dados.last()).vr_vllanmto := 32.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99849380;
  v_dados(v_dados.last()).vr_nrctremp := 146498;
  v_dados(v_dados.last()).vr_vllanmto := 16.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99849461;
  v_dados(v_dados.last()).vr_nrctremp := 275838;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99848970;
  v_dados(v_dados.last()).vr_nrctremp := 175748;
  v_dados(v_dados.last()).vr_vllanmto := 21.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99848546;
  v_dados(v_dados.last()).vr_nrctremp := 338752;
  v_dados(v_dados.last()).vr_vllanmto := 18.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99848821;
  v_dados(v_dados.last()).vr_nrctremp := 340928;
  v_dados(v_dados.last()).vr_vllanmto := 24.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99847477;
  v_dados(v_dados.last()).vr_nrctremp := 238102;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99846594;
  v_dados(v_dados.last()).vr_nrctremp := 253723;
  v_dados(v_dados.last()).vr_vllanmto := 14.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99847132;
  v_dados(v_dados.last()).vr_nrctremp := 321654;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99846594;
  v_dados(v_dados.last()).vr_nrctremp := 298812;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99846330;
  v_dados(v_dados.last()).vr_nrctremp := 335412;
  v_dados(v_dados.last()).vr_vllanmto := 17.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99846543;
  v_dados(v_dados.last()).vr_nrctremp := 135768;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99846543;
  v_dados(v_dados.last()).vr_nrctremp := 278865;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845865;
  v_dados(v_dados.last()).vr_nrctremp := 332665;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845423;
  v_dados(v_dados.last()).vr_nrctremp := 235865;
  v_dados(v_dados.last()).vr_vllanmto := 14.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845830;
  v_dados(v_dados.last()).vr_nrctremp := 332658;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845423;
  v_dados(v_dados.last()).vr_nrctremp := 257639;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845423;
  v_dados(v_dados.last()).vr_nrctremp := 345820;
  v_dados(v_dados.last()).vr_vllanmto := 21.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845415;
  v_dados(v_dados.last()).vr_nrctremp := 245701;
  v_dados(v_dados.last()).vr_vllanmto := 117.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99845210;
  v_dados(v_dados.last()).vr_nrctremp := 314592;
  v_dados(v_dados.last()).vr_vllanmto := 116.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99844753;
  v_dados(v_dados.last()).vr_nrctremp := 341233;
  v_dados(v_dados.last()).vr_vllanmto := 13.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99844338;
  v_dados(v_dados.last()).vr_nrctremp := 311610;
  v_dados(v_dados.last()).vr_vllanmto := 145.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99844311;
  v_dados(v_dados.last()).vr_nrctremp := 359215;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99843080;
  v_dados(v_dados.last()).vr_nrctremp := 197038;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99843668;
  v_dados(v_dados.last()).vr_nrctremp := 210406;
  v_dados(v_dados.last()).vr_vllanmto := 45.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99843250;
  v_dados(v_dados.last()).vr_nrctremp := 284309;
  v_dados(v_dados.last()).vr_vllanmto := 48.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99842653;
  v_dados(v_dados.last()).vr_nrctremp := 262694;
  v_dados(v_dados.last()).vr_vllanmto := 31.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99842106;
  v_dados(v_dados.last()).vr_nrctremp := 322396;
  v_dados(v_dados.last()).vr_vllanmto := 31.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99840820;
  v_dados(v_dados.last()).vr_nrctremp := 233853;
  v_dados(v_dados.last()).vr_vllanmto := 78.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99839628;
  v_dados(v_dados.last()).vr_nrctremp := 327746;
  v_dados(v_dados.last()).vr_vllanmto := 15.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99839628;
  v_dados(v_dados.last()).vr_nrctremp := 337210;
  v_dados(v_dados.last()).vr_vllanmto := 11.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99839296;
  v_dados(v_dados.last()).vr_nrctremp := 65833;
  v_dados(v_dados.last()).vr_vllanmto := 1880.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99839296;
  v_dados(v_dados.last()).vr_nrctremp := 188123;
  v_dados(v_dados.last()).vr_vllanmto := 43.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99839296;
  v_dados(v_dados.last()).vr_nrctremp := 279361;
  v_dados(v_dados.last()).vr_vllanmto := 20.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99838290;
  v_dados(v_dados.last()).vr_nrctremp := 335435;
  v_dados(v_dados.last()).vr_vllanmto := 38.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99838656;
  v_dados(v_dados.last()).vr_nrctremp := 313316;
  v_dados(v_dados.last()).vr_vllanmto := 38.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99836564;
  v_dados(v_dados.last()).vr_nrctremp := 264492;
  v_dados(v_dados.last()).vr_vllanmto := 14.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99836769;
  v_dados(v_dados.last()).vr_nrctremp := 314443;
  v_dados(v_dados.last()).vr_vllanmto := 29.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99836556;
  v_dados(v_dados.last()).vr_nrctremp := 199142;
  v_dados(v_dados.last()).vr_vllanmto := 27.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99836289;
  v_dados(v_dados.last()).vr_nrctremp := 266022;
  v_dados(v_dados.last()).vr_vllanmto := 10.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99836068;
  v_dados(v_dados.last()).vr_nrctremp := 110555;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99833263;
  v_dados(v_dados.last()).vr_nrctremp := 347588;
  v_dados(v_dados.last()).vr_vllanmto := 19.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99832747;
  v_dados(v_dados.last()).vr_nrctremp := 265127;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99832747;
  v_dados(v_dados.last()).vr_nrctremp := 292560;
  v_dados(v_dados.last()).vr_vllanmto := 19.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99832011;
  v_dados(v_dados.last()).vr_nrctremp := 175206;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99832445;
  v_dados(v_dados.last()).vr_nrctremp := 345754;
  v_dados(v_dados.last()).vr_vllanmto := 33.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99831740;
  v_dados(v_dados.last()).vr_nrctremp := 312546;
  v_dados(v_dados.last()).vr_vllanmto := 11.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99829843;
  v_dados(v_dados.last()).vr_nrctremp := 236919;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99829452;
  v_dados(v_dados.last()).vr_nrctremp := 252797;
  v_dados(v_dados.last()).vr_vllanmto := 2576.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99829630;
  v_dados(v_dados.last()).vr_nrctremp := 346993;
  v_dados(v_dados.last()).vr_vllanmto := 11.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99828014;
  v_dados(v_dados.last()).vr_nrctremp := 124332;
  v_dados(v_dados.last()).vr_vllanmto := 107.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99828111;
  v_dados(v_dados.last()).vr_nrctremp := 142019;
  v_dados(v_dados.last()).vr_vllanmto := 13.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99828014;
  v_dados(v_dados.last()).vr_nrctremp := 124334;
  v_dados(v_dados.last()).vr_vllanmto := 48.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827913;
  v_dados(v_dados.last()).vr_nrctremp := 301654;
  v_dados(v_dados.last()).vr_vllanmto := 33.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827751;
  v_dados(v_dados.last()).vr_nrctremp := 336431;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827514;
  v_dados(v_dados.last()).vr_nrctremp := 252268;
  v_dados(v_dados.last()).vr_vllanmto := 13.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827131;
  v_dados(v_dados.last()).vr_nrctremp := 325045;
  v_dados(v_dados.last()).vr_vllanmto := 29.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827492;
  v_dados(v_dados.last()).vr_nrctremp := 303281;
  v_dados(v_dados.last()).vr_vllanmto := 18.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827085;
  v_dados(v_dados.last()).vr_nrctremp := 329245;
  v_dados(v_dados.last()).vr_vllanmto := 24.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 273151;
  v_dados(v_dados.last()).vr_vllanmto := 55.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 230666;
  v_dados(v_dados.last()).vr_vllanmto := 175.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 248810;
  v_dados(v_dados.last()).vr_vllanmto := 45.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 254372;
  v_dados(v_dados.last()).vr_vllanmto := 2065.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 287913;
  v_dados(v_dados.last()).vr_vllanmto := 70.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 309165;
  v_dados(v_dados.last()).vr_vllanmto := 138.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99825902;
  v_dados(v_dados.last()).vr_nrctremp := 273104;
  v_dados(v_dados.last()).vr_vllanmto := 140.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99825074;
  v_dados(v_dados.last()).vr_nrctremp := 305367;
  v_dados(v_dados.last()).vr_vllanmto := 20.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99824485;
  v_dados(v_dados.last()).vr_nrctremp := 167766;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99824442;
  v_dados(v_dados.last()).vr_nrctremp := 295718;
  v_dados(v_dados.last()).vr_vllanmto := 20.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99822059;
  v_dados(v_dados.last()).vr_nrctremp := 242315;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99820013;
  v_dados(v_dados.last()).vr_nrctremp := 196857;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99818329;
  v_dados(v_dados.last()).vr_nrctremp := 286610;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99816911;
  v_dados(v_dados.last()).vr_nrctremp := 342862;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99816989;
  v_dados(v_dados.last()).vr_nrctremp := 101588;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99816113;
  v_dados(v_dados.last()).vr_nrctremp := 245338;
  v_dados(v_dados.last()).vr_vllanmto := 21.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815559;
  v_dados(v_dados.last()).vr_nrctremp := 299304;
  v_dados(v_dados.last()).vr_vllanmto := 96.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815591;
  v_dados(v_dados.last()).vr_nrctremp := 262671;
  v_dados(v_dados.last()).vr_vllanmto := 43.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815591;
  v_dados(v_dados.last()).vr_nrctremp := 302724;
  v_dados(v_dados.last()).vr_vllanmto := 134;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815559;
  v_dados(v_dados.last()).vr_nrctremp := 247626;
  v_dados(v_dados.last()).vr_vllanmto := 414.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815540;
  v_dados(v_dados.last()).vr_nrctremp := 286467;
  v_dados(v_dados.last()).vr_vllanmto := 190.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99815125;
  v_dados(v_dados.last()).vr_nrctremp := 302094;
  v_dados(v_dados.last()).vr_vllanmto := 53.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814455;
  v_dados(v_dados.last()).vr_nrctremp := 317939;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814668;
  v_dados(v_dados.last()).vr_nrctremp := 139153;
  v_dados(v_dados.last()).vr_vllanmto := 102.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814510;
  v_dados(v_dados.last()).vr_nrctremp := 242044;
  v_dados(v_dados.last()).vr_vllanmto := 38.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814110;
  v_dados(v_dados.last()).vr_nrctremp := 233245;
  v_dados(v_dados.last()).vr_vllanmto := 23.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814404;
  v_dados(v_dados.last()).vr_nrctremp := 205263;
  v_dados(v_dados.last()).vr_vllanmto := 1142.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814366;
  v_dados(v_dados.last()).vr_nrctremp := 286328;
  v_dados(v_dados.last()).vr_vllanmto := 350.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814110;
  v_dados(v_dados.last()).vr_nrctremp := 237814;
  v_dados(v_dados.last()).vr_vllanmto := 31.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814102;
  v_dados(v_dados.last()).vr_nrctremp := 264660;
  v_dados(v_dados.last()).vr_vllanmto := 105.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814005;
  v_dados(v_dados.last()).vr_nrctremp := 114018;
  v_dados(v_dados.last()).vr_vllanmto := 30.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814005;
  v_dados(v_dados.last()).vr_nrctremp := 130951;
  v_dados(v_dados.last()).vr_vllanmto := 21.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814005;
  v_dados(v_dados.last()).vr_nrctremp := 174443;
  v_dados(v_dados.last()).vr_vllanmto := 40.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814005;
  v_dados(v_dados.last()).vr_nrctremp := 283372;
  v_dados(v_dados.last()).vr_vllanmto := 23.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813980;
  v_dados(v_dados.last()).vr_nrctremp := 337321;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813955;
  v_dados(v_dados.last()).vr_nrctremp := 271143;
  v_dados(v_dados.last()).vr_vllanmto := 45.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813734;
  v_dados(v_dados.last()).vr_nrctremp := 68975;
  v_dados(v_dados.last()).vr_vllanmto := 96.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813742;
  v_dados(v_dados.last()).vr_nrctremp := 283202;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813696;
  v_dados(v_dados.last()).vr_nrctremp := 278887;
  v_dados(v_dados.last()).vr_vllanmto := 178.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813459;
  v_dados(v_dados.last()).vr_nrctremp := 296021;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813424;
  v_dados(v_dados.last()).vr_nrctremp := 90119;
  v_dados(v_dados.last()).vr_vllanmto := 49.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813190;
  v_dados(v_dados.last()).vr_nrctremp := 308515;
  v_dados(v_dados.last()).vr_vllanmto := 12912.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812797;
  v_dados(v_dados.last()).vr_nrctremp := 132407;
  v_dados(v_dados.last()).vr_vllanmto := 128.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813033;
  v_dados(v_dados.last()).vr_nrctremp := 92977;
  v_dados(v_dados.last()).vr_vllanmto := 154.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812797;
  v_dados(v_dados.last()).vr_nrctremp := 295344;
  v_dados(v_dados.last()).vr_vllanmto := 63.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812770;
  v_dados(v_dados.last()).vr_nrctremp := 244065;
  v_dados(v_dados.last()).vr_vllanmto := 34700.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812703;
  v_dados(v_dados.last()).vr_nrctremp := 285000;
  v_dados(v_dados.last()).vr_vllanmto := 45.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812568;
  v_dados(v_dados.last()).vr_nrctremp := 102721;
  v_dados(v_dados.last()).vr_vllanmto := 45.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812568;
  v_dados(v_dados.last()).vr_nrctremp := 287693;
  v_dados(v_dados.last()).vr_vllanmto := 97.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812517;
  v_dados(v_dados.last()).vr_nrctremp := 184919;
  v_dados(v_dados.last()).vr_vllanmto := 21.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812517;
  v_dados(v_dados.last()).vr_nrctremp := 274702;
  v_dados(v_dados.last()).vr_vllanmto := 22.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812045;
  v_dados(v_dados.last()).vr_nrctremp := 333099;
  v_dados(v_dados.last()).vr_vllanmto := 32.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812320;
  v_dados(v_dados.last()).vr_nrctremp := 172942;
  v_dados(v_dados.last()).vr_vllanmto := 10216.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812231;
  v_dados(v_dados.last()).vr_nrctremp := 295630;
  v_dados(v_dados.last()).vr_vllanmto := 6577.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812029;
  v_dados(v_dados.last()).vr_nrctremp := 238369;
  v_dados(v_dados.last()).vr_vllanmto := 7908.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99812029;
  v_dados(v_dados.last()).vr_nrctremp := 268418;
  v_dados(v_dados.last()).vr_vllanmto := 518.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 824.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 139845;
  v_dados(v_dados.last()).vr_vllanmto := 293.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 148826;
  v_dados(v_dados.last()).vr_vllanmto := 248.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 187546;
  v_dados(v_dados.last()).vr_vllanmto := 612.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 202660;
  v_dados(v_dados.last()).vr_vllanmto := 240.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811952;
  v_dados(v_dados.last()).vr_nrctremp := 284704;
  v_dados(v_dados.last()).vr_vllanmto := 400.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811502;
  v_dados(v_dados.last()).vr_nrctremp := 268186;
  v_dados(v_dados.last()).vr_vllanmto := 731.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811820;
  v_dados(v_dados.last()).vr_nrctremp := 266788;
  v_dados(v_dados.last()).vr_vllanmto := 106.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811782;
  v_dados(v_dados.last()).vr_nrctremp := 299560;
  v_dados(v_dados.last()).vr_vllanmto := 177.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811383;
  v_dados(v_dados.last()).vr_nrctremp := 280380;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811316;
  v_dados(v_dados.last()).vr_nrctremp := 90707;
  v_dados(v_dados.last()).vr_vllanmto := 237.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810786;
  v_dados(v_dados.last()).vr_nrctremp := 321304;
  v_dados(v_dados.last()).vr_vllanmto := 12.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811227;
  v_dados(v_dados.last()).vr_nrctremp := 254965;
  v_dados(v_dados.last()).vr_vllanmto := 341.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99811219;
  v_dados(v_dados.last()).vr_nrctremp := 309516;
  v_dados(v_dados.last()).vr_vllanmto := 36.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810441;
  v_dados(v_dados.last()).vr_nrctremp := 305824;
  v_dados(v_dados.last()).vr_vllanmto := 53.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810441;
  v_dados(v_dados.last()).vr_nrctremp := 319229;
  v_dados(v_dados.last()).vr_vllanmto := 14.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810140;
  v_dados(v_dados.last()).vr_nrctremp := 212748;
  v_dados(v_dados.last()).vr_vllanmto := 470.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810247;
  v_dados(v_dados.last()).vr_nrctremp := 116388;
  v_dados(v_dados.last()).vr_vllanmto := 15.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810140;
  v_dados(v_dados.last()).vr_nrctremp := 231817;
  v_dados(v_dados.last()).vr_vllanmto := 76.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99809893;
  v_dados(v_dados.last()).vr_nrctremp := 334284;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99809842;
  v_dados(v_dados.last()).vr_nrctremp := 229054;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99809800;
  v_dados(v_dados.last()).vr_nrctremp := 117890;
  v_dados(v_dados.last()).vr_vllanmto := 149.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99809800;
  v_dados(v_dados.last()).vr_nrctremp := 263805;
  v_dados(v_dados.last()).vr_vllanmto := 54.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99809001;
  v_dados(v_dados.last()).vr_nrctremp := 259798;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807416;
  v_dados(v_dados.last()).vr_nrctremp := 165359;
  v_dados(v_dados.last()).vr_vllanmto := 13.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807580;
  v_dados(v_dados.last()).vr_nrctremp := 213885;
  v_dados(v_dados.last()).vr_vllanmto := 26727.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807300;
  v_dados(v_dados.last()).vr_nrctremp := 312500;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807246;
  v_dados(v_dados.last()).vr_nrctremp := 313457;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99806576;
  v_dados(v_dados.last()).vr_nrctremp := 306333;
  v_dados(v_dados.last()).vr_vllanmto := 73.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807033;
  v_dados(v_dados.last()).vr_nrctremp := 87507;
  v_dados(v_dados.last()).vr_vllanmto := 5429.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99807017;
  v_dados(v_dados.last()).vr_nrctremp := 351987;
  v_dados(v_dados.last()).vr_vllanmto := 18.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99806690;
  v_dados(v_dados.last()).vr_nrctremp := 247072;
  v_dados(v_dados.last()).vr_vllanmto := 165.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99806428;
  v_dados(v_dados.last()).vr_nrctremp := 91698;
  v_dados(v_dados.last()).vr_vllanmto := 182.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99805898;
  v_dados(v_dados.last()).vr_nrctremp := 342119;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99803356;
  v_dados(v_dados.last()).vr_nrctremp := 302114;
  v_dados(v_dados.last()).vr_vllanmto := 387.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99799812;
  v_dados(v_dados.last()).vr_nrctremp := 268540;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99798638;
  v_dados(v_dados.last()).vr_nrctremp := 241591;
  v_dados(v_dados.last()).vr_vllanmto := 20.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99798638;
  v_dados(v_dados.last()).vr_nrctremp := 347170;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99793210;
  v_dados(v_dados.last()).vr_nrctremp := 353581;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99793431;
  v_dados(v_dados.last()).vr_nrctremp := 309078;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99792796;
  v_dados(v_dados.last()).vr_nrctremp := 264792;
  v_dados(v_dados.last()).vr_vllanmto := 14.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99788411;
  v_dados(v_dados.last()).vr_nrctremp := 265988;
  v_dados(v_dados.last()).vr_vllanmto := 26.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99786575;
  v_dados(v_dados.last()).vr_nrctremp := 195606;
  v_dados(v_dados.last()).vr_vllanmto := 3623.45;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99786877;
  v_dados(v_dados.last()).vr_nrctremp := 324131;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99785684;
  v_dados(v_dados.last()).vr_nrctremp := 228191;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99784076;
  v_dados(v_dados.last()).vr_nrctremp := 57728;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99784033;
  v_dados(v_dados.last()).vr_nrctremp := 340858;
  v_dados(v_dados.last()).vr_vllanmto := 23106.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99783037;
  v_dados(v_dados.last()).vr_nrctremp := 316836;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99781492;
  v_dados(v_dados.last()).vr_nrctremp := 354190;
  v_dados(v_dados.last()).vr_vllanmto := 26.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99781646;
  v_dados(v_dados.last()).vr_nrctremp := 342568;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99780712;
  v_dados(v_dados.last()).vr_nrctremp := 282054;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99780267;
  v_dados(v_dados.last()).vr_nrctremp := 252951;
  v_dados(v_dados.last()).vr_vllanmto := 10.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99780518;
  v_dados(v_dados.last()).vr_nrctremp := 287865;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99777894;
  v_dados(v_dados.last()).vr_nrctremp := 292342;
  v_dados(v_dados.last()).vr_vllanmto := 513.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99777754;
  v_dados(v_dados.last()).vr_nrctremp := 324040;
  v_dados(v_dados.last()).vr_vllanmto := 19.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99775840;
  v_dados(v_dados.last()).vr_nrctremp := 287739;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99773619;
  v_dados(v_dados.last()).vr_nrctremp := 345163;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99772809;
  v_dados(v_dados.last()).vr_nrctremp := 307524;
  v_dados(v_dados.last()).vr_vllanmto := 26.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99770857;
  v_dados(v_dados.last()).vr_nrctremp := 288206;
  v_dados(v_dados.last()).vr_vllanmto := 792.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99768500;
  v_dados(v_dados.last()).vr_nrctremp := 295605;
  v_dados(v_dados.last()).vr_vllanmto := 298.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99768348;
  v_dados(v_dados.last()).vr_nrctremp := 134611;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99765594;
  v_dados(v_dados.last()).vr_nrctremp := 251505;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99765829;
  v_dados(v_dados.last()).vr_nrctremp := 286386;
  v_dados(v_dados.last()).vr_vllanmto := 18.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99762188;
  v_dados(v_dados.last()).vr_nrctremp := 339433;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99759802;
  v_dados(v_dados.last()).vr_nrctremp := 229691;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99758008;
  v_dados(v_dados.last()).vr_nrctremp := 264227;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99758288;
  v_dados(v_dados.last()).vr_nrctremp := 200267;
  v_dados(v_dados.last()).vr_vllanmto := 12.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99757850;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 1406.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99757850;
  v_dados(v_dados.last()).vr_nrctremp := 141760;
  v_dados(v_dados.last()).vr_vllanmto := 313.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99757800;
  v_dados(v_dados.last()).vr_nrctremp := 335316;
  v_dados(v_dados.last()).vr_vllanmto := 15.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99755157;
  v_dados(v_dados.last()).vr_nrctremp := 337205;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99754533;
  v_dados(v_dados.last()).vr_nrctremp := 327781;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99752344;
  v_dados(v_dados.last()).vr_nrctremp := 319391;
  v_dados(v_dados.last()).vr_vllanmto := 18.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99752760;
  v_dados(v_dados.last()).vr_nrctremp := 341687;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99751887;
  v_dados(v_dados.last()).vr_nrctremp := 319947;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99752328;
  v_dados(v_dados.last()).vr_nrctremp := 287608;
  v_dados(v_dados.last()).vr_vllanmto := 15.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99752298;
  v_dados(v_dados.last()).vr_nrctremp := 322556;
  v_dados(v_dados.last()).vr_vllanmto := 25.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99751623;
  v_dados(v_dados.last()).vr_nrctremp := 105884;
  v_dados(v_dados.last()).vr_vllanmto := 4065.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99751623;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 2351.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99750465;
  v_dados(v_dados.last()).vr_nrctremp := 291676;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99746425;
  v_dados(v_dados.last()).vr_nrctremp := 233903;
  v_dados(v_dados.last()).vr_vllanmto := 10.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99746883;
  v_dados(v_dados.last()).vr_nrctremp := 94143;
  v_dados(v_dados.last()).vr_vllanmto := 1883.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99742721;
  v_dados(v_dados.last()).vr_nrctremp := 145047;
  v_dados(v_dados.last()).vr_vllanmto := 14.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99739585;
  v_dados(v_dados.last()).vr_nrctremp := 229337;
  v_dados(v_dados.last()).vr_vllanmto := 18.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738350;
  v_dados(v_dados.last()).vr_nrctremp := 50935;
  v_dados(v_dados.last()).vr_vllanmto := 72.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738813;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 100.56;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738350;
  v_dados(v_dados.last()).vr_nrctremp := 192919;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738350;
  v_dados(v_dados.last()).vr_nrctremp := 238468;
  v_dados(v_dados.last()).vr_vllanmto := 38.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738252;
  v_dados(v_dados.last()).vr_nrctremp := 291487;
  v_dados(v_dados.last()).vr_vllanmto := 16.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99736985;
  v_dados(v_dados.last()).vr_nrctremp := 330380;
  v_dados(v_dados.last()).vr_vllanmto := 21.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735903;
  v_dados(v_dados.last()).vr_nrctremp := 107394;
  v_dados(v_dados.last()).vr_vllanmto := 14.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735016;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 234.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735172;
  v_dados(v_dados.last()).vr_nrctremp := 322768;
  v_dados(v_dados.last()).vr_vllanmto := 20.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735016;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 55.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735016;
  v_dados(v_dados.last()).vr_nrctremp := 153126;
  v_dados(v_dados.last()).vr_vllanmto := 34.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735016;
  v_dados(v_dados.last()).vr_nrctremp := 192497;
  v_dados(v_dados.last()).vr_vllanmto := 35.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99734753;
  v_dados(v_dados.last()).vr_nrctremp := 255306;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99733650;
  v_dados(v_dados.last()).vr_nrctremp := 332289;
  v_dados(v_dados.last()).vr_vllanmto := 10.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99732912;
  v_dados(v_dados.last()).vr_nrctremp := 341693;
  v_dados(v_dados.last()).vr_vllanmto := 14.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99730022;
  v_dados(v_dados.last()).vr_nrctremp := 68956;
  v_dados(v_dados.last()).vr_vllanmto := 1331.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99729199;
  v_dados(v_dados.last()).vr_nrctremp := 322206;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99727846;
  v_dados(v_dados.last()).vr_nrctremp := 229581;
  v_dados(v_dados.last()).vr_vllanmto := 86.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99727820;
  v_dados(v_dados.last()).vr_nrctremp := 252189;
  v_dados(v_dados.last()).vr_vllanmto := 705.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99727579;
  v_dados(v_dados.last()).vr_nrctremp := 117990;
  v_dados(v_dados.last()).vr_vllanmto := 1134.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99727579;
  v_dados(v_dados.last()).vr_nrctremp := 247428;
  v_dados(v_dados.last()).vr_vllanmto := 5047.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99726114;
  v_dados(v_dados.last()).vr_nrctremp := 296354;
  v_dados(v_dados.last()).vr_vllanmto := 66.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99726637;
  v_dados(v_dados.last()).vr_nrctremp := 197758;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99726211;
  v_dados(v_dados.last()).vr_nrctremp := 123203;
  v_dados(v_dados.last()).vr_vllanmto := 13.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99725967;
  v_dados(v_dados.last()).vr_nrctremp := 273508;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99725614;
  v_dados(v_dados.last()).vr_nrctremp := 166688;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99724561;
  v_dados(v_dados.last()).vr_nrctremp := 262808;
  v_dados(v_dados.last()).vr_vllanmto := 15.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99722747;
  v_dados(v_dados.last()).vr_nrctremp := 198109;
  v_dados(v_dados.last()).vr_vllanmto := 35.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99720868;
  v_dados(v_dados.last()).vr_nrctremp := 342782;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99721066;
  v_dados(v_dados.last()).vr_nrctremp := 346702;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99720868;
  v_dados(v_dados.last()).vr_nrctremp := 358228;
  v_dados(v_dados.last()).vr_vllanmto := 28.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99720647;
  v_dados(v_dados.last()).vr_nrctremp := 266531;
  v_dados(v_dados.last()).vr_vllanmto := 38.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99719100;
  v_dados(v_dados.last()).vr_nrctremp := 274491;
  v_dados(v_dados.last()).vr_vllanmto := 12.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99719096;
  v_dados(v_dados.last()).vr_nrctremp := 270046;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99717085;
  v_dados(v_dados.last()).vr_nrctremp := 299509;
  v_dados(v_dados.last()).vr_vllanmto := 16.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99714868;
  v_dados(v_dados.last()).vr_nrctremp := 320937;
  v_dados(v_dados.last()).vr_vllanmto := 13.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99712644;
  v_dados(v_dados.last()).vr_nrctremp := 261596;
  v_dados(v_dados.last()).vr_vllanmto := 17.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99713390;
  v_dados(v_dados.last()).vr_nrctremp := 356033;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99711613;
  v_dados(v_dados.last()).vr_nrctremp := 322754;
  v_dados(v_dados.last()).vr_vllanmto := 10.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99712156;
  v_dados(v_dados.last()).vr_nrctremp := 115984;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99712156;
  v_dados(v_dados.last()).vr_nrctremp := 336308;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99710846;
  v_dados(v_dados.last()).vr_nrctremp := 227800;
  v_dados(v_dados.last()).vr_vllanmto := 2928.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99711290;
  v_dados(v_dados.last()).vr_nrctremp := 238673;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99710510;
  v_dados(v_dados.last()).vr_nrctremp := 321687;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99709155;
  v_dados(v_dados.last()).vr_nrctremp := 230651;
  v_dados(v_dados.last()).vr_vllanmto := 11.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99708086;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 3305.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99704781;
  v_dados(v_dados.last()).vr_nrctremp := 298273;
  v_dados(v_dados.last()).vr_vllanmto := 16.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99702487;
  v_dados(v_dados.last()).vr_nrctremp := 285312;
  v_dados(v_dados.last()).vr_vllanmto := 2365.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99702657;
  v_dados(v_dados.last()).vr_nrctremp := 218923;
  v_dados(v_dados.last()).vr_vllanmto := 57.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99701391;
  v_dados(v_dados.last()).vr_nrctremp := 306995;
  v_dados(v_dados.last()).vr_vllanmto := 11.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99700840;
  v_dados(v_dados.last()).vr_nrctremp := 117044;
  v_dados(v_dados.last()).vr_vllanmto := 74.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99700344;
  v_dados(v_dados.last()).vr_nrctremp := 266459;
  v_dados(v_dados.last()).vr_vllanmto := 208.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99683709;
  v_dados(v_dados.last()).vr_nrctremp := 76421;
  v_dados(v_dados.last()).vr_vllanmto := 3478.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99683709;
  v_dados(v_dados.last()).vr_nrctremp := 77074;
  v_dados(v_dados.last()).vr_vllanmto := 2236.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99681870;
  v_dados(v_dados.last()).vr_nrctremp := 338833;
  v_dados(v_dados.last()).vr_vllanmto := 16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99681323;
  v_dados(v_dados.last()).vr_nrctremp := 332981;
  v_dados(v_dados.last()).vr_vllanmto := 35.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99680050;
  v_dados(v_dados.last()).vr_nrctremp := 269381;
  v_dados(v_dados.last()).vr_vllanmto := 23.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99680050;
  v_dados(v_dados.last()).vr_nrctremp := 307965;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99677571;
  v_dados(v_dados.last()).vr_nrctremp := 251569;
  v_dados(v_dados.last()).vr_vllanmto := 21.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99676931;
  v_dados(v_dados.last()).vr_nrctremp := 148733;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99677040;
  v_dados(v_dados.last()).vr_nrctremp := 307689;
  v_dados(v_dados.last()).vr_vllanmto := 17.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99676931;
  v_dados(v_dados.last()).vr_nrctremp := 233112;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99676648;
  v_dados(v_dados.last()).vr_nrctremp := 310486;
  v_dados(v_dados.last()).vr_vllanmto := 24.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99674181;
  v_dados(v_dados.last()).vr_nrctremp := 277727;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99673630;
  v_dados(v_dados.last()).vr_nrctremp := 290966;
  v_dados(v_dados.last()).vr_vllanmto := 13.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99673630;
  v_dados(v_dados.last()).vr_nrctremp := 356062;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99671921;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 1676.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99671247;
  v_dados(v_dados.last()).vr_nrctremp := 254732;
  v_dados(v_dados.last()).vr_vllanmto := 27.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99670925;
  v_dados(v_dados.last()).vr_nrctremp := 277019;
  v_dados(v_dados.last()).vr_vllanmto := 21.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99668629;
  v_dados(v_dados.last()).vr_nrctremp := 343745;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99665255;
  v_dados(v_dados.last()).vr_nrctremp := 111025;
  v_dados(v_dados.last()).vr_vllanmto := 362.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99663570;
  v_dados(v_dados.last()).vr_nrctremp := 357416;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99655748;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 4299.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99654121;
  v_dados(v_dados.last()).vr_nrctremp := 264176;
  v_dados(v_dados.last()).vr_vllanmto := 11.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99650886;
  v_dados(v_dados.last()).vr_nrctremp := 354299;
  v_dados(v_dados.last()).vr_vllanmto := 11.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99650142;
  v_dados(v_dados.last()).vr_nrctremp := 240715;
  v_dados(v_dados.last()).vr_vllanmto := 309.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99649047;
  v_dados(v_dados.last()).vr_nrctremp := 146914;
  v_dados(v_dados.last()).vr_vllanmto := 114.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99649330;
  v_dados(v_dados.last()).vr_nrctremp := 233793;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99649047;
  v_dados(v_dados.last()).vr_nrctremp := 240061;
  v_dados(v_dados.last()).vr_vllanmto := 42.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99648644;
  v_dados(v_dados.last()).vr_nrctremp := 207634;
  v_dados(v_dados.last()).vr_vllanmto := 13.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99640708;
  v_dados(v_dados.last()).vr_nrctremp := 274385;
  v_dados(v_dados.last()).vr_vllanmto := 342.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99638746;
  v_dados(v_dados.last()).vr_nrctremp := 308561;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99637596;
  v_dados(v_dados.last()).vr_nrctremp := 303438;
  v_dados(v_dados.last()).vr_vllanmto := 20814.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99635909;
  v_dados(v_dados.last()).vr_nrctremp := 296728;
  v_dados(v_dados.last()).vr_vllanmto := 13.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99635402;
  v_dados(v_dados.last()).vr_nrctremp := 326821;
  v_dados(v_dados.last()).vr_vllanmto := 16.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99623676;
  v_dados(v_dados.last()).vr_nrctremp := 353223;
  v_dados(v_dados.last()).vr_vllanmto := 28.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99624591;
  v_dados(v_dados.last()).vr_nrctremp := 285247;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99623676;
  v_dados(v_dados.last()).vr_nrctremp := 356861;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99623196;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 10428.02;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99623307;
  v_dados(v_dados.last()).vr_nrctremp := 359222;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99617102;
  v_dados(v_dados.last()).vr_nrctremp := 300625;
  v_dados(v_dados.last()).vr_vllanmto := 709.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99617102;
  v_dados(v_dados.last()).vr_nrctremp := 163160;
  v_dados(v_dados.last()).vr_vllanmto := 79.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99616939;
  v_dados(v_dados.last()).vr_nrctremp := 104758;
  v_dados(v_dados.last()).vr_vllanmto := 4752.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99615630;
  v_dados(v_dados.last()).vr_nrctremp := 232543;
  v_dados(v_dados.last()).vr_vllanmto := 11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99612658;
  v_dados(v_dados.last()).vr_nrctremp := 355408;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99612194;
  v_dados(v_dados.last()).vr_nrctremp := 351143;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99611759;
  v_dados(v_dados.last()).vr_nrctremp := 268428;
  v_dados(v_dados.last()).vr_vllanmto := 13.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99589893;
  v_dados(v_dados.last()).vr_nrctremp := 157762;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99590360;
  v_dados(v_dados.last()).vr_nrctremp := 340173;
  v_dados(v_dados.last()).vr_vllanmto := 23.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99588960;
  v_dados(v_dados.last()).vr_nrctremp := 307659;
  v_dados(v_dados.last()).vr_vllanmto := 11.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99584557;
  v_dados(v_dados.last()).vr_nrctremp := 307818;
  v_dados(v_dados.last()).vr_vllanmto := 150.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99583330;
  v_dados(v_dados.last()).vr_nrctremp := 179261;
  v_dados(v_dados.last()).vr_vllanmto := 522.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99581639;
  v_dados(v_dados.last()).vr_nrctremp := 338255;
  v_dados(v_dados.last()).vr_vllanmto := 11519.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99579030;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 3076.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99581086;
  v_dados(v_dados.last()).vr_nrctremp := 196967;
  v_dados(v_dados.last()).vr_vllanmto := 107.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99579030;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 1155.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99578891;
  v_dados(v_dados.last()).vr_nrctremp := 267916;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99578816;
  v_dados(v_dados.last()).vr_nrctremp := 342820;
  v_dados(v_dados.last()).vr_vllanmto := 19.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99578816;
  v_dados(v_dados.last()).vr_nrctremp := 343275;
  v_dados(v_dados.last()).vr_vllanmto := 19.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99573679;
  v_dados(v_dados.last()).vr_nrctremp := 255926;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99572516;
  v_dados(v_dados.last()).vr_nrctremp := 167789;
  v_dados(v_dados.last()).vr_vllanmto := 109.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99572516;
  v_dados(v_dados.last()).vr_nrctremp := 336549;
  v_dados(v_dados.last()).vr_vllanmto := 239.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99564980;
  v_dados(v_dados.last()).vr_nrctremp := 354744;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99564939;
  v_dados(v_dados.last()).vr_nrctremp := 343565;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99564840;
  v_dados(v_dados.last()).vr_nrctremp := 305094;
  v_dados(v_dados.last()).vr_vllanmto := 49.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99561255;
  v_dados(v_dados.last()).vr_nrctremp := 305715;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99558564;
  v_dados(v_dados.last()).vr_nrctremp := 62504;
  v_dados(v_dados.last()).vr_vllanmto := 13.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99554429;
  v_dados(v_dados.last()).vr_nrctremp := 256438;
  v_dados(v_dados.last()).vr_vllanmto := 345.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99554380;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 802.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99554380;
  v_dados(v_dados.last()).vr_nrctremp := 253030;
  v_dados(v_dados.last()).vr_vllanmto := 931.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99554330;
  v_dados(v_dados.last()).vr_nrctremp := 296389;
  v_dados(v_dados.last()).vr_vllanmto := 13.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99551110;
  v_dados(v_dados.last()).vr_nrctremp := 346280;
  v_dados(v_dados.last()).vr_vllanmto := 52919.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99550130;
  v_dados(v_dados.last()).vr_nrctremp := 354083;
  v_dados(v_dados.last()).vr_vllanmto := 12.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99548852;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 2045.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99547333;
  v_dados(v_dados.last()).vr_nrctremp := 352555;
  v_dados(v_dados.last()).vr_vllanmto := 54.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99543389;
  v_dados(v_dados.last()).vr_nrctremp := 339309;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99544091;
  v_dados(v_dados.last()).vr_nrctremp := 278103;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99543370;
  v_dados(v_dados.last()).vr_nrctremp := 330485;
  v_dados(v_dados.last()).vr_vllanmto := 25.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99539632;
  v_dados(v_dados.last()).vr_nrctremp := 294436;
  v_dados(v_dados.last()).vr_vllanmto := 63.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99537915;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 19.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99538237;
  v_dados(v_dados.last()).vr_nrctremp := 333085;
  v_dados(v_dados.last()).vr_vllanmto := 41.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99537915;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 734.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99537770;
  v_dados(v_dados.last()).vr_nrctremp := 321244;
  v_dados(v_dados.last()).vr_vllanmto := 15.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99536617;
  v_dados(v_dados.last()).vr_nrctremp := 269042;
  v_dados(v_dados.last()).vr_vllanmto := 76.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99534487;
  v_dados(v_dados.last()).vr_nrctremp := 349799;
  v_dados(v_dados.last()).vr_vllanmto := 12.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99533910;
  v_dados(v_dados.last()).vr_nrctremp := 197207;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99533910;
  v_dados(v_dados.last()).vr_nrctremp := 264011;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99533910;
  v_dados(v_dados.last()).vr_nrctremp := 296358;
  v_dados(v_dados.last()).vr_vllanmto := 16.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99532492;
  v_dados(v_dados.last()).vr_nrctremp := 116408;
  v_dados(v_dados.last()).vr_vllanmto := 67.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99532573;
  v_dados(v_dados.last()).vr_nrctremp := 149121;
  v_dados(v_dados.last()).vr_vllanmto := 77.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99532573;
  v_dados(v_dados.last()).vr_nrctremp := 241384;
  v_dados(v_dados.last()).vr_vllanmto := 52.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99532492;
  v_dados(v_dados.last()).vr_nrctremp := 73978;
  v_dados(v_dados.last()).vr_vllanmto := 213.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99528649;
  v_dados(v_dados.last()).vr_nrctremp := 282785;
  v_dados(v_dados.last()).vr_vllanmto := 66.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99524910;
  v_dados(v_dados.last()).vr_nrctremp := 319297;
  v_dados(v_dados.last()).vr_vllanmto := 14.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99520486;
  v_dados(v_dados.last()).vr_nrctremp := 305938;
  v_dados(v_dados.last()).vr_vllanmto := 27.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99519429;
  v_dados(v_dados.last()).vr_nrctremp := 209089;
  v_dados(v_dados.last()).vr_vllanmto := 1445.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99519372;
  v_dados(v_dados.last()).vr_nrctremp := 289660;
  v_dados(v_dados.last()).vr_vllanmto := 213.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99514729;
  v_dados(v_dados.last()).vr_nrctremp := 303855;
  v_dados(v_dados.last()).vr_vllanmto := 95.24;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99514729;
  v_dados(v_dados.last()).vr_nrctremp := 351293;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99513390;
  v_dados(v_dados.last()).vr_nrctremp := 355730;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99513331;
  v_dados(v_dados.last()).vr_nrctremp := 360014;
  v_dados(v_dados.last()).vr_vllanmto := 15.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99506572;
  v_dados(v_dados.last()).vr_nrctremp := 241573;
  v_dados(v_dados.last()).vr_vllanmto := 13.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99506564;
  v_dados(v_dados.last()).vr_nrctremp := 304312;
  v_dados(v_dados.last()).vr_vllanmto := 25.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99505657;
  v_dados(v_dados.last()).vr_nrctremp := 358862;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99504626;
  v_dados(v_dados.last()).vr_nrctremp := 313323;
  v_dados(v_dados.last()).vr_vllanmto := 20.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99502127;
  v_dados(v_dados.last()).vr_nrctremp := 313816;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99501643;
  v_dados(v_dados.last()).vr_nrctremp := 273326;
  v_dados(v_dados.last()).vr_vllanmto := 45.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99500078;
  v_dados(v_dados.last()).vr_nrctremp := 202250;
  v_dados(v_dados.last()).vr_vllanmto := 21.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99501120;
  v_dados(v_dados.last()).vr_nrctremp := 289873;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99500078;
  v_dados(v_dados.last()).vr_nrctremp := 242253;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99498154;
  v_dados(v_dados.last()).vr_nrctremp := 312885;
  v_dados(v_dados.last()).vr_vllanmto := 13.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99496151;
  v_dados(v_dados.last()).vr_nrctremp := 347017;
  v_dados(v_dados.last()).vr_vllanmto := 25.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99493519;
  v_dados(v_dados.last()).vr_nrctremp := 326992;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 185908;
  v_dados(v_dados.last()).vr_vllanmto := 158.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 141142;
  v_dados(v_dados.last()).vr_vllanmto := 507.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 150785;
  v_dados(v_dados.last()).vr_vllanmto := 507.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 165366;
  v_dados(v_dados.last()).vr_vllanmto := 138.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 194673;
  v_dados(v_dados.last()).vr_vllanmto := 149.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99492725;
  v_dados(v_dados.last()).vr_nrctremp := 230274;
  v_dados(v_dados.last()).vr_vllanmto := 339.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99486989;
  v_dados(v_dados.last()).vr_nrctremp := 352152;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99482770;
  v_dados(v_dados.last()).vr_nrctremp := 306965;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99483556;
  v_dados(v_dados.last()).vr_nrctremp := 307628;
  v_dados(v_dados.last()).vr_vllanmto := 37.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99481367;
  v_dados(v_dados.last()).vr_nrctremp := 239737;
  v_dados(v_dados.last()).vr_vllanmto := 157.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99482541;
  v_dados(v_dados.last()).vr_nrctremp := 262464;
  v_dados(v_dados.last()).vr_vllanmto := 199.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99478684;
  v_dados(v_dados.last()).vr_nrctremp := 338817;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99478790;
  v_dados(v_dados.last()).vr_nrctremp := 254210;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99478595;
  v_dados(v_dados.last()).vr_nrctremp := 358010;
  v_dados(v_dados.last()).vr_vllanmto := 24.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99475812;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 10364.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99476274;
  v_dados(v_dados.last()).vr_nrctremp := 336741;
  v_dados(v_dados.last()).vr_vllanmto := 28.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99473151;
  v_dados(v_dados.last()).vr_nrctremp := 334314;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99472449;
  v_dados(v_dados.last()).vr_nrctremp := 309972;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99465922;
  v_dados(v_dados.last()).vr_nrctremp := 145861;
  v_dados(v_dados.last()).vr_vllanmto := 1622.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99467224;
  v_dados(v_dados.last()).vr_nrctremp := 216332;
  v_dados(v_dados.last()).vr_vllanmto := 251.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99467011;
  v_dados(v_dados.last()).vr_nrctremp := 288495;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99465922;
  v_dados(v_dados.last()).vr_nrctremp := 253534;
  v_dados(v_dados.last()).vr_vllanmto := 398.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99465922;
  v_dados(v_dados.last()).vr_nrctremp := 290708;
  v_dados(v_dados.last()).vr_vllanmto := 903.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99464225;
  v_dados(v_dados.last()).vr_nrctremp := 283864;
  v_dados(v_dados.last()).vr_vllanmto := 28.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99460041;
  v_dados(v_dados.last()).vr_nrctremp := 250086;
  v_dados(v_dados.last()).vr_vllanmto := 2222.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99458373;
  v_dados(v_dados.last()).vr_nrctremp := 346343;
  v_dados(v_dados.last()).vr_vllanmto := 20.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99458624;
  v_dados(v_dados.last()).vr_nrctremp := 322034;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99456222;
  v_dados(v_dados.last()).vr_nrctremp := 357861;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99456796;
  v_dados(v_dados.last()).vr_nrctremp := 210362;
  v_dados(v_dados.last()).vr_vllanmto := 1233.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99455544;
  v_dados(v_dados.last()).vr_nrctremp := 349801;
  v_dados(v_dados.last()).vr_vllanmto := 25.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99453053;
  v_dados(v_dados.last()).vr_nrctremp := 248763;
  v_dados(v_dados.last()).vr_vllanmto := 50.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99451255;
  v_dados(v_dados.last()).vr_nrctremp := 354062;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99450674;
  v_dados(v_dados.last()).vr_nrctremp := 250370;
  v_dados(v_dados.last()).vr_vllanmto := 15.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99448882;
  v_dados(v_dados.last()).vr_nrctremp := 300648;
  v_dados(v_dados.last()).vr_vllanmto := 598.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99449838;
  v_dados(v_dados.last()).vr_nrctremp := 346405;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99448408;
  v_dados(v_dados.last()).vr_nrctremp := 261412;
  v_dados(v_dados.last()).vr_vllanmto := 1071.73;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99448610;
  v_dados(v_dados.last()).vr_nrctremp := 328356;
  v_dados(v_dados.last()).vr_vllanmto := 12.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99447452;
  v_dados(v_dados.last()).vr_nrctremp := 312583;
  v_dados(v_dados.last()).vr_vllanmto := 21.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99445972;
  v_dados(v_dados.last()).vr_nrctremp := 340506;
  v_dados(v_dados.last()).vr_vllanmto := 13.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99443686;
  v_dados(v_dados.last()).vr_nrctremp := 298087;
  v_dados(v_dados.last()).vr_vllanmto := 122.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99440075;
  v_dados(v_dados.last()).vr_nrctremp := 220482;
  v_dados(v_dados.last()).vr_vllanmto := 169.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99436442;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 1317.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99434091;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 920.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99434326;
  v_dados(v_dados.last()).vr_nrctremp := 287462;
  v_dados(v_dados.last()).vr_vllanmto := 18.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99427443;
  v_dados(v_dados.last()).vr_nrctremp := 272741;
  v_dados(v_dados.last()).vr_vllanmto := 19432.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99427621;
  v_dados(v_dados.last()).vr_nrctremp := 246657;
  v_dados(v_dados.last()).vr_vllanmto := 19.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99427621;
  v_dados(v_dados.last()).vr_nrctremp := 346275;
  v_dados(v_dados.last()).vr_vllanmto := 12.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99427443;
  v_dados(v_dados.last()).vr_nrctremp := 326092;
  v_dados(v_dados.last()).vr_vllanmto := 8676.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99427443;
  v_dados(v_dados.last()).vr_nrctremp := 342184;
  v_dados(v_dados.last()).vr_vllanmto := 4994.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99426919;
  v_dados(v_dados.last()).vr_nrctremp := 121298;
  v_dados(v_dados.last()).vr_vllanmto := 17.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99422840;
  v_dados(v_dados.last()).vr_nrctremp := 198976;
  v_dados(v_dados.last()).vr_vllanmto := 259.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99417898;
  v_dados(v_dados.last()).vr_nrctremp := 166819;
  v_dados(v_dados.last()).vr_vllanmto := 3907.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99414112;
  v_dados(v_dados.last()).vr_nrctremp := 356502;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99414732;
  v_dados(v_dados.last()).vr_nrctremp := 279742;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99414015;
  v_dados(v_dados.last()).vr_nrctremp := 299823;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99408953;
  v_dados(v_dados.last()).vr_nrctremp := 259371;
  v_dados(v_dados.last()).vr_vllanmto := 442.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99409771;
  v_dados(v_dados.last()).vr_nrctremp := 289199;
  v_dados(v_dados.last()).vr_vllanmto := 14.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99407159;
  v_dados(v_dados.last()).vr_nrctremp := 271052;
  v_dados(v_dados.last()).vr_vllanmto := 1916.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99400260;
  v_dados(v_dados.last()).vr_nrctremp := 315071;
  v_dados(v_dados.last()).vr_vllanmto := 10.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99398877;
  v_dados(v_dados.last()).vr_nrctremp := 261659;
  v_dados(v_dados.last()).vr_vllanmto := 16.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99393697;
  v_dados(v_dados.last()).vr_nrctremp := 346012;
  v_dados(v_dados.last()).vr_vllanmto := 26.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99392887;
  v_dados(v_dados.last()).vr_nrctremp := 299818;
  v_dados(v_dados.last()).vr_vllanmto := 28.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99393107;
  v_dados(v_dados.last()).vr_nrctremp := 337606;
  v_dados(v_dados.last()).vr_vllanmto := 15.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99389045;
  v_dados(v_dados.last()).vr_nrctremp := 227415;
  v_dados(v_dados.last()).vr_vllanmto := 2046.55;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99388634;
  v_dados(v_dados.last()).vr_nrctremp := 318423;
  v_dados(v_dados.last()).vr_vllanmto := 208.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99385325;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 811.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99383594;
  v_dados(v_dados.last()).vr_nrctremp := 137941;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99384574;
  v_dados(v_dados.last()).vr_nrctremp := 295571;
  v_dados(v_dados.last()).vr_vllanmto := 292.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99383349;
  v_dados(v_dados.last()).vr_nrctremp := 339307;
  v_dados(v_dados.last()).vr_vllanmto := 10.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99381125;
  v_dados(v_dados.last()).vr_nrctremp := 244539;
  v_dados(v_dados.last()).vr_vllanmto := 40.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99379147;
  v_dados(v_dados.last()).vr_nrctremp := 275288;
  v_dados(v_dados.last()).vr_vllanmto := 13.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99374641;
  v_dados(v_dados.last()).vr_nrctremp := 256774;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99373572;
  v_dados(v_dados.last()).vr_nrctremp := 315289;
  v_dados(v_dados.last()).vr_vllanmto := 29.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99373572;
  v_dados(v_dados.last()).vr_nrctremp := 333794;
  v_dados(v_dados.last()).vr_vllanmto := 17.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99367009;
  v_dados(v_dados.last()).vr_nrctremp := 328288;
  v_dados(v_dados.last()).vr_vllanmto := 39.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99361361;
  v_dados(v_dados.last()).vr_nrctremp := 250085;
  v_dados(v_dados.last()).vr_vllanmto := 348.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99359987;
  v_dados(v_dados.last()).vr_nrctremp := 240582;
  v_dados(v_dados.last()).vr_vllanmto := 293.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99358190;
  v_dados(v_dados.last()).vr_nrctremp := 327661;
  v_dados(v_dados.last()).vr_vllanmto := 25.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99352419;
  v_dados(v_dados.last()).vr_nrctremp := 152360;
  v_dados(v_dados.last()).vr_vllanmto := 563.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99352419;
  v_dados(v_dados.last()).vr_nrctremp := 191578;
  v_dados(v_dados.last()).vr_vllanmto := 507.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99352095;
  v_dados(v_dados.last()).vr_nrctremp := 192882;
  v_dados(v_dados.last()).vr_vllanmto := 1528.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99351102;
  v_dados(v_dados.last()).vr_nrctremp := 260453;
  v_dados(v_dados.last()).vr_vllanmto := 89.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99351528;
  v_dados(v_dados.last()).vr_nrctremp := 315699;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99351528;
  v_dados(v_dados.last()).vr_nrctremp := 319946;
  v_dados(v_dados.last()).vr_vllanmto := 19.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99350084;
  v_dados(v_dados.last()).vr_nrctremp := 259911;
  v_dados(v_dados.last()).vr_vllanmto := 40.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99349167;
  v_dados(v_dados.last()).vr_nrctremp := 209265;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99347326;
  v_dados(v_dados.last()).vr_nrctremp := 212819;
  v_dados(v_dados.last()).vr_vllanmto := 1264.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99337371;
  v_dados(v_dados.last()).vr_nrctremp := 160854;
  v_dados(v_dados.last()).vr_vllanmto := 139.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99336006;
  v_dados(v_dados.last()).vr_nrctremp := 304608;
  v_dados(v_dados.last()).vr_vllanmto := 995.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99335956;
  v_dados(v_dados.last()).vr_nrctremp := 335401;
  v_dados(v_dados.last()).vr_vllanmto := 12.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99333821;
  v_dados(v_dados.last()).vr_nrctremp := 297874;
  v_dados(v_dados.last()).vr_vllanmto := 21.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99332590;
  v_dados(v_dados.last()).vr_nrctremp := 293904;
  v_dados(v_dados.last()).vr_vllanmto := 50.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99331250;
  v_dados(v_dados.last()).vr_nrctremp := 318751;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99330385;
  v_dados(v_dados.last()).vr_nrctremp := 313260;
  v_dados(v_dados.last()).vr_vllanmto := 100.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99327805;
  v_dados(v_dados.last()).vr_nrctremp := 166378;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99322803;
  v_dados(v_dados.last()).vr_nrctremp := 170004;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99321084;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 5352.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99319128;
  v_dados(v_dados.last()).vr_nrctremp := 354556;
  v_dados(v_dados.last()).vr_vllanmto := 25.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99318997;
  v_dados(v_dados.last()).vr_nrctremp := 317433;
  v_dados(v_dados.last()).vr_vllanmto := 22.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99318830;
  v_dados(v_dados.last()).vr_nrctremp := 264146;
  v_dados(v_dados.last()).vr_vllanmto := 184.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99317648;
  v_dados(v_dados.last()).vr_nrctremp := 325886;
  v_dados(v_dados.last()).vr_vllanmto := 15.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99311666;
  v_dados(v_dados.last()).vr_nrctremp := 346567;
  v_dados(v_dados.last()).vr_vllanmto := 102.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99311666;
  v_dados(v_dados.last()).vr_nrctremp := 348179;
  v_dados(v_dados.last()).vr_vllanmto := 21.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99311666;
  v_dados(v_dados.last()).vr_nrctremp := 348225;
  v_dados(v_dados.last()).vr_vllanmto := 29.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99309998;
  v_dados(v_dados.last()).vr_nrctremp := 313383;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99310724;
  v_dados(v_dados.last()).vr_nrctremp := 323684;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99307618;
  v_dados(v_dados.last()).vr_nrctremp := 315004;
  v_dados(v_dados.last()).vr_vllanmto := 119.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99302454;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 1327.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99303566;
  v_dados(v_dados.last()).vr_nrctremp := 225993;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99302454;
  v_dados(v_dados.last()).vr_nrctremp := 292212;
  v_dados(v_dados.last()).vr_vllanmto := 674.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99300443;
  v_dados(v_dados.last()).vr_nrctremp := 229817;
  v_dados(v_dados.last()).vr_vllanmto := 15.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99298473;
  v_dados(v_dados.last()).vr_nrctremp := 327127;
  v_dados(v_dados.last()).vr_vllanmto := 16.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99298376;
  v_dados(v_dados.last()).vr_nrctremp := 351979;
  v_dados(v_dados.last()).vr_vllanmto := 36.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99297540;
  v_dados(v_dados.last()).vr_nrctremp := 240134;
  v_dados(v_dados.last()).vr_vllanmto := 37.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99296217;
  v_dados(v_dados.last()).vr_nrctremp := 358840;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99294010;
  v_dados(v_dados.last()).vr_nrctremp := 245304;
  v_dados(v_dados.last()).vr_vllanmto := 1731.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99291339;
  v_dados(v_dados.last()).vr_nrctremp := 347990;
  v_dados(v_dados.last()).vr_vllanmto := 15.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99289962;
  v_dados(v_dados.last()).vr_nrctremp := 350023;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99286734;
  v_dados(v_dados.last()).vr_nrctremp := 352171;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99283549;
  v_dados(v_dados.last()).vr_nrctremp := 285975;
  v_dados(v_dados.last()).vr_vllanmto := 61.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99281627;
  v_dados(v_dados.last()).vr_nrctremp := 186780;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99276488;
  v_dados(v_dados.last()).vr_nrctremp := 222216;
  v_dados(v_dados.last()).vr_vllanmto := 9116.4;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99264625;
  v_dados(v_dados.last()).vr_nrctremp := 289846;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99258560;
  v_dados(v_dados.last()).vr_nrctremp := 284004;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99259702;
  v_dados(v_dados.last()).vr_nrctremp := 340491;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99258480;
  v_dados(v_dados.last()).vr_nrctremp := 344546;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99250306;
  v_dados(v_dados.last()).vr_nrctremp := 306964;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99249669;
  v_dados(v_dados.last()).vr_nrctremp := 340723;
  v_dados(v_dados.last()).vr_vllanmto := 13.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99245418;
  v_dados(v_dados.last()).vr_nrctremp := 261384;
  v_dados(v_dados.last()).vr_vllanmto := 1629.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99243717;
  v_dados(v_dados.last()).vr_nrctremp := 349384;
  v_dados(v_dados.last()).vr_vllanmto := 17.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99232626;
  v_dados(v_dados.last()).vr_nrctremp := 324166;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99235897;
  v_dados(v_dados.last()).vr_nrctremp := 338079;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99234475;
  v_dados(v_dados.last()).vr_nrctremp := 309224;
  v_dados(v_dados.last()).vr_vllanmto := 18.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99229811;
  v_dados(v_dados.last()).vr_nrctremp := 356398;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99213923;
  v_dados(v_dados.last()).vr_nrctremp := 359666;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99220741;
  v_dados(v_dados.last()).vr_nrctremp := 342438;
  v_dados(v_dados.last()).vr_vllanmto := 15.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82012636;
  v_dados(v_dados.last()).vr_nrctremp := 333328;
  v_dados(v_dados.last()).vr_vllanmto := 30.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82012636;
  v_dados(v_dados.last()).vr_nrctremp := 341874;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85845850;
  v_dados(v_dados.last()).vr_nrctremp := 291115;
  v_dados(v_dados.last()).vr_vllanmto := 244.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85864897;
  v_dados(v_dados.last()).vr_nrctremp := 303642;
  v_dados(v_dados.last()).vr_vllanmto := 794.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85814288;
  v_dados(v_dados.last()).vr_nrctremp := 331370;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85775681;
  v_dados(v_dados.last()).vr_nrctremp := 176904;
  v_dados(v_dados.last()).vr_vllanmto := 1631.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85775681;
  v_dados(v_dados.last()).vr_nrctremp := 176905;
  v_dados(v_dados.last()).vr_vllanmto := 1574.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85447595;
  v_dados(v_dados.last()).vr_nrctremp := 290158;
  v_dados(v_dados.last()).vr_vllanmto := 215.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85447595;
  v_dados(v_dados.last()).vr_nrctremp := 241295;
  v_dados(v_dados.last()).vr_vllanmto := 2449.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85374270;
  v_dados(v_dados.last()).vr_nrctremp := 291689;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85398411;
  v_dados(v_dados.last()).vr_nrctremp := 201815;
  v_dados(v_dados.last()).vr_vllanmto := 549.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85397202;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 1005.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85394610;
  v_dados(v_dados.last()).vr_nrctremp := 341943;
  v_dados(v_dados.last()).vr_vllanmto := 12.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85383856;
  v_dados(v_dados.last()).vr_nrctremp := 294867;
  v_dados(v_dados.last()).vr_vllanmto := 695.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85379646;
  v_dados(v_dados.last()).vr_nrctremp := 352891;
  v_dados(v_dados.last()).vr_vllanmto := 14.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85317730;
  v_dados(v_dados.last()).vr_nrctremp := 286780;
  v_dados(v_dados.last()).vr_vllanmto := 96.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85274100;
  v_dados(v_dados.last()).vr_nrctremp := 198301;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85277215;
  v_dados(v_dados.last()).vr_nrctremp := 200765;
  v_dados(v_dados.last()).vr_vllanmto := 2992.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85276715;
  v_dados(v_dados.last()).vr_nrctremp := 268898;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85259233;
  v_dados(v_dados.last()).vr_nrctremp := 225274;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85207284;
  v_dados(v_dados.last()).vr_nrctremp := 234156;
  v_dados(v_dados.last()).vr_vllanmto := 1729.8;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85228265;
  v_dados(v_dados.last()).vr_nrctremp := 240186;
  v_dados(v_dados.last()).vr_vllanmto := 7667.31;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85148741;
  v_dados(v_dados.last()).vr_nrctremp := 203894;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85159611;
  v_dados(v_dados.last()).vr_nrctremp := 278852;
  v_dados(v_dados.last()).vr_vllanmto := 244.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85077763;
  v_dados(v_dados.last()).vr_nrctremp := 359685;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85085294;
  v_dados(v_dados.last()).vr_nrctremp := 353834;
  v_dados(v_dados.last()).vr_vllanmto := 15.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84983000;
  v_dados(v_dados.last()).vr_nrctremp := 297585;
  v_dados(v_dados.last()).vr_vllanmto := 12.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85031941;
  v_dados(v_dados.last()).vr_nrctremp := 209246;
  v_dados(v_dados.last()).vr_vllanmto := 197.76;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85031941;
  v_dados(v_dados.last()).vr_nrctremp := 238463;
  v_dados(v_dados.last()).vr_vllanmto := 482.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85031941;
  v_dados(v_dados.last()).vr_nrctremp := 267064;
  v_dados(v_dados.last()).vr_vllanmto := 398.76;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 274680;
  v_dados(v_dados.last()).vr_vllanmto := 576.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 215815;
  v_dados(v_dados.last()).vr_vllanmto := 1554.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 219069;
  v_dados(v_dados.last()).vr_vllanmto := 1862.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 247863;
  v_dados(v_dados.last()).vr_vllanmto := 581;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84927615;
  v_dados(v_dados.last()).vr_nrctremp := 304380;
  v_dados(v_dados.last()).vr_vllanmto := 287.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84891017;
  v_dados(v_dados.last()).vr_nrctremp := 330299;
  v_dados(v_dados.last()).vr_vllanmto := 11.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84866454;
  v_dados(v_dados.last()).vr_nrctremp := 297537;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84794259;
  v_dados(v_dados.last()).vr_nrctremp := 220654;
  v_dados(v_dados.last()).vr_vllanmto := 33.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84833734;
  v_dados(v_dados.last()).vr_nrctremp := 306790;
  v_dados(v_dados.last()).vr_vllanmto := 89.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84790741;
  v_dados(v_dados.last()).vr_nrctremp := 220834;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84758058;
  v_dados(v_dados.last()).vr_nrctremp := 222548;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84774991;
  v_dados(v_dados.last()).vr_nrctremp := 289503;
  v_dados(v_dados.last()).vr_vllanmto := 18.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84754583;
  v_dados(v_dados.last()).vr_nrctremp := 222416;
  v_dados(v_dados.last()).vr_vllanmto := 23.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84726032;
  v_dados(v_dados.last()).vr_nrctremp := 339659;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84733179;
  v_dados(v_dados.last()).vr_nrctremp := 305186;
  v_dados(v_dados.last()).vr_vllanmto := 125.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84679980;
  v_dados(v_dados.last()).vr_nrctremp := 343433;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84641002;
  v_dados(v_dados.last()).vr_nrctremp := 262210;
  v_dados(v_dados.last()).vr_vllanmto := 29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84659130;
  v_dados(v_dados.last()).vr_nrctremp := 321201;
  v_dados(v_dados.last()).vr_vllanmto := 36.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84622270;
  v_dados(v_dados.last()).vr_nrctremp := 280792;
  v_dados(v_dados.last()).vr_vllanmto := 1556.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84604654;
  v_dados(v_dados.last()).vr_nrctremp := 310314;
  v_dados(v_dados.last()).vr_vllanmto := 16.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84598140;
  v_dados(v_dados.last()).vr_nrctremp := 230219;
  v_dados(v_dados.last()).vr_vllanmto := 330.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84598140;
  v_dados(v_dados.last()).vr_nrctremp := 275871;
  v_dados(v_dados.last()).vr_vllanmto := 102.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84598140;
  v_dados(v_dados.last()).vr_nrctremp := 306655;
  v_dados(v_dados.last()).vr_vllanmto := 32.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84590939;
  v_dados(v_dados.last()).vr_nrctremp := 230711;
  v_dados(v_dados.last()).vr_vllanmto := 422.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84590939;
  v_dados(v_dados.last()).vr_nrctremp := 273783;
  v_dados(v_dados.last()).vr_vllanmto := 164.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84544791;
  v_dados(v_dados.last()).vr_nrctremp := 348248;
  v_dados(v_dados.last()).vr_vllanmto := 20.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84559810;
  v_dados(v_dados.last()).vr_nrctremp := 240660;
  v_dados(v_dados.last()).vr_vllanmto := 12354.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84540060;
  v_dados(v_dados.last()).vr_nrctremp := 327617;
  v_dados(v_dados.last()).vr_vllanmto := 21.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84498226;
  v_dados(v_dados.last()).vr_nrctremp := 265084;
  v_dados(v_dados.last()).vr_vllanmto := 213.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84455551;
  v_dados(v_dados.last()).vr_nrctremp := 282609;
  v_dados(v_dados.last()).vr_vllanmto := 22.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84458925;
  v_dados(v_dados.last()).vr_nrctremp := 314150;
  v_dados(v_dados.last()).vr_vllanmto := 515.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84451483;
  v_dados(v_dados.last()).vr_nrctremp := 255285;
  v_dados(v_dados.last()).vr_vllanmto := 42380.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84451483;
  v_dados(v_dados.last()).vr_nrctremp := 347606;
  v_dados(v_dados.last()).vr_vllanmto := 142955.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84418613;
  v_dados(v_dados.last()).vr_nrctremp := 342817;
  v_dados(v_dados.last()).vr_vllanmto := 16.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84422149;
  v_dados(v_dados.last()).vr_nrctremp := 238348;
  v_dados(v_dados.last()).vr_vllanmto := 27960.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84340002;
  v_dados(v_dados.last()).vr_nrctremp := 342141;
  v_dados(v_dados.last()).vr_vllanmto := 17.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84368977;
  v_dados(v_dados.last()).vr_nrctremp := 241402;
  v_dados(v_dados.last()).vr_vllanmto := 13.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 245466;
  v_dados(v_dados.last()).vr_vllanmto := 1542.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84314702;
  v_dados(v_dados.last()).vr_nrctremp := 266075;
  v_dados(v_dados.last()).vr_vllanmto := 17943.3;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84289406;
  v_dados(v_dados.last()).vr_nrctremp := 288622;
  v_dados(v_dados.last()).vr_vllanmto := 250.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 262208;
  v_dados(v_dados.last()).vr_vllanmto := 48.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 276541;
  v_dados(v_dados.last()).vr_vllanmto := 66.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 295195;
  v_dados(v_dados.last()).vr_vllanmto := 481.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 298678;
  v_dados(v_dados.last()).vr_vllanmto := 352.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84254327;
  v_dados(v_dados.last()).vr_nrctremp := 246681;
  v_dados(v_dados.last()).vr_vllanmto := 40.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84256974;
  v_dados(v_dados.last()).vr_nrctremp := 252687;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84245301;
  v_dados(v_dados.last()).vr_nrctremp := 320296;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84239964;
  v_dados(v_dados.last()).vr_nrctremp := 246683;
  v_dados(v_dados.last()).vr_vllanmto := 19.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84239964;
  v_dados(v_dados.last()).vr_nrctremp := 315005;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84229306;
  v_dados(v_dados.last()).vr_nrctremp := 248940;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84234458;
  v_dados(v_dados.last()).vr_nrctremp := 347437;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84176113;
  v_dados(v_dados.last()).vr_nrctremp := 350345;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84192577;
  v_dados(v_dados.last()).vr_nrctremp := 350165;
  v_dados(v_dados.last()).vr_vllanmto := 27.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84150637;
  v_dados(v_dados.last()).vr_nrctremp := 250564;
  v_dados(v_dados.last()).vr_vllanmto := 10.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84118997;
  v_dados(v_dados.last()).vr_nrctremp := 263864;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84110929;
  v_dados(v_dados.last()).vr_nrctremp := 305117;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84094184;
  v_dados(v_dados.last()).vr_nrctremp := 348250;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84043210;
  v_dados(v_dados.last()).vr_nrctremp := 337673;
  v_dados(v_dados.last()).vr_vllanmto := 23028.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84059591;
  v_dados(v_dados.last()).vr_nrctremp := 254682;
  v_dados(v_dados.last()).vr_vllanmto := 17517.05;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84024763;
  v_dados(v_dados.last()).vr_nrctremp := 256196;
  v_dados(v_dados.last()).vr_vllanmto := 16.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84020350;
  v_dados(v_dados.last()).vr_nrctremp := 342611;
  v_dados(v_dados.last()).vr_vllanmto := 13.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83992766;
  v_dados(v_dados.last()).vr_nrctremp := 257774;
  v_dados(v_dados.last()).vr_vllanmto := 21.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83986081;
  v_dados(v_dados.last()).vr_nrctremp := 280042;
  v_dados(v_dados.last()).vr_vllanmto := 36.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83981624;
  v_dados(v_dados.last()).vr_nrctremp := 258541;
  v_dados(v_dados.last()).vr_vllanmto := 69.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83963634;
  v_dados(v_dados.last()).vr_nrctremp := 260828;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83881140;
  v_dados(v_dados.last()).vr_nrctremp := 264780;
  v_dados(v_dados.last()).vr_vllanmto := 1329.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83904670;
  v_dados(v_dados.last()).vr_nrctremp := 262218;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83841270;
  v_dados(v_dados.last()).vr_nrctremp := 264849;
  v_dados(v_dados.last()).vr_vllanmto := 24.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83851623;
  v_dados(v_dados.last()).vr_nrctremp := 264341;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83841270;
  v_dados(v_dados.last()).vr_nrctremp := 303854;
  v_dados(v_dados.last()).vr_vllanmto := 16.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83839380;
  v_dados(v_dados.last()).vr_nrctremp := 314110;
  v_dados(v_dados.last()).vr_vllanmto := 36.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83809147;
  v_dados(v_dados.last()).vr_nrctremp := 280221;
  v_dados(v_dados.last()).vr_vllanmto := 20.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83809147;
  v_dados(v_dados.last()).vr_nrctremp := 350950;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83793542;
  v_dados(v_dados.last()).vr_nrctremp := 305786;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83799150;
  v_dados(v_dados.last()).vr_nrctremp := 353132;
  v_dados(v_dados.last()).vr_vllanmto := 13.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83789839;
  v_dados(v_dados.last()).vr_nrctremp := 276225;
  v_dados(v_dados.last()).vr_vllanmto := 130.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83783318;
  v_dados(v_dados.last()).vr_nrctremp := 272673;
  v_dados(v_dados.last()).vr_vllanmto := 28789.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83777849;
  v_dados(v_dados.last()).vr_nrctremp := 313705;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83777830;
  v_dados(v_dados.last()).vr_nrctremp := 283548;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83769544;
  v_dados(v_dados.last()).vr_nrctremp := 267618;
  v_dados(v_dados.last()).vr_vllanmto := 18.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83755110;
  v_dados(v_dados.last()).vr_nrctremp := 267932;
  v_dados(v_dados.last()).vr_vllanmto := 21.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83764097;
  v_dados(v_dados.last()).vr_nrctremp := 267821;
  v_dados(v_dados.last()).vr_vllanmto := 20.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83749381;
  v_dados(v_dados.last()).vr_nrctremp := 281788;
  v_dados(v_dados.last()).vr_vllanmto := 12893.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83744886;
  v_dados(v_dados.last()).vr_nrctremp := 298283;
  v_dados(v_dados.last()).vr_vllanmto := 10.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83742611;
  v_dados(v_dados.last()).vr_nrctremp := 268640;
  v_dados(v_dados.last()).vr_vllanmto := 1864.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83718923;
  v_dados(v_dados.last()).vr_nrctremp := 319401;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83662170;
  v_dados(v_dados.last()).vr_nrctremp := 286889;
  v_dados(v_dados.last()).vr_vllanmto := 465.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83702415;
  v_dados(v_dados.last()).vr_nrctremp := 357300;
  v_dados(v_dados.last()).vr_vllanmto := 33.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83649506;
  v_dados(v_dados.last()).vr_nrctremp := 279936;
  v_dados(v_dados.last()).vr_vllanmto := 55.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83649506;
  v_dados(v_dados.last()).vr_nrctremp := 280386;
  v_dados(v_dados.last()).vr_vllanmto := 26.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83588400;
  v_dados(v_dados.last()).vr_nrctremp := 274828;
  v_dados(v_dados.last()).vr_vllanmto := 27603.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83604820;
  v_dados(v_dados.last()).vr_nrctremp := 338759;
  v_dados(v_dados.last()).vr_vllanmto := 12.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83599495;
  v_dados(v_dados.last()).vr_nrctremp := 327448;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83583394;
  v_dados(v_dados.last()).vr_nrctremp := 332260;
  v_dados(v_dados.last()).vr_vllanmto := 10.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83557962;
  v_dados(v_dados.last()).vr_nrctremp := 276164;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83559710;
  v_dados(v_dados.last()).vr_nrctremp := 276387;
  v_dados(v_dados.last()).vr_vllanmto := 24.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83556214;
  v_dados(v_dados.last()).vr_nrctremp := 339934;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83554696;
  v_dados(v_dados.last()).vr_nrctremp := 276311;
  v_dados(v_dados.last()).vr_vllanmto := 13.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83551883;
  v_dados(v_dados.last()).vr_nrctremp := 276346;
  v_dados(v_dados.last()).vr_vllanmto := 42871;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83534423;
  v_dados(v_dados.last()).vr_nrctremp := 278653;
  v_dados(v_dados.last()).vr_vllanmto := 33.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83534423;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 2074.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83508805;
  v_dados(v_dados.last()).vr_nrctremp := 278584;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83469273;
  v_dados(v_dados.last()).vr_nrctremp := 279611;
  v_dados(v_dados.last()).vr_vllanmto := 1272.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83438904;
  v_dados(v_dados.last()).vr_nrctremp := 295168;
  v_dados(v_dados.last()).vr_vllanmto := 18.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83460624;
  v_dados(v_dados.last()).vr_nrctremp := 280213;
  v_dados(v_dados.last()).vr_vllanmto := 41.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83460624;
  v_dados(v_dados.last()).vr_nrctremp := 303129;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83460624;
  v_dados(v_dados.last()).vr_nrctremp := 358358;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83425543;
  v_dados(v_dados.last()).vr_nrctremp := 338716;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83403752;
  v_dados(v_dados.last()).vr_nrctremp := 282370;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83403396;
  v_dados(v_dados.last()).vr_nrctremp := 353613;
  v_dados(v_dados.last()).vr_vllanmto := 15.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83395512;
  v_dados(v_dados.last()).vr_nrctremp := 282908;
  v_dados(v_dados.last()).vr_vllanmto := 27.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83375872;
  v_dados(v_dados.last()).vr_nrctremp := 323318;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83293558;
  v_dados(v_dados.last()).vr_nrctremp := 287145;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83356460;
  v_dados(v_dados.last()).vr_nrctremp := 285851;
  v_dados(v_dados.last()).vr_vllanmto := 12.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83285628;
  v_dados(v_dados.last()).vr_nrctremp := 286841;
  v_dados(v_dados.last()).vr_vllanmto := 11.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83261354;
  v_dados(v_dados.last()).vr_nrctremp := 287882;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83255591;
  v_dados(v_dados.last()).vr_nrctremp := 288036;
  v_dados(v_dados.last()).vr_vllanmto := 200.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83255591;
  v_dados(v_dados.last()).vr_nrctremp := 302386;
  v_dados(v_dados.last()).vr_vllanmto := 276.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83253840;
  v_dados(v_dados.last()).vr_nrctremp := 288570;
  v_dados(v_dados.last()).vr_vllanmto := 15.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83208429;
  v_dados(v_dados.last()).vr_nrctremp := 313594;
  v_dados(v_dados.last()).vr_vllanmto := 12.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83233695;
  v_dados(v_dados.last()).vr_nrctremp := 345132;
  v_dados(v_dados.last()).vr_vllanmto := 15.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83227121;
  v_dados(v_dados.last()).vr_nrctremp := 327530;
  v_dados(v_dados.last()).vr_vllanmto := 21.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83203362;
  v_dados(v_dados.last()).vr_nrctremp := 290817;
  v_dados(v_dados.last()).vr_vllanmto := 89.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83170529;
  v_dados(v_dados.last()).vr_nrctremp := 291230;
  v_dados(v_dados.last()).vr_vllanmto := 30.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83138374;
  v_dados(v_dados.last()).vr_nrctremp := 292409;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83099727;
  v_dados(v_dados.last()).vr_nrctremp := 312918;
  v_dados(v_dados.last()).vr_vllanmto := 20.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83115366;
  v_dados(v_dados.last()).vr_nrctremp := 296003;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83110895;
  v_dados(v_dados.last()).vr_nrctremp := 293529;
  v_dados(v_dados.last()).vr_vllanmto := 35.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83094962;
  v_dados(v_dados.last()).vr_nrctremp := 338282;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83087702;
  v_dados(v_dados.last()).vr_nrctremp := 300294;
  v_dados(v_dados.last()).vr_vllanmto := 35.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83080058;
  v_dados(v_dados.last()).vr_nrctremp := 294398;
  v_dados(v_dados.last()).vr_vllanmto := 1185.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83045619;
  v_dados(v_dados.last()).vr_nrctremp := 327658;
  v_dados(v_dados.last()).vr_vllanmto := 27.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83043012;
  v_dados(v_dados.last()).vr_nrctremp := 295725;
  v_dados(v_dados.last()).vr_vllanmto := 16.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83042474;
  v_dados(v_dados.last()).vr_nrctremp := 296998;
  v_dados(v_dados.last()).vr_vllanmto := 10.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83001310;
  v_dados(v_dados.last()).vr_nrctremp := 326258;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83041974;
  v_dados(v_dados.last()).vr_nrctremp := 295964;
  v_dados(v_dados.last()).vr_vllanmto := 20.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83001310;
  v_dados(v_dados.last()).vr_nrctremp := 350150;
  v_dados(v_dados.last()).vr_vllanmto := 12.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82993610;
  v_dados(v_dados.last()).vr_nrctremp := 336516;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82977518;
  v_dados(v_dados.last()).vr_nrctremp := 343806;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82971730;
  v_dados(v_dados.last()).vr_nrctremp := 331935;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82964084;
  v_dados(v_dados.last()).vr_nrctremp := 312550;
  v_dados(v_dados.last()).vr_vllanmto := 357.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82956499;
  v_dados(v_dados.last()).vr_nrctremp := 298796;
  v_dados(v_dados.last()).vr_vllanmto := 90677.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82950989;
  v_dados(v_dados.last()).vr_nrctremp := 318419;
  v_dados(v_dados.last()).vr_vllanmto := 397.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82943478;
  v_dados(v_dados.last()).vr_nrctremp := 316770;
  v_dados(v_dados.last()).vr_vllanmto := 29.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82941211;
  v_dados(v_dados.last()).vr_nrctremp := 299370;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82881502;
  v_dados(v_dados.last()).vr_nrctremp := 301392;
  v_dados(v_dados.last()).vr_vllanmto := 12.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82906777;
  v_dados(v_dados.last()).vr_nrctremp := 337793;
  v_dados(v_dados.last()).vr_vllanmto := 14.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82899665;
  v_dados(v_dados.last()).vr_nrctremp := 304869;
  v_dados(v_dados.last()).vr_vllanmto := 14.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82863202;
  v_dados(v_dados.last()).vr_nrctremp := 302270;
  v_dados(v_dados.last()).vr_vllanmto := 1655.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82853150;
  v_dados(v_dados.last()).vr_nrctremp := 326978;
  v_dados(v_dados.last()).vr_vllanmto := 45652.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82822816;
  v_dados(v_dados.last()).vr_nrctremp := 303303;
  v_dados(v_dados.last()).vr_vllanmto := 36.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82730342;
  v_dados(v_dados.last()).vr_nrctremp := 308749;
  v_dados(v_dados.last()).vr_vllanmto := 41.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82776091;
  v_dados(v_dados.last()).vr_nrctremp := 304842;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82618488;
  v_dados(v_dados.last()).vr_nrctremp := 312637;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82654069;
  v_dados(v_dados.last()).vr_nrctremp := 311394;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82654050;
  v_dados(v_dados.last()).vr_nrctremp := 309336;
  v_dados(v_dados.last()).vr_vllanmto := 512.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82642710;
  v_dados(v_dados.last()).vr_nrctremp := 309800;
  v_dados(v_dados.last()).vr_vllanmto := 13.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82555923;
  v_dados(v_dados.last()).vr_nrctremp := 315537;
  v_dados(v_dados.last()).vr_vllanmto := 21.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82590117;
  v_dados(v_dados.last()).vr_nrctremp := 312025;
  v_dados(v_dados.last()).vr_vllanmto := 10.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82555923;
  v_dados(v_dados.last()).vr_nrctremp := 356639;
  v_dados(v_dados.last()).vr_vllanmto := 15.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82543658;
  v_dados(v_dados.last()).vr_nrctremp := 314605;
  v_dados(v_dados.last()).vr_vllanmto := 13.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82543658;
  v_dados(v_dados.last()).vr_nrctremp := 323717;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82523592;
  v_dados(v_dados.last()).vr_nrctremp := 319165;
  v_dados(v_dados.last()).vr_vllanmto := 20.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82539430;
  v_dados(v_dados.last()).vr_nrctremp := 353895;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82522111;
  v_dados(v_dados.last()).vr_nrctremp := 350847;
  v_dados(v_dados.last()).vr_vllanmto := 849.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82516952;
  v_dados(v_dados.last()).vr_nrctremp := 317294;
  v_dados(v_dados.last()).vr_vllanmto := 19.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82487561;
  v_dados(v_dados.last()).vr_nrctremp := 317861;
  v_dados(v_dados.last()).vr_vllanmto := 17.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82477973;
  v_dados(v_dados.last()).vr_nrctremp := 316349;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82462895;
  v_dados(v_dados.last()).vr_nrctremp := 354747;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82452520;
  v_dados(v_dados.last()).vr_nrctremp := 322170;
  v_dados(v_dados.last()).vr_vllanmto := 14.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82400644;
  v_dados(v_dados.last()).vr_nrctremp := 321686;
  v_dados(v_dados.last()).vr_vllanmto := 11.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82401454;
  v_dados(v_dados.last()).vr_nrctremp := 331905;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82400644;
  v_dados(v_dados.last()).vr_nrctremp := 326594;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82382204;
  v_dados(v_dados.last()).vr_nrctremp := 346203;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82377758;
  v_dados(v_dados.last()).vr_nrctremp := 320697;
  v_dados(v_dados.last()).vr_vllanmto := 26.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82376662;
  v_dados(v_dados.last()).vr_nrctremp := 333073;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82368171;
  v_dados(v_dados.last()).vr_nrctremp := 320008;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82367841;
  v_dados(v_dados.last()).vr_nrctremp := 357985;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82366349;
  v_dados(v_dados.last()).vr_nrctremp := 328134;
  v_dados(v_dados.last()).vr_vllanmto := 13.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82366349;
  v_dados(v_dados.last()).vr_nrctremp := 355755;
  v_dados(v_dados.last()).vr_vllanmto := 94.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82359121;
  v_dados(v_dados.last()).vr_nrctremp := 347263;
  v_dados(v_dados.last()).vr_vllanmto := 31.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82339686;
  v_dados(v_dados.last()).vr_nrctremp := 321404;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82265410;
  v_dados(v_dados.last()).vr_nrctremp := 323823;
  v_dados(v_dados.last()).vr_vllanmto := 22.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82277141;
  v_dados(v_dados.last()).vr_nrctremp := 327477;
  v_dados(v_dados.last()).vr_vllanmto := 31.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82277141;
  v_dados(v_dados.last()).vr_nrctremp := 327479;
  v_dados(v_dados.last()).vr_vllanmto := 24.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82270414;
  v_dados(v_dados.last()).vr_nrctremp := 323638;
  v_dados(v_dados.last()).vr_vllanmto := 20.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82257400;
  v_dados(v_dados.last()).vr_nrctremp := 326231;
  v_dados(v_dados.last()).vr_vllanmto := 22.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82234590;
  v_dados(v_dados.last()).vr_nrctremp := 348752;
  v_dados(v_dados.last()).vr_vllanmto := 30.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82227020;
  v_dados(v_dados.last()).vr_nrctremp := 328581;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82230153;
  v_dados(v_dados.last()).vr_nrctremp := 330116;
  v_dados(v_dados.last()).vr_vllanmto := 27.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82230153;
  v_dados(v_dados.last()).vr_nrctremp := 330118;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82230153;
  v_dados(v_dados.last()).vr_nrctremp := 330865;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82191417;
  v_dados(v_dados.last()).vr_nrctremp := 326677;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82183627;
  v_dados(v_dados.last()).vr_nrctremp := 327040;
  v_dados(v_dados.last()).vr_vllanmto := 22.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82183503;
  v_dados(v_dados.last()).vr_nrctremp := 337979;
  v_dados(v_dados.last()).vr_vllanmto := 12.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82170533;
  v_dados(v_dados.last()).vr_nrctremp := 330208;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82170533;
  v_dados(v_dados.last()).vr_nrctremp := 340353;
  v_dados(v_dados.last()).vr_vllanmto := 36.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82160929;
  v_dados(v_dados.last()).vr_nrctremp := 332387;
  v_dados(v_dados.last()).vr_vllanmto := 19.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82158169;
  v_dados(v_dados.last()).vr_nrctremp := 354319;
  v_dados(v_dados.last()).vr_vllanmto := 32.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82091722;
  v_dados(v_dados.last()).vr_nrctremp := 340515;
  v_dados(v_dados.last()).vr_vllanmto := 26.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82115672;
  v_dados(v_dados.last()).vr_nrctremp := 335291;
  v_dados(v_dados.last()).vr_vllanmto := 18.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82115672;
  v_dados(v_dados.last()).vr_nrctremp := 338134;
  v_dados(v_dados.last()).vr_vllanmto := 17.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82091722;
  v_dados(v_dados.last()).vr_nrctremp := 340529;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82084939;
  v_dados(v_dados.last()).vr_nrctremp := 330565;
  v_dados(v_dados.last()).vr_vllanmto := 19.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82035180;
  v_dados(v_dados.last()).vr_nrctremp := 335453;
  v_dados(v_dados.last()).vr_vllanmto := 36.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81979959;
  v_dados(v_dados.last()).vr_nrctremp := 351867;
  v_dados(v_dados.last()).vr_vllanmto := 19.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81843453;
  v_dados(v_dados.last()).vr_nrctremp := 339580;
  v_dados(v_dados.last()).vr_vllanmto := 15.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81836074;
  v_dados(v_dados.last()).vr_nrctremp := 341420;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81731280;
  v_dados(v_dados.last()).vr_nrctremp := 344382;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81763255;
  v_dados(v_dados.last()).vr_nrctremp := 344786;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81759215;
  v_dados(v_dados.last()).vr_nrctremp := 351759;
  v_dados(v_dados.last()).vr_vllanmto := 25.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81652500;
  v_dados(v_dados.last()).vr_nrctremp := 346490;
  v_dados(v_dados.last()).vr_vllanmto := 16.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81606958;
  v_dados(v_dados.last()).vr_nrctremp := 348330;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81641877;
  v_dados(v_dados.last()).vr_nrctremp := 346686;
  v_dados(v_dados.last()).vr_vllanmto := 16.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81622805;
  v_dados(v_dados.last()).vr_nrctremp := 347382;
  v_dados(v_dados.last()).vr_vllanmto := 12.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81606958;
  v_dados(v_dados.last()).vr_nrctremp := 348327;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81606427;
  v_dados(v_dados.last()).vr_nrctremp := 347757;
  v_dados(v_dados.last()).vr_vllanmto := 12.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81594429;
  v_dados(v_dados.last()).vr_nrctremp := 357431;
  v_dados(v_dados.last()).vr_vllanmto := 41.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81591918;
  v_dados(v_dados.last()).vr_nrctremp := 355393;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81581661;
  v_dados(v_dados.last()).vr_nrctremp := 348986;
  v_dados(v_dados.last()).vr_vllanmto := 17.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81575203;
  v_dados(v_dados.last()).vr_nrctremp := 348879;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81556586;
  v_dados(v_dados.last()).vr_nrctremp := 356983;
  v_dados(v_dados.last()).vr_vllanmto := 104185.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81544855;
  v_dados(v_dados.last()).vr_nrctremp := 350156;
  v_dados(v_dados.last()).vr_vllanmto := 18.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81527411;
  v_dados(v_dados.last()).vr_nrctremp := 358066;
  v_dados(v_dados.last()).vr_vllanmto := 24.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350688;
  v_dados(v_dados.last()).vr_vllanmto := 16696.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350692;
  v_dados(v_dados.last()).vr_vllanmto := 17393.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350695;
  v_dados(v_dados.last()).vr_vllanmto := 12801.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 358982;
  v_dados(v_dados.last()).vr_vllanmto := 27.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81464029;
  v_dados(v_dados.last()).vr_nrctremp := 352527;
  v_dados(v_dados.last()).vr_vllanmto := 1926.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81477805;
  v_dados(v_dados.last()).vr_nrctremp := 351974;
  v_dados(v_dados.last()).vr_vllanmto := 10.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81470053;
  v_dados(v_dados.last()).vr_nrctremp := 354594;
  v_dados(v_dados.last()).vr_vllanmto := 33.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81464029;
  v_dados(v_dados.last()).vr_nrctremp := 355045;
  v_dados(v_dados.last()).vr_vllanmto := 1893.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81464029;
  v_dados(v_dados.last()).vr_nrctremp := 355046;
  v_dados(v_dados.last()).vr_vllanmto := 7719.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81464029;
  v_dados(v_dados.last()).vr_nrctremp := 361594;
  v_dados(v_dados.last()).vr_vllanmto := 12844.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81459416;
  v_dados(v_dados.last()).vr_nrctremp := 359184;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81452527;
  v_dados(v_dados.last()).vr_nrctremp := 357313;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81451377;
  v_dados(v_dados.last()).vr_nrctremp := 352939;
  v_dados(v_dados.last()).vr_vllanmto := 16.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81449704;
  v_dados(v_dados.last()).vr_nrctremp := 354263;
  v_dados(v_dados.last()).vr_vllanmto := 36.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81445210;
  v_dados(v_dados.last()).vr_nrctremp := 354604;
  v_dados(v_dados.last()).vr_vllanmto := 20.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81421214;
  v_dados(v_dados.last()).vr_nrctremp := 353931;
  v_dados(v_dados.last()).vr_vllanmto := 45.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81421010;
  v_dados(v_dados.last()).vr_nrctremp := 354155;
  v_dados(v_dados.last()).vr_vllanmto := 16.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81421010;
  v_dados(v_dados.last()).vr_nrctremp := 354162;
  v_dados(v_dados.last()).vr_vllanmto := 11.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81399014;
  v_dados(v_dados.last()).vr_nrctremp := 354971;
  v_dados(v_dados.last()).vr_vllanmto := 89462.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81399014;
  v_dados(v_dados.last()).vr_nrctremp := 358739;
  v_dados(v_dados.last()).vr_vllanmto := 37.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81379706;
  v_dados(v_dados.last()).vr_nrctremp := 355656;
  v_dados(v_dados.last()).vr_vllanmto := 72953.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81379706;
  v_dados(v_dados.last()).vr_nrctremp := 355894;
  v_dados(v_dados.last()).vr_vllanmto := 185896;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81379200;
  v_dados(v_dados.last()).vr_nrctremp := 355663;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81375964;
  v_dados(v_dados.last()).vr_nrctremp := 356105;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81366310;
  v_dados(v_dados.last()).vr_nrctremp := 356379;
  v_dados(v_dados.last()).vr_vllanmto := 13.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81346980;
  v_dados(v_dados.last()).vr_nrctremp := 358955;
  v_dados(v_dados.last()).vr_vllanmto := 17.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81342756;
  v_dados(v_dados.last()).vr_nrctremp := 358102;
  v_dados(v_dados.last()).vr_vllanmto := 195277.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81125097;
  v_dados(v_dados.last()).vr_nrctremp := 364272;
  v_dados(v_dados.last()).vr_vllanmto := 4180.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81254075;
  v_dados(v_dados.last()).vr_nrctremp := 359802;
  v_dados(v_dados.last()).vr_vllanmto := 10.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99992450;
  v_dados(v_dados.last()).vr_nrctremp := 153202;
  v_dados(v_dados.last()).vr_vllanmto := 15.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99527936;
  v_dados(v_dados.last()).vr_nrctremp := 145847;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99989816;
  v_dados(v_dados.last()).vr_nrctremp := 77028;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99974614;
  v_dados(v_dados.last()).vr_nrctremp := 84338;
  v_dados(v_dados.last()).vr_vllanmto := 36.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99967693;
  v_dados(v_dados.last()).vr_nrctremp := 57479;
  v_dados(v_dados.last()).vr_vllanmto := 11933.48;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99952912;
  v_dados(v_dados.last()).vr_nrctremp := 140688;
  v_dados(v_dados.last()).vr_vllanmto := 24.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99918986;
  v_dados(v_dados.last()).vr_nrctremp := 38185;
  v_dados(v_dados.last()).vr_vllanmto := 22155.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99911477;
  v_dados(v_dados.last()).vr_nrctremp := 115450;
  v_dados(v_dados.last()).vr_vllanmto := 12.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99893231;
  v_dados(v_dados.last()).vr_nrctremp := 44726;
  v_dados(v_dados.last()).vr_vllanmto := 12.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99892332;
  v_dados(v_dados.last()).vr_nrctremp := 130382;
  v_dados(v_dados.last()).vr_vllanmto := 10.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99887541;
  v_dados(v_dados.last()).vr_nrctremp := 156341;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99871831;
  v_dados(v_dados.last()).vr_nrctremp := 134093;
  v_dados(v_dados.last()).vr_vllanmto := 14.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99869900;
  v_dados(v_dados.last()).vr_nrctremp := 75961;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99868695;
  v_dados(v_dados.last()).vr_nrctremp := 144074;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99868067;
  v_dados(v_dados.last()).vr_nrctremp := 98090;
  v_dados(v_dados.last()).vr_vllanmto := 168.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99854449;
  v_dados(v_dados.last()).vr_nrctremp := 111029;
  v_dados(v_dados.last()).vr_vllanmto := 23.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99837846;
  v_dados(v_dados.last()).vr_nrctremp := 133342;
  v_dados(v_dados.last()).vr_vllanmto := 25.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99833620;
  v_dados(v_dados.last()).vr_nrctremp := 145593;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99833069;
  v_dados(v_dados.last()).vr_nrctremp := 139948;
  v_dados(v_dados.last()).vr_vllanmto := 27.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99826380;
  v_dados(v_dados.last()).vr_nrctremp := 158364;
  v_dados(v_dados.last()).vr_vllanmto := 10.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99822997;
  v_dados(v_dados.last()).vr_nrctremp := 127620;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99814790;
  v_dados(v_dados.last()).vr_nrctremp := 142023;
  v_dados(v_dados.last()).vr_vllanmto := 17.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99787547;
  v_dados(v_dados.last()).vr_nrctremp := 136872;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99784459;
  v_dados(v_dados.last()).vr_nrctremp := 159694;
  v_dados(v_dados.last()).vr_vllanmto := 20.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99778629;
  v_dados(v_dados.last()).vr_nrctremp := 155710;
  v_dados(v_dados.last()).vr_vllanmto := 19.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99774895;
  v_dados(v_dados.last()).vr_nrctremp := 158985;
  v_dados(v_dados.last()).vr_vllanmto := 25.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99770881;
  v_dados(v_dados.last()).vr_nrctremp := 35468;
  v_dados(v_dados.last()).vr_vllanmto := 79.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99735407;
  v_dados(v_dados.last()).vr_nrctremp := 80922;
  v_dados(v_dados.last()).vr_vllanmto := 1747.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99722780;
  v_dados(v_dados.last()).vr_nrctremp := 42448;
  v_dados(v_dados.last()).vr_vllanmto := 976.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99721864;
  v_dados(v_dados.last()).vr_nrctremp := 117072;
  v_dados(v_dados.last()).vr_vllanmto := 15.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99718529;
  v_dados(v_dados.last()).vr_nrctremp := 42281;
  v_dados(v_dados.last()).vr_vllanmto := 87.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99718529;
  v_dados(v_dados.last()).vr_nrctremp := 49691;
  v_dados(v_dados.last()).vr_vllanmto := 38.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99667479;
  v_dados(v_dados.last()).vr_nrctremp := 45846;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99667100;
  v_dados(v_dados.last()).vr_nrctremp := 92139;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99666510;
  v_dados(v_dados.last()).vr_nrctremp := 51196;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99666120;
  v_dados(v_dados.last()).vr_nrctremp := 67729;
  v_dados(v_dados.last()).vr_vllanmto := 27.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99665662;
  v_dados(v_dados.last()).vr_nrctremp := 108638;
  v_dados(v_dados.last()).vr_vllanmto := 12439.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99649438;
  v_dados(v_dados.last()).vr_nrctremp := 106560;
  v_dados(v_dados.last()).vr_vllanmto := 31.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99639017;
  v_dados(v_dados.last()).vr_nrctremp := 62245;
  v_dados(v_dados.last()).vr_vllanmto := 2665.61;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99639017;
  v_dados(v_dados.last()).vr_nrctremp := 73782;
  v_dados(v_dados.last()).vr_vllanmto := 5629.6;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99636654;
  v_dados(v_dados.last()).vr_nrctremp := 77990;
  v_dados(v_dados.last()).vr_vllanmto := 2711.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99633876;
  v_dados(v_dados.last()).vr_nrctremp := 97216;
  v_dados(v_dados.last()).vr_vllanmto := 15457.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99608405;
  v_dados(v_dados.last()).vr_nrctremp := 133217;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99593475;
  v_dados(v_dados.last()).vr_nrctremp := 152180;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99584760;
  v_dados(v_dados.last()).vr_nrctremp := 147184;
  v_dados(v_dados.last()).vr_vllanmto := 16.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99584611;
  v_dados(v_dados.last()).vr_nrctremp := 131807;
  v_dados(v_dados.last()).vr_vllanmto := 15.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99584115;
  v_dados(v_dados.last()).vr_nrctremp := 150450;
  v_dados(v_dados.last()).vr_vllanmto := 31.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99570971;
  v_dados(v_dados.last()).vr_nrctremp := 144975;
  v_dados(v_dados.last()).vr_vllanmto := 10.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99569450;
  v_dados(v_dados.last()).vr_nrctremp := 153760;
  v_dados(v_dados.last()).vr_vllanmto := 14.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99559200;
  v_dados(v_dados.last()).vr_nrctremp := 130493;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99555018;
  v_dados(v_dados.last()).vr_nrctremp := 152074;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99521504;
  v_dados(v_dados.last()).vr_nrctremp := 152328;
  v_dados(v_dados.last()).vr_vllanmto := 242.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99521504;
  v_dados(v_dados.last()).vr_nrctremp := 160251;
  v_dados(v_dados.last()).vr_vllanmto := 230.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84487836;
  v_dados(v_dados.last()).vr_nrctremp := 102852;
  v_dados(v_dados.last()).vr_vllanmto := 83.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84134836;
  v_dados(v_dados.last()).vr_nrctremp := 122891;
  v_dados(v_dados.last()).vr_vllanmto := 24.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 85451142;
  v_dados(v_dados.last()).vr_nrctremp := 110120;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 85282898;
  v_dados(v_dados.last()).vr_nrctremp := 160300;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 85200573;
  v_dados(v_dados.last()).vr_nrctremp := 67446;
  v_dados(v_dados.last()).vr_vllanmto := 87.66;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84939249;
  v_dados(v_dados.last()).vr_nrctremp := 135713;
  v_dados(v_dados.last()).vr_vllanmto := 17.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84632879;
  v_dados(v_dados.last()).vr_nrctremp := 98058;
  v_dados(v_dados.last()).vr_vllanmto := 2095.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84536098;
  v_dados(v_dados.last()).vr_nrctremp := 146748;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84532637;
  v_dados(v_dados.last()).vr_nrctremp := 146366;
  v_dados(v_dados.last()).vr_vllanmto := 17.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84530766;
  v_dados(v_dados.last()).vr_nrctremp := 162045;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84530189;
  v_dados(v_dados.last()).vr_nrctremp := 99358;
  v_dados(v_dados.last()).vr_vllanmto := 24.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84527773;
  v_dados(v_dados.last()).vr_nrctremp := 110702;
  v_dados(v_dados.last()).vr_vllanmto := 12.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84522313;
  v_dados(v_dados.last()).vr_nrctremp := 120195;
  v_dados(v_dados.last()).vr_vllanmto := 11.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84509562;
  v_dados(v_dados.last()).vr_nrctremp := 108330;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84509465;
  v_dados(v_dados.last()).vr_nrctremp := 126373;
  v_dados(v_dados.last()).vr_vllanmto := 20572.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84505109;
  v_dados(v_dados.last()).vr_nrctremp := 129721;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84505060;
  v_dados(v_dados.last()).vr_nrctremp := 119378;
  v_dados(v_dados.last()).vr_vllanmto := 14.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84497858;
  v_dados(v_dados.last()).vr_nrctremp := 97453;
  v_dados(v_dados.last()).vr_vllanmto := 14.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84496231;
  v_dados(v_dados.last()).vr_nrctremp := 116772;
  v_dados(v_dados.last()).vr_vllanmto := 28.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84489766;
  v_dados(v_dados.last()).vr_nrctremp := 112870;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84489740;
  v_dados(v_dados.last()).vr_nrctremp := 139546;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84487941;
  v_dados(v_dados.last()).vr_nrctremp := 102566;
  v_dados(v_dados.last()).vr_vllanmto := 105.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84487712;
  v_dados(v_dados.last()).vr_nrctremp := 111548;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84487682;
  v_dados(v_dados.last()).vr_nrctremp := 123119;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84416750;
  v_dados(v_dados.last()).vr_nrctremp := 127838;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84316152;
  v_dados(v_dados.last()).vr_nrctremp := 130679;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84298839;
  v_dados(v_dados.last()).vr_nrctremp := 125027;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84278161;
  v_dados(v_dados.last()).vr_nrctremp := 120051;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84240822;
  v_dados(v_dados.last()).vr_nrctremp := 123580;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84172339;
  v_dados(v_dados.last()).vr_nrctremp := 107083;
  v_dados(v_dados.last()).vr_vllanmto := 2275.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84167530;
  v_dados(v_dados.last()).vr_nrctremp := 115583;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84109149;
  v_dados(v_dados.last()).vr_nrctremp := 120199;
  v_dados(v_dados.last()).vr_vllanmto := 16.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83849440;
  v_dados(v_dados.last()).vr_nrctremp := 155688;
  v_dados(v_dados.last()).vr_vllanmto := 12.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83798587;
  v_dados(v_dados.last()).vr_nrctremp := 107408;
  v_dados(v_dados.last()).vr_vllanmto := 2585.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83719130;
  v_dados(v_dados.last()).vr_nrctremp := 138223;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83699996;
  v_dados(v_dados.last()).vr_nrctremp := 147767;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83576754;
  v_dados(v_dados.last()).vr_nrctremp := 127166;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 82166048;
  v_dados(v_dados.last()).vr_nrctremp := 161060;
  v_dados(v_dados.last()).vr_vllanmto := 14.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 81742711;
  v_dados(v_dados.last()).vr_nrctremp := 152446;
  v_dados(v_dados.last()).vr_vllanmto := 14.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 81342144;
  v_dados(v_dados.last()).vr_nrctremp := 161105;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 81249390;
  v_dados(v_dados.last()).vr_nrctremp := 163124;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
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
