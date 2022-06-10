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
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 394920;
    v_dados(v_dados.last()).vr_nrctremp := 51265;
    v_dados(v_dados.last()).vr_vllanmto := 50.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 394920;
    v_dados(v_dados.last()).vr_nrctremp := 51265;
    v_dados(v_dados.last()).vr_vllanmto := 45.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 387606;
    v_dados(v_dados.last()).vr_nrctremp := 51788;
    v_dados(v_dados.last()).vr_vllanmto := 52.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 387606;
    v_dados(v_dados.last()).vr_nrctremp := 51788;
    v_dados(v_dados.last()).vr_vllanmto := 47.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 397083;
    v_dados(v_dados.last()).vr_nrctremp := 51918;
    v_dados(v_dados.last()).vr_vllanmto := 52.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 397083;
    v_dados(v_dados.last()).vr_nrctremp := 51918;
    v_dados(v_dados.last()).vr_vllanmto := 47.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 339199;
    v_dados(v_dados.last()).vr_nrctremp := 52014;
    v_dados(v_dados.last()).vr_vllanmto := 52.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 339199;
    v_dados(v_dados.last()).vr_nrctremp := 52014;
    v_dados(v_dados.last()).vr_vllanmto := 47.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 204188;
    v_dados(v_dados.last()).vr_nrctremp := 52517;
    v_dados(v_dados.last()).vr_vllanmto := 53.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 204188;
    v_dados(v_dados.last()).vr_nrctremp := 52517;
    v_dados(v_dados.last()).vr_vllanmto := 163.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 210994;
    v_dados(v_dados.last()).vr_nrctremp := 52715;
    v_dados(v_dados.last()).vr_vllanmto := 62.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 210994;
    v_dados(v_dados.last()).vr_nrctremp := 52715;
    v_dados(v_dados.last()).vr_vllanmto := 56.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 401250;
    v_dados(v_dados.last()).vr_nrctremp := 53319;
    v_dados(v_dados.last()).vr_vllanmto := 51.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 401250;
    v_dados(v_dados.last()).vr_nrctremp := 53319;
    v_dados(v_dados.last()).vr_vllanmto := 47.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 402206;
    v_dados(v_dados.last()).vr_nrctremp := 53507;
    v_dados(v_dados.last()).vr_vllanmto := 55.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 402206;
    v_dados(v_dados.last()).vr_nrctremp := 53507;
    v_dados(v_dados.last()).vr_vllanmto := 50.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 406953;
    v_dados(v_dados.last()).vr_nrctremp := 54345;
    v_dados(v_dados.last()).vr_vllanmto := 27.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 297283;
    v_dados(v_dados.last()).vr_nrctremp := 54417;
    v_dados(v_dados.last()).vr_vllanmto := 12.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 297283;
    v_dados(v_dados.last()).vr_nrctremp := 54417;
    v_dados(v_dados.last()).vr_vllanmto := 26.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 206768;
    v_dados(v_dados.last()).vr_nrctremp := 54456;
    v_dados(v_dados.last()).vr_vllanmto := 59.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 206768;
    v_dados(v_dados.last()).vr_nrctremp := 54456;
    v_dados(v_dados.last()).vr_vllanmto := 53.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 413909;
    v_dados(v_dados.last()).vr_nrctremp := 55040;
    v_dados(v_dados.last()).vr_vllanmto := 56.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 413909;
    v_dados(v_dados.last()).vr_nrctremp := 55040;
    v_dados(v_dados.last()).vr_vllanmto := 51.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 363030;
    v_dados(v_dados.last()).vr_nrctremp := 55689;
    v_dados(v_dados.last()).vr_vllanmto := 14.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 363030;
    v_dados(v_dados.last()).vr_nrctremp := 55689;
    v_dados(v_dados.last()).vr_vllanmto := 13.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 403903;
    v_dados(v_dados.last()).vr_nrctremp := 55860;
    v_dados(v_dados.last()).vr_vllanmto := 11.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 403903;
    v_dados(v_dados.last()).vr_nrctremp := 55860;
    v_dados(v_dados.last()).vr_vllanmto := 56.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 413291;
    v_dados(v_dados.last()).vr_nrctremp := 56214;
    v_dados(v_dados.last()).vr_vllanmto := 62.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 413291;
    v_dados(v_dados.last()).vr_nrctremp := 56214;
    v_dados(v_dados.last()).vr_vllanmto := 56.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 423912;
    v_dados(v_dados.last()).vr_nrctremp := 56496;
    v_dados(v_dados.last()).vr_vllanmto := 2.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 423912;
    v_dados(v_dados.last()).vr_nrctremp := 56496;
    v_dados(v_dados.last()).vr_vllanmto := 134.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 324043;
    v_dados(v_dados.last()).vr_nrctremp := 56552;
    v_dados(v_dados.last()).vr_vllanmto := 65.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 324043;
    v_dados(v_dados.last()).vr_nrctremp := 56552;
    v_dados(v_dados.last()).vr_vllanmto := 59.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 406929;
    v_dados(v_dados.last()).vr_nrctremp := 56747;
    v_dados(v_dados.last()).vr_vllanmto := 36.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 406929;
    v_dados(v_dados.last()).vr_nrctremp := 56747;
    v_dados(v_dados.last()).vr_vllanmto := 32.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 206750;
    v_dados(v_dados.last()).vr_nrctremp := 57881;
    v_dados(v_dados.last()).vr_vllanmto := 34.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 206750;
    v_dados(v_dados.last()).vr_nrctremp := 57881;
    v_dados(v_dados.last()).vr_vllanmto := 31.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 404136;
    v_dados(v_dados.last()).vr_nrctremp := 58419;
    v_dados(v_dados.last()).vr_vllanmto := 68.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 404136;
    v_dados(v_dados.last()).vr_nrctremp := 58419;
    v_dados(v_dados.last()).vr_vllanmto := 62.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 276324;
    v_dados(v_dados.last()).vr_nrctremp := 59493;
    v_dados(v_dados.last()).vr_vllanmto := 34.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 276324;
    v_dados(v_dados.last()).vr_nrctremp := 59493;
    v_dados(v_dados.last()).vr_vllanmto := 32.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 421456;
    v_dados(v_dados.last()).vr_nrctremp := 59997;
    v_dados(v_dados.last()).vr_vllanmto := 76.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 421456;
    v_dados(v_dados.last()).vr_nrctremp := 59997;
    v_dados(v_dados.last()).vr_vllanmto := 68.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 204153;
    v_dados(v_dados.last()).vr_nrctremp := 60465;
    v_dados(v_dados.last()).vr_vllanmto := 75.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 204153;
    v_dados(v_dados.last()).vr_nrctremp := 60465;
    v_dados(v_dados.last()).vr_vllanmto := 68.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 283231;
    v_dados(v_dados.last()).vr_nrctremp := 62610;
    v_dados(v_dados.last()).vr_vllanmto := 60.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 283231;
    v_dados(v_dados.last()).vr_nrctremp := 62610;
    v_dados(v_dados.last()).vr_vllanmto := 55.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 297283;
    v_dados(v_dados.last()).vr_nrctremp := 63342;
    v_dados(v_dados.last()).vr_vllanmto := 30.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 297283;
    v_dados(v_dados.last()).vr_nrctremp := 63342;
    v_dados(v_dados.last()).vr_vllanmto := 28.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 333425;
    v_dados(v_dados.last()).vr_nrctremp := 63378;
    v_dados(v_dados.last()).vr_vllanmto := 78.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 333425;
    v_dados(v_dados.last()).vr_nrctremp := 63378;
    v_dados(v_dados.last()).vr_vllanmto := 73.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 194034;
    v_dados(v_dados.last()).vr_nrctremp := 63823;
    v_dados(v_dados.last()).vr_vllanmto := 141.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 194034;
    v_dados(v_dados.last()).vr_nrctremp := 63823;
    v_dados(v_dados.last()).vr_vllanmto := 133.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 254029;
    v_dados(v_dados.last()).vr_nrctremp := 64002;
    v_dados(v_dados.last()).vr_vllanmto := 33.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 254029;
    v_dados(v_dados.last()).vr_nrctremp := 64002;
    v_dados(v_dados.last()).vr_vllanmto := 31.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 235032;
    v_dados(v_dados.last()).vr_nrctremp := 64074;
    v_dados(v_dados.last()).vr_vllanmto := 116.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 235032;
    v_dados(v_dados.last()).vr_nrctremp := 64074;
    v_dados(v_dados.last()).vr_vllanmto := 108.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 312916;
    v_dados(v_dados.last()).vr_nrctremp := 64169;
    v_dados(v_dados.last()).vr_vllanmto := 7.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 475785;
    v_dados(v_dados.last()).vr_nrctremp := 64306;
    v_dados(v_dados.last()).vr_vllanmto := 44.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 475785;
    v_dados(v_dados.last()).vr_nrctremp := 64306;
    v_dados(v_dados.last()).vr_vllanmto := 40.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500100;
    v_dados(v_dados.last()).vr_nrctremp := 2020025;
    v_dados(v_dados.last()).vr_vllanmto := 2.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529524;
    v_dados(v_dados.last()).vr_nrctremp := 19100179;
    v_dados(v_dados.last()).vr_vllanmto := 77.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522481;
    v_dados(v_dados.last()).vr_nrctremp := 19100457;
    v_dados(v_dados.last()).vr_vllanmto := 13.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522481;
    v_dados(v_dados.last()).vr_nrctremp := 19100457;
    v_dados(v_dados.last()).vr_vllanmto := 12.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530034;
    v_dados(v_dados.last()).vr_nrctremp := 19100662;
    v_dados(v_dados.last()).vr_vllanmto := .04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504467;
    v_dados(v_dados.last()).vr_nrctremp := 19100768;
    v_dados(v_dados.last()).vr_vllanmto := 16.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 511099;
    v_dados(v_dados.last()).vr_nrctremp := 19200692;
    v_dados(v_dados.last()).vr_vllanmto := 153.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518719;
    v_dados(v_dados.last()).vr_nrctremp := 20100152;
    v_dados(v_dados.last()).vr_vllanmto := 104.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505285;
    v_dados(v_dados.last()).vr_nrctremp := 20100206;
    v_dados(v_dados.last()).vr_vllanmto := 116.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514420;
    v_dados(v_dados.last()).vr_nrctremp := 20100224;
    v_dados(v_dados.last()).vr_vllanmto := 29.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 511358;
    v_dados(v_dados.last()).vr_nrctremp := 20100239;
    v_dados(v_dados.last()).vr_vllanmto := 6.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522988;
    v_dados(v_dados.last()).vr_nrctremp := 20100245;
    v_dados(v_dados.last()).vr_vllanmto := 31.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524026;
    v_dados(v_dados.last()).vr_nrctremp := 20100258;
    v_dados(v_dados.last()).vr_vllanmto := 20.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524026;
    v_dados(v_dados.last()).vr_nrctremp := 20100258;
    v_dados(v_dados.last()).vr_vllanmto := 19.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501743;
    v_dados(v_dados.last()).vr_nrctremp := 20100309;
    v_dados(v_dados.last()).vr_vllanmto := 2.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518565;
    v_dados(v_dados.last()).vr_nrctremp := 20100317;
    v_dados(v_dados.last()).vr_vllanmto := 5.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528587;
    v_dados(v_dados.last()).vr_nrctremp := 20100359;
    v_dados(v_dados.last()).vr_vllanmto := 6.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 513350;
    v_dados(v_dados.last()).vr_nrctremp := 20100364;
    v_dados(v_dados.last()).vr_vllanmto := 11.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 513350;
    v_dados(v_dados.last()).vr_nrctremp := 20100364;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528641;
    v_dados(v_dados.last()).vr_nrctremp := 20100365;
    v_dados(v_dados.last()).vr_vllanmto := 3.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 523925;
    v_dados(v_dados.last()).vr_nrctremp := 20100367;
    v_dados(v_dados.last()).vr_vllanmto := 10.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 523925;
    v_dados(v_dados.last()).vr_nrctremp := 20100367;
    v_dados(v_dados.last()).vr_vllanmto := 10.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501999;
    v_dados(v_dados.last()).vr_nrctremp := 20100370;
    v_dados(v_dados.last()).vr_vllanmto := 10.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504769;
    v_dados(v_dados.last()).vr_nrctremp := 20100374;
    v_dados(v_dados.last()).vr_vllanmto := 19.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504769;
    v_dados(v_dados.last()).vr_nrctremp := 20100374;
    v_dados(v_dados.last()).vr_vllanmto := 19.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525715;
    v_dados(v_dados.last()).vr_nrctremp := 20100428;
    v_dados(v_dados.last()).vr_vllanmto := 8.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500895;
    v_dados(v_dados.last()).vr_nrctremp := 20100431;
    v_dados(v_dados.last()).vr_vllanmto := 10.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500895;
    v_dados(v_dados.last()).vr_nrctremp := 20100431;
    v_dados(v_dados.last()).vr_vllanmto := 10.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501646;
    v_dados(v_dados.last()).vr_nrctremp := 20100441;
    v_dados(v_dados.last()).vr_vllanmto := 1.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518832;
    v_dados(v_dados.last()).vr_nrctremp := 20100442;
    v_dados(v_dados.last()).vr_vllanmto := 26.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 521345;
    v_dados(v_dados.last()).vr_nrctremp := 20100445;
    v_dados(v_dados.last()).vr_vllanmto := 21.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 521345;
    v_dados(v_dados.last()).vr_nrctremp := 20100445;
    v_dados(v_dados.last()).vr_vllanmto := 19.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527440;
    v_dados(v_dados.last()).vr_nrctremp := 20100480;
    v_dados(v_dados.last()).vr_vllanmto := 1.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501557;
    v_dados(v_dados.last()).vr_nrctremp := 20100487;
    v_dados(v_dados.last()).vr_vllanmto := 1.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 515558;
    v_dados(v_dados.last()).vr_nrctremp := 20100495;
    v_dados(v_dados.last()).vr_vllanmto := 38.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 515558;
    v_dados(v_dados.last()).vr_nrctremp := 20100495;
    v_dados(v_dados.last()).vr_vllanmto := 13.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 520195;
    v_dados(v_dados.last()).vr_nrctremp := 20100497;
    v_dados(v_dados.last()).vr_vllanmto := 2.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517976;
    v_dados(v_dados.last()).vr_nrctremp := 20100502;
    v_dados(v_dados.last()).vr_vllanmto := 5.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514640;
    v_dados(v_dados.last()).vr_nrctremp := 20100508;
    v_dados(v_dados.last()).vr_vllanmto := 6.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514640;
    v_dados(v_dados.last()).vr_nrctremp := 20100508;
    v_dados(v_dados.last()).vr_vllanmto := 30.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505196;
    v_dados(v_dados.last()).vr_nrctremp := 20100526;
    v_dados(v_dados.last()).vr_vllanmto := 17.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505196;
    v_dados(v_dados.last()).vr_nrctremp := 20100526;
    v_dados(v_dados.last()).vr_vllanmto := 16.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525774;
    v_dados(v_dados.last()).vr_nrctremp := 20100533;
    v_dados(v_dados.last()).vr_vllanmto := 3.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 519650;
    v_dados(v_dados.last()).vr_nrctremp := 20100538;
    v_dados(v_dados.last()).vr_vllanmto := 31.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529133;
    v_dados(v_dados.last()).vr_nrctremp := 20100540;
    v_dados(v_dados.last()).vr_vllanmto := 47.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504939;
    v_dados(v_dados.last()).vr_nrctremp := 20100546;
    v_dados(v_dados.last()).vr_vllanmto := 52.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 511293;
    v_dados(v_dados.last()).vr_nrctremp := 20100547;
    v_dados(v_dados.last()).vr_vllanmto := 6.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514373;
    v_dados(v_dados.last()).vr_nrctremp := 20100578;
    v_dados(v_dados.last()).vr_vllanmto := 3.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502987;
    v_dados(v_dados.last()).vr_nrctremp := 20100614;
    v_dados(v_dados.last()).vr_vllanmto := 2.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502995;
    v_dados(v_dados.last()).vr_nrctremp := 20100622;
    v_dados(v_dados.last()).vr_vllanmto := 15.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502995;
    v_dados(v_dados.last()).vr_nrctremp := 20100622;
    v_dados(v_dados.last()).vr_vllanmto := 39.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 521434;
    v_dados(v_dados.last()).vr_nrctremp := 20100626;
    v_dados(v_dados.last()).vr_vllanmto := 27.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528986;
    v_dados(v_dados.last()).vr_nrctremp := 20100628;
    v_dados(v_dados.last()).vr_vllanmto := .08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522988;
    v_dados(v_dados.last()).vr_nrctremp := 20100629;
    v_dados(v_dados.last()).vr_vllanmto := 3.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522988;
    v_dados(v_dados.last()).vr_nrctremp := 20100629;
    v_dados(v_dados.last()).vr_vllanmto := 28.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 507806;
    v_dados(v_dados.last()).vr_nrctremp := 20100630;
    v_dados(v_dados.last()).vr_vllanmto := 3.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 507806;
    v_dados(v_dados.last()).vr_nrctremp := 20100630;
    v_dados(v_dados.last()).vr_vllanmto := 27.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530786;
    v_dados(v_dados.last()).vr_nrctremp := 20100634;
    v_dados(v_dados.last()).vr_vllanmto := 24.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514500;
    v_dados(v_dados.last()).vr_nrctremp := 20100648;
    v_dados(v_dados.last()).vr_vllanmto := 3.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514500;
    v_dados(v_dados.last()).vr_nrctremp := 20100648;
    v_dados(v_dados.last()).vr_vllanmto := 18.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504556;
    v_dados(v_dados.last()).vr_nrctremp := 20200022;
    v_dados(v_dados.last()).vr_vllanmto := 32.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504556;
    v_dados(v_dados.last()).vr_nrctremp := 20200022;
    v_dados(v_dados.last()).vr_vllanmto := 32.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500003;
    v_dados(v_dados.last()).vr_nrctremp := 20200023;
    v_dados(v_dados.last()).vr_vllanmto := 8.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500003;
    v_dados(v_dados.last()).vr_nrctremp := 20200023;
    v_dados(v_dados.last()).vr_vllanmto := 14.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517194;
    v_dados(v_dados.last()).vr_nrctremp := 20200024;
    v_dados(v_dados.last()).vr_vllanmto := 14.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517194;
    v_dados(v_dados.last()).vr_nrctremp := 20200024;
    v_dados(v_dados.last()).vr_vllanmto := 13.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530751;
    v_dados(v_dados.last()).vr_nrctremp := 20200318;
    v_dados(v_dados.last()).vr_vllanmto := .25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501239;
    v_dados(v_dados.last()).vr_nrctremp := 20200572;
    v_dados(v_dados.last()).vr_vllanmto := 4.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501239;
    v_dados(v_dados.last()).vr_nrctremp := 20200572;
    v_dados(v_dados.last()).vr_vllanmto := 171.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506133;
    v_dados(v_dados.last()).vr_nrctremp := 20300006;
    v_dados(v_dados.last()).vr_vllanmto := 1.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500917;
    v_dados(v_dados.last()).vr_nrctremp := 20300019;
    v_dados(v_dados.last()).vr_vllanmto := 353.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500917;
    v_dados(v_dados.last()).vr_nrctremp := 20300019;
    v_dados(v_dados.last()).vr_vllanmto := 286.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503061;
    v_dados(v_dados.last()).vr_nrctremp := 20300036;
    v_dados(v_dados.last()).vr_vllanmto := 9.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506648;
    v_dados(v_dados.last()).vr_nrctremp := 20300042;
    v_dados(v_dados.last()).vr_vllanmto := 1.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503207;
    v_dados(v_dados.last()).vr_nrctremp := 20300044;
    v_dados(v_dados.last()).vr_vllanmto := 12.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503207;
    v_dados(v_dados.last()).vr_nrctremp := 20300044;
    v_dados(v_dados.last()).vr_vllanmto := 13.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505803;
    v_dados(v_dados.last()).vr_nrctremp := 20300049;
    v_dados(v_dados.last()).vr_vllanmto := 7.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505803;
    v_dados(v_dados.last()).vr_nrctremp := 20300049;
    v_dados(v_dados.last()).vr_vllanmto := 25.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506001;
    v_dados(v_dados.last()).vr_nrctremp := 20300050;
    v_dados(v_dados.last()).vr_vllanmto := .14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503045;
    v_dados(v_dados.last()).vr_nrctremp := 20400653;
    v_dados(v_dados.last()).vr_vllanmto := 155.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505102;
    v_dados(v_dados.last()).vr_nrctremp := 21100007;
    v_dados(v_dados.last()).vr_vllanmto := 25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505102;
    v_dados(v_dados.last()).vr_nrctremp := 21100007;
    v_dados(v_dados.last()).vr_vllanmto := 5.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501948;
    v_dados(v_dados.last()).vr_nrctremp := 21100009;
    v_dados(v_dados.last()).vr_vllanmto := 19.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501948;
    v_dados(v_dados.last()).vr_nrctremp := 21100009;
    v_dados(v_dados.last()).vr_vllanmto := 14.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 516880;
    v_dados(v_dados.last()).vr_nrctremp := 21100013;
    v_dados(v_dados.last()).vr_vllanmto := 2.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518514;
    v_dados(v_dados.last()).vr_nrctremp := 21100033;
    v_dados(v_dados.last()).vr_vllanmto := 13.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518514;
    v_dados(v_dados.last()).vr_nrctremp := 21100033;
    v_dados(v_dados.last()).vr_vllanmto := 12.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 526991;
    v_dados(v_dados.last()).vr_nrctremp := 21100037;
    v_dados(v_dados.last()).vr_vllanmto := 59.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504726;
    v_dados(v_dados.last()).vr_nrctremp := 21100038;
    v_dados(v_dados.last()).vr_vllanmto := .31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504726;
    v_dados(v_dados.last()).vr_nrctremp := 21100038;
    v_dados(v_dados.last()).vr_vllanmto := 25.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524174;
    v_dados(v_dados.last()).vr_nrctremp := 21100040;
    v_dados(v_dados.last()).vr_vllanmto := 19.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524174;
    v_dados(v_dados.last()).vr_nrctremp := 21100040;
    v_dados(v_dados.last()).vr_vllanmto := 18.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504971;
    v_dados(v_dados.last()).vr_nrctremp := 21100042;
    v_dados(v_dados.last()).vr_vllanmto := 9.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518425;
    v_dados(v_dados.last()).vr_nrctremp := 21100046;
    v_dados(v_dados.last()).vr_vllanmto := 41.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518425;
    v_dados(v_dados.last()).vr_nrctremp := 21100046;
    v_dados(v_dados.last()).vr_vllanmto := 24.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522830;
    v_dados(v_dados.last()).vr_nrctremp := 21100047;
    v_dados(v_dados.last()).vr_vllanmto := .64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522830;
    v_dados(v_dados.last()).vr_nrctremp := 21100047;
    v_dados(v_dados.last()).vr_vllanmto := 22.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 521841;
    v_dados(v_dados.last()).vr_nrctremp := 21100053;
    v_dados(v_dados.last()).vr_vllanmto := 63.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528889;
    v_dados(v_dados.last()).vr_nrctremp := 21100057;
    v_dados(v_dados.last()).vr_vllanmto := 19.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528889;
    v_dados(v_dados.last()).vr_nrctremp := 21100057;
    v_dados(v_dados.last()).vr_vllanmto := 18.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524450;
    v_dados(v_dados.last()).vr_nrctremp := 21100066;
    v_dados(v_dados.last()).vr_vllanmto := 1.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527807;
    v_dados(v_dados.last()).vr_nrctremp := 21100070;
    v_dados(v_dados.last()).vr_vllanmto := 1.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503169;
    v_dados(v_dados.last()).vr_nrctremp := 21100075;
    v_dados(v_dados.last()).vr_vllanmto := 5.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 519936;
    v_dados(v_dados.last()).vr_nrctremp := 21100077;
    v_dados(v_dados.last()).vr_vllanmto := 55.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518441;
    v_dados(v_dados.last()).vr_nrctremp := 21100089;
    v_dados(v_dados.last()).vr_vllanmto := 56.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 526401;
    v_dados(v_dados.last()).vr_nrctremp := 21100090;
    v_dados(v_dados.last()).vr_vllanmto := 9.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 524310;
    v_dados(v_dados.last()).vr_nrctremp := 21100092;
    v_dados(v_dados.last()).vr_vllanmto := 28.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501573;
    v_dados(v_dados.last()).vr_nrctremp := 21100093;
    v_dados(v_dados.last()).vr_vllanmto := 147;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504297;
    v_dados(v_dados.last()).vr_nrctremp := 21100102;
    v_dados(v_dados.last()).vr_vllanmto := 23.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504297;
    v_dados(v_dados.last()).vr_nrctremp := 21100102;
    v_dados(v_dados.last()).vr_vllanmto := 49.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 526096;
    v_dados(v_dados.last()).vr_nrctremp := 21100115;
    v_dados(v_dados.last()).vr_vllanmto := 51.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 516040;
    v_dados(v_dados.last()).vr_nrctremp := 21100121;
    v_dados(v_dados.last()).vr_vllanmto := 10.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 516040;
    v_dados(v_dados.last()).vr_nrctremp := 21100121;
    v_dados(v_dados.last()).vr_vllanmto := 29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503665;
    v_dados(v_dados.last()).vr_nrctremp := 21100124;
    v_dados(v_dados.last()).vr_vllanmto := 13.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503665;
    v_dados(v_dados.last()).vr_nrctremp := 21100124;
    v_dados(v_dados.last()).vr_vllanmto := 48.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525014;
    v_dados(v_dados.last()).vr_nrctremp := 21100133;
    v_dados(v_dados.last()).vr_vllanmto := 13.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525014;
    v_dados(v_dados.last()).vr_nrctremp := 21100133;
    v_dados(v_dados.last()).vr_vllanmto := 12.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 512605;
    v_dados(v_dados.last()).vr_nrctremp := 21100134;
    v_dados(v_dados.last()).vr_vllanmto := 65.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527610;
    v_dados(v_dados.last()).vr_nrctremp := 21100135;
    v_dados(v_dados.last()).vr_vllanmto := 8.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527610;
    v_dados(v_dados.last()).vr_nrctremp := 21100135;
    v_dados(v_dados.last()).vr_vllanmto := 43.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514543;
    v_dados(v_dados.last()).vr_nrctremp := 21100138;
    v_dados(v_dados.last()).vr_vllanmto := 87.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522023;
    v_dados(v_dados.last()).vr_nrctremp := 21100140;
    v_dados(v_dados.last()).vr_vllanmto := 32.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522023;
    v_dados(v_dados.last()).vr_nrctremp := 21100140;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530263;
    v_dados(v_dados.last()).vr_nrctremp := 21100142;
    v_dados(v_dados.last()).vr_vllanmto := 3.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530263;
    v_dados(v_dados.last()).vr_nrctremp := 21100142;
    v_dados(v_dados.last()).vr_vllanmto := 11.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530263;
    v_dados(v_dados.last()).vr_nrctremp := 21100142;
    v_dados(v_dados.last()).vr_vllanmto := 11.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 531537;
    v_dados(v_dados.last()).vr_nrctremp := 21100144;
    v_dados(v_dados.last()).vr_vllanmto := 4.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505277;
    v_dados(v_dados.last()).vr_nrctremp := 21100150;
    v_dados(v_dados.last()).vr_vllanmto := 32.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504521;
    v_dados(v_dados.last()).vr_nrctremp := 21100152;
    v_dados(v_dados.last()).vr_vllanmto := 265.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 519324;
    v_dados(v_dados.last()).vr_nrctremp := 21100162;
    v_dados(v_dados.last()).vr_vllanmto := 19.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 519324;
    v_dados(v_dados.last()).vr_nrctremp := 21100162;
    v_dados(v_dados.last()).vr_vllanmto := 17.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529958;
    v_dados(v_dados.last()).vr_nrctremp := 21100163;
    v_dados(v_dados.last()).vr_vllanmto := 14.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529958;
    v_dados(v_dados.last()).vr_nrctremp := 21100163;
    v_dados(v_dados.last()).vr_vllanmto := 13.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 521396;
    v_dados(v_dados.last()).vr_nrctremp := 21100165;
    v_dados(v_dados.last()).vr_vllanmto := 21.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530026;
    v_dados(v_dados.last()).vr_nrctremp := 21100168;
    v_dados(v_dados.last()).vr_vllanmto := 2.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 520772;
    v_dados(v_dados.last()).vr_nrctremp := 21100171;
    v_dados(v_dados.last()).vr_vllanmto := 6.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525820;
    v_dados(v_dados.last()).vr_nrctremp := 21100180;
    v_dados(v_dados.last()).vr_vllanmto := 82.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525820;
    v_dados(v_dados.last()).vr_nrctremp := 21100180;
    v_dados(v_dados.last()).vr_vllanmto := 18.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529656;
    v_dados(v_dados.last()).vr_nrctremp := 21100183;
    v_dados(v_dados.last()).vr_vllanmto := 11.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529656;
    v_dados(v_dados.last()).vr_nrctremp := 21100183;
    v_dados(v_dados.last()).vr_vllanmto := 26.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500992;
    v_dados(v_dados.last()).vr_nrctremp := 21100184;
    v_dados(v_dados.last()).vr_vllanmto := 10.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504327;
    v_dados(v_dados.last()).vr_nrctremp := 21100187;
    v_dados(v_dados.last()).vr_vllanmto := 19.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504327;
    v_dados(v_dados.last()).vr_nrctremp := 21100187;
    v_dados(v_dados.last()).vr_vllanmto := 10.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 531022;
    v_dados(v_dados.last()).vr_nrctremp := 21100192;
    v_dados(v_dados.last()).vr_vllanmto := 1.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528480;
    v_dados(v_dados.last()).vr_nrctremp := 21100193;
    v_dados(v_dados.last()).vr_vllanmto := 7.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530689;
    v_dados(v_dados.last()).vr_nrctremp := 21100201;
    v_dados(v_dados.last()).vr_vllanmto := 22.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 515639;
    v_dados(v_dados.last()).vr_nrctremp := 21100207;
    v_dados(v_dados.last()).vr_vllanmto := 1.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 515639;
    v_dados(v_dados.last()).vr_nrctremp := 21100207;
    v_dados(v_dados.last()).vr_vllanmto := 118.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503185;
    v_dados(v_dados.last()).vr_nrctremp := 21100212;
    v_dados(v_dados.last()).vr_vllanmto := 4.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503185;
    v_dados(v_dados.last()).vr_nrctremp := 21100212;
    v_dados(v_dados.last()).vr_vllanmto := 14.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530069;
    v_dados(v_dados.last()).vr_nrctremp := 21100220;
    v_dados(v_dados.last()).vr_vllanmto := 23.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530069;
    v_dados(v_dados.last()).vr_nrctremp := 21100220;
    v_dados(v_dados.last()).vr_vllanmto := 21.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505757;
    v_dados(v_dados.last()).vr_nrctremp := 21100228;
    v_dados(v_dados.last()).vr_vllanmto := .4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505757;
    v_dados(v_dados.last()).vr_nrctremp := 21100228;
    v_dados(v_dados.last()).vr_vllanmto := 58.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517984;
    v_dados(v_dados.last()).vr_nrctremp := 21100236;
    v_dados(v_dados.last()).vr_vllanmto := 58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517984;
    v_dados(v_dados.last()).vr_nrctremp := 21100236;
    v_dados(v_dados.last()).vr_vllanmto := 46.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525448;
    v_dados(v_dados.last()).vr_nrctremp := 21100241;
    v_dados(v_dados.last()).vr_vllanmto := 94.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504289;
    v_dados(v_dados.last()).vr_nrctremp := 21100243;
    v_dados(v_dados.last()).vr_vllanmto := 16.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504289;
    v_dados(v_dados.last()).vr_nrctremp := 21100243;
    v_dados(v_dados.last()).vr_vllanmto := 15.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527394;
    v_dados(v_dados.last()).vr_nrctremp := 21100244;
    v_dados(v_dados.last()).vr_vllanmto := 57.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504530;
    v_dados(v_dados.last()).vr_nrctremp := 21100253;
    v_dados(v_dados.last()).vr_vllanmto := 12.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518166;
    v_dados(v_dados.last()).vr_nrctremp := 21100279;
    v_dados(v_dados.last()).vr_vllanmto := 12.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502405;
    v_dados(v_dados.last()).vr_nrctremp := 21200008;
    v_dados(v_dados.last()).vr_vllanmto := 11.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532037;
    v_dados(v_dados.last()).vr_nrctremp := 21200014;
    v_dados(v_dados.last()).vr_vllanmto := 37.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532037;
    v_dados(v_dados.last()).vr_nrctremp := 21200014;
    v_dados(v_dados.last()).vr_vllanmto := 36.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532088;
    v_dados(v_dados.last()).vr_nrctremp := 21200015;
    v_dados(v_dados.last()).vr_vllanmto := 65.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532088;
    v_dados(v_dados.last()).vr_nrctremp := 21200015;
    v_dados(v_dados.last()).vr_vllanmto := 61.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532177;
    v_dados(v_dados.last()).vr_nrctremp := 21200016;
    v_dados(v_dados.last()).vr_vllanmto := 23.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532177;
    v_dados(v_dados.last()).vr_nrctremp := 21200016;
    v_dados(v_dados.last()).vr_vllanmto := 45.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503126;
    v_dados(v_dados.last()).vr_nrctremp := 21200019;
    v_dados(v_dados.last()).vr_vllanmto := 32.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503126;
    v_dados(v_dados.last()).vr_nrctremp := 21200019;
    v_dados(v_dados.last()).vr_vllanmto := 41.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501255;
    v_dados(v_dados.last()).vr_nrctremp := 21200088;
    v_dados(v_dados.last()).vr_vllanmto := 15.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502464;
    v_dados(v_dados.last()).vr_nrctremp := 21200155;
    v_dados(v_dados.last()).vr_vllanmto := .21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506230;
    v_dados(v_dados.last()).vr_nrctremp := 21300010;
    v_dados(v_dados.last()).vr_vllanmto := .22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 533203;
    v_dados(v_dados.last()).vr_nrctremp := 21300011;
    v_dados(v_dados.last()).vr_vllanmto := 26.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 533203;
    v_dados(v_dados.last()).vr_nrctremp := 21300011;
    v_dados(v_dados.last()).vr_vllanmto := 25.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 533530;
    v_dados(v_dados.last()).vr_nrctremp := 21300015;
    v_dados(v_dados.last()).vr_vllanmto := 12.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 533530;
    v_dados(v_dados.last()).vr_nrctremp := 21300015;
    v_dados(v_dados.last()).vr_vllanmto := 11.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505382;
    v_dados(v_dados.last()).vr_nrctremp := 21300020;
    v_dados(v_dados.last()).vr_vllanmto := 30.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505382;
    v_dados(v_dados.last()).vr_nrctremp := 21300020;
    v_dados(v_dados.last()).vr_vllanmto := 28.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506087;
    v_dados(v_dados.last()).vr_nrctremp := 21300025;
    v_dados(v_dados.last()).vr_vllanmto := 90.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506087;
    v_dados(v_dados.last()).vr_nrctremp := 21300025;
    v_dados(v_dados.last()).vr_vllanmto := 58.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505927;
    v_dados(v_dados.last()).vr_nrctremp := 21300026;
    v_dados(v_dados.last()).vr_vllanmto := 17.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505927;
    v_dados(v_dados.last()).vr_nrctremp := 21300026;
    v_dados(v_dados.last()).vr_vllanmto := 16.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505358;
    v_dados(v_dados.last()).vr_nrctremp := 21300027;
    v_dados(v_dados.last()).vr_vllanmto := 9.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506192;
    v_dados(v_dados.last()).vr_nrctremp := 21300031;
    v_dados(v_dados.last()).vr_vllanmto := 5.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506192;
    v_dados(v_dados.last()).vr_nrctremp := 21300031;
    v_dados(v_dados.last()).vr_vllanmto := 2.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506133;
    v_dados(v_dados.last()).vr_nrctremp := 21300033;
    v_dados(v_dados.last()).vr_vllanmto := 18.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506133;
    v_dados(v_dados.last()).vr_nrctremp := 21300033;
    v_dados(v_dados.last()).vr_vllanmto := 17.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502928;
    v_dados(v_dados.last()).vr_nrctremp := 21300035;
    v_dados(v_dados.last()).vr_vllanmto := 45.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506320;
    v_dados(v_dados.last()).vr_nrctremp := 21300038;
    v_dados(v_dados.last()).vr_vllanmto := 7.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506613;
    v_dados(v_dados.last()).vr_nrctremp := 21300039;
    v_dados(v_dados.last()).vr_vllanmto := 14.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506613;
    v_dados(v_dados.last()).vr_nrctremp := 21300039;
    v_dados(v_dados.last()).vr_vllanmto := 13.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505129;
    v_dados(v_dados.last()).vr_nrctremp := 21300177;
    v_dados(v_dados.last()).vr_vllanmto := 3.38;
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
