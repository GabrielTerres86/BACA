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
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14205858;
  v_dados(v_dados.last()).vr_nrctremp := 117653;
  v_dados(v_dados.last()).vr_vllanmto := 14.55;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15701107;
  v_dados(v_dados.last()).vr_nrctremp := 125027;
  v_dados(v_dados.last()).vr_vllanmto := 13.74;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931314;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := .22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 211585;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 202665;
  v_dados(v_dados.last()).vr_nrctremp := 308292;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 388181;
  v_dados(v_dados.last()).vr_nrctremp := 268428;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11358700;
  v_dados(v_dados.last()).vr_nrctremp := 6080438;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14820900;
  v_dados(v_dados.last()).vr_nrctremp := 307322;
  v_dados(v_dados.last()).vr_vllanmto := 10.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8987149;
  v_dados(v_dados.last()).vr_nrctremp := 5669002;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14516209;
  v_dados(v_dados.last()).vr_nrctremp := 100522;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14130971;
  v_dados(v_dados.last()).vr_nrctremp := 261505;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15242617;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 382744;
  v_dados(v_dados.last()).vr_nrctremp := 85674;
  v_dados(v_dados.last()).vr_vllanmto := 13.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 326461;
  v_dados(v_dados.last()).vr_nrctremp := 222212;
  v_dados(v_dados.last()).vr_vllanmto := 13.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 222053;
  v_dados(v_dados.last()).vr_vllanmto := 13.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189154;
  v_dados(v_dados.last()).vr_nrctremp := 321304;
  v_dados(v_dados.last()).vr_vllanmto := 14.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13987925;
  v_dados(v_dados.last()).vr_nrctremp := 6677311;
  v_dados(v_dados.last()).vr_vllanmto := 16.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 165366;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15065537;
  v_dados(v_dados.last()).vr_nrctremp := 49900;
  v_dados(v_dados.last()).vr_vllanmto := 16.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15868176;
  v_dados(v_dados.last()).vr_nrctremp := 6959339;
  v_dados(v_dados.last()).vr_vllanmto := 16.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15758508;
  v_dados(v_dados.last()).vr_nrctremp := 112669;
  v_dados(v_dados.last()).vr_vllanmto := 17.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3790622;
  v_dados(v_dados.last()).vr_nrctremp := 4307968;
  v_dados(v_dados.last()).vr_vllanmto := 17.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 190039;
  v_dados(v_dados.last()).vr_nrctremp := 38452;
  v_dados(v_dados.last()).vr_vllanmto := 18.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 615366;
  v_dados(v_dados.last()).vr_nrctremp := 295571;
  v_dados(v_dados.last()).vr_vllanmto := 18.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 189995;
  v_dados(v_dados.last()).vr_nrctremp := 45413;
  v_dados(v_dados.last()).vr_vllanmto := 18.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 16418000;
  v_dados(v_dados.last()).vr_nrctremp := 715792;
  v_dados(v_dados.last()).vr_vllanmto := 18.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14180774;
  v_dados(v_dados.last()).vr_nrctremp := 7089998;
  v_dados(v_dados.last()).vr_vllanmto := 18.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13160940;
  v_dados(v_dados.last()).vr_nrctremp := 6224558;
  v_dados(v_dados.last()).vr_vllanmto := 19.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 359238;
  v_dados(v_dados.last()).vr_nrctremp := 274385;
  v_dados(v_dados.last()).vr_vllanmto := 19.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 526010;
  v_dados(v_dados.last()).vr_nrctremp := 90126;
  v_dados(v_dados.last()).vr_vllanmto := 20.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15641562;
  v_dados(v_dados.last()).vr_nrctremp := 112127;
  v_dados(v_dados.last()).vr_vllanmto := 20.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 194673;
  v_dados(v_dados.last()).vr_vllanmto := 21.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16651359;
  v_dados(v_dados.last()).vr_nrctremp := 104619;
  v_dados(v_dados.last()).vr_vllanmto := 21.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 720550;
  v_dados(v_dados.last()).vr_nrctremp := 283467;
  v_dados(v_dados.last()).vr_vllanmto := 21.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 185908;
  v_dados(v_dados.last()).vr_vllanmto := 22.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 6631120;
  v_dados(v_dados.last()).vr_vllanmto := 23.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16272552;
  v_dados(v_dados.last()).vr_nrctremp := 100149;
  v_dados(v_dados.last()).vr_vllanmto := 23.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14507749;
  v_dados(v_dados.last()).vr_nrctremp := 77826;
  v_dados(v_dados.last()).vr_vllanmto := 24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9575448;
  v_dados(v_dados.last()).vr_nrctremp := 4535138;
  v_dados(v_dados.last()).vr_vllanmto := 24.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16018311;
  v_dados(v_dados.last()).vr_nrctremp := 258541;
  v_dados(v_dados.last()).vr_vllanmto := 24.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15863328;
  v_dados(v_dados.last()).vr_nrctremp := 94670;
  v_dados(v_dados.last()).vr_vllanmto := 24.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 192497;
  v_dados(v_dados.last()).vr_vllanmto := 24.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 239410;
  v_dados(v_dados.last()).vr_nrctremp := 51062;
  v_dados(v_dados.last()).vr_vllanmto := 24.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14122634;
  v_dados(v_dados.last()).vr_nrctremp := 7069966;
  v_dados(v_dados.last()).vr_vllanmto := 25.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14726327;
  v_dados(v_dados.last()).vr_nrctremp := 277209;
  v_dados(v_dados.last()).vr_vllanmto := 26.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211753;
  v_dados(v_dados.last()).vr_nrctremp := 286083;
  v_dados(v_dados.last()).vr_vllanmto := 26.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698270;
  v_dados(v_dados.last()).vr_nrctremp := 273753;
  v_dados(v_dados.last()).vr_vllanmto := 27.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1182463;
  v_dados(v_dados.last()).vr_nrctremp := 456454;
  v_dados(v_dados.last()).vr_vllanmto := 28.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 164291;
  v_dados(v_dados.last()).vr_nrctremp := 20796;
  v_dados(v_dados.last()).vr_vllanmto := 28.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16703006;
  v_dados(v_dados.last()).vr_nrctremp := 6993826;
  v_dados(v_dados.last()).vr_vllanmto := 29.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16416163;
  v_dados(v_dados.last()).vr_nrctremp := 101706;
  v_dados(v_dados.last()).vr_vllanmto := 30.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9543490;
  v_dados(v_dados.last()).vr_nrctremp := 4391966;
  v_dados(v_dados.last()).vr_vllanmto := 30.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13053140;
  v_dados(v_dados.last()).vr_nrctremp := 5779480;
  v_dados(v_dados.last()).vr_vllanmto := 30.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 934402;
  v_dados(v_dados.last()).vr_nrctremp := 672757;
  v_dados(v_dados.last()).vr_vllanmto := 30.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16539540;
  v_dados(v_dados.last()).vr_nrctremp := 450619;
  v_dados(v_dados.last()).vr_vllanmto := 30.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11208201;
  v_dados(v_dados.last()).vr_nrctremp := 7293592;
  v_dados(v_dados.last()).vr_vllanmto := 31.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 271845;
  v_dados(v_dados.last()).vr_nrctremp := 56501;
  v_dados(v_dados.last()).vr_vllanmto := 31.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 332836;
  v_dados(v_dados.last()).vr_nrctremp := 92139;
  v_dados(v_dados.last()).vr_vllanmto := 31.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184390;
  v_dados(v_dados.last()).vr_nrctremp := 286467;
  v_dados(v_dados.last()).vr_vllanmto := 32.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10750029;
  v_dados(v_dados.last()).vr_nrctremp := 6135678;
  v_dados(v_dados.last()).vr_vllanmto := 32.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 763896;
  v_dados(v_dados.last()).vr_nrctremp := 174662;
  v_dados(v_dados.last()).vr_vllanmto := 32.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15477800;
  v_dados(v_dados.last()).vr_nrctremp := 111924;
  v_dados(v_dados.last()).vr_vllanmto := 33.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 428167;
  v_dados(v_dados.last()).vr_nrctremp := 97953;
  v_dados(v_dados.last()).vr_vllanmto := 33.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12942820;
  v_dados(v_dados.last()).vr_nrctremp := 7251150;
  v_dados(v_dados.last()).vr_vllanmto := 34.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 94656;
  v_dados(v_dados.last()).vr_vllanmto := 34.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15458750;
  v_dados(v_dados.last()).vr_nrctremp := 283472;
  v_dados(v_dados.last()).vr_vllanmto := 34.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 416606;
  v_dados(v_dados.last()).vr_nrctremp := 179261;
  v_dados(v_dados.last()).vr_vllanmto := 34.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 315516;
  v_dados(v_dados.last()).vr_nrctremp := 95930;
  v_dados(v_dados.last()).vr_vllanmto := 35.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864529;
  v_dados(v_dados.last()).vr_nrctremp := 94677;
  v_dados(v_dados.last()).vr_vllanmto := 35.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 80950;
  v_dados(v_dados.last()).vr_nrctremp := 38185;
  v_dados(v_dados.last()).vr_vllanmto := 36.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 225029;
  v_dados(v_dados.last()).vr_nrctremp := 200360;
  v_dados(v_dados.last()).vr_vllanmto := 36.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10905910;
  v_dados(v_dados.last()).vr_nrctremp := 6488844;
  v_dados(v_dados.last()).vr_vllanmto := 36.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 924296;
  v_dados(v_dados.last()).vr_nrctremp := 366422;
  v_dados(v_dados.last()).vr_vllanmto := 36.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16709616;
  v_dados(v_dados.last()).vr_nrctremp := 341925;
  v_dados(v_dados.last()).vr_vllanmto := 38.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 902519;
  v_dados(v_dados.last()).vr_nrctremp := 318129;
  v_dados(v_dados.last()).vr_vllanmto := 39.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 764248;
  v_dados(v_dados.last()).vr_nrctremp := 371816;
  v_dados(v_dados.last()).vr_vllanmto := 40.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 148826;
  v_dados(v_dados.last()).vr_vllanmto := 40.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 174033;
  v_dados(v_dados.last()).vr_nrctremp := 273104;
  v_dados(v_dados.last()).vr_vllanmto := 41.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 134082;
  v_dados(v_dados.last()).vr_nrctremp := 42024;
  v_dados(v_dados.last()).vr_vllanmto := 41.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141760;
  v_dados(v_dados.last()).vr_vllanmto := 42.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116491;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 43.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17206103;
  v_dados(v_dados.last()).vr_nrctremp := 361318;
  v_dados(v_dados.last()).vr_vllanmto := 43.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14154080;
  v_dados(v_dados.last()).vr_nrctremp := 291115;
  v_dados(v_dados.last()).vr_vllanmto := 45.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7583001;
  v_dados(v_dados.last()).vr_nrctremp := 7518679;
  v_dados(v_dados.last()).vr_vllanmto := 46.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139845;
  v_dados(v_dados.last()).vr_vllanmto := 47.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 292206;
  v_dados(v_dados.last()).vr_nrctremp := 294319;
  v_dados(v_dados.last()).vr_vllanmto := 48.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80337074;
  v_dados(v_dados.last()).vr_nrctremp := 2955519;
  v_dados(v_dados.last()).vr_vllanmto := 49.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 49.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11665300;
  v_dados(v_dados.last()).vr_nrctremp := 6665413;
  v_dados(v_dados.last()).vr_vllanmto := 49.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 987581;
  v_dados(v_dados.last()).vr_nrctremp := 359973;
  v_dados(v_dados.last()).vr_vllanmto := 51.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14598345;
  v_dados(v_dados.last()).vr_nrctremp := 6520485;
  v_dados(v_dados.last()).vr_vllanmto := 52.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446025;
  v_dados(v_dados.last()).vr_nrctremp := 83056;
  v_dados(v_dados.last()).vr_vllanmto := 53.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16251865;
  v_dados(v_dados.last()).vr_nrctremp := 314665;
  v_dados(v_dados.last()).vr_vllanmto := 53.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11629410;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 56.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15316734;
  v_dados(v_dados.last()).vr_nrctremp := 317120;
  v_dados(v_dados.last()).vr_vllanmto := 57.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 886050;
  v_dados(v_dados.last()).vr_nrctremp := 382587;
  v_dados(v_dados.last()).vr_vllanmto := 58.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16265289;
  v_dados(v_dados.last()).vr_nrctremp := 440729;
  v_dados(v_dados.last()).vr_vllanmto := 59.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 47694;
  v_dados(v_dados.last()).vr_nrctremp := 32701;
  v_dados(v_dados.last()).vr_vllanmto := 60.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15207536;
  v_dados(v_dados.last()).vr_nrctremp := 7224738;
  v_dados(v_dados.last()).vr_vllanmto := 61.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4066944;
  v_dados(v_dados.last()).vr_nrctremp := 6695513;
  v_dados(v_dados.last()).vr_vllanmto := 62.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 50935;
  v_dados(v_dados.last()).vr_vllanmto := 63.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9739289;
  v_dados(v_dados.last()).vr_nrctremp := 5378221;
  v_dados(v_dados.last()).vr_vllanmto := 64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9667202;
  v_dados(v_dados.last()).vr_nrctremp := 6858514;
  v_dados(v_dados.last()).vr_vllanmto := 64.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 184919;
  v_dados(v_dados.last()).vr_vllanmto := 64.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15490475;
  v_dados(v_dados.last()).vr_nrctremp := 108320;
  v_dados(v_dados.last()).vr_vllanmto := 65.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14140888;
  v_dados(v_dados.last()).vr_nrctremp := 106454;
  v_dados(v_dados.last()).vr_vllanmto := 67.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15047806;
  v_dados(v_dados.last()).vr_nrctremp := 84306;
  v_dados(v_dados.last()).vr_vllanmto := 68.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15963179;
  v_dados(v_dados.last()).vr_nrctremp := 300118;
  v_dados(v_dados.last()).vr_vllanmto := 68.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15266761;
  v_dados(v_dados.last()).vr_nrctremp := 305186;
  v_dados(v_dados.last()).vr_vllanmto := 68.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 187546;
  v_dados(v_dados.last()).vr_vllanmto := 68.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80338526;
  v_dados(v_dados.last()).vr_nrctremp := 5672938;
  v_dados(v_dados.last()).vr_vllanmto := 69.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 4801045;
  v_dados(v_dados.last()).vr_vllanmto := 72.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78638;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 73.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 209775;
  v_dados(v_dados.last()).vr_nrctremp := 46471;
  v_dados(v_dados.last()).vr_vllanmto := 75.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 68578;
  v_dados(v_dados.last()).vr_nrctremp := 270253;
  v_dados(v_dados.last()).vr_vllanmto := 76.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 363286;
  v_dados(v_dados.last()).vr_nrctremp := 77990;
  v_dados(v_dados.last()).vr_vllanmto := 77.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 300625;
  v_dados(v_dados.last()).vr_vllanmto := 77.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14602733;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 77.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6065317;
  v_dados(v_dados.last()).vr_nrctremp := 4604018;
  v_dados(v_dados.last()).vr_vllanmto := 78.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14173905;
  v_dados(v_dados.last()).vr_nrctremp := 98056;
  v_dados(v_dados.last()).vr_vllanmto := 79.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 256544;
  v_dados(v_dados.last()).vr_nrctremp := 58944;
  v_dados(v_dados.last()).vr_vllanmto := 81.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16238281;
  v_dados(v_dados.last()).vr_nrctremp := 314032;
  v_dados(v_dados.last()).vr_vllanmto := 82.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14068184;
  v_dados(v_dados.last()).vr_nrctremp := 5613771;
  v_dados(v_dados.last()).vr_vllanmto := 83.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16337743;
  v_dados(v_dados.last()).vr_nrctremp := 286588;
  v_dados(v_dados.last()).vr_vllanmto := 83.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 526010;
  v_dados(v_dados.last()).vr_nrctremp := 87242;
  v_dados(v_dados.last()).vr_vllanmto := 86.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 292206;
  v_dados(v_dados.last()).vr_nrctremp := 249004;
  v_dados(v_dados.last()).vr_vllanmto := 87.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 4251082;
  v_dados(v_dados.last()).vr_vllanmto := 87.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15062449;
  v_dados(v_dados.last()).vr_nrctremp := 6597582;
  v_dados(v_dados.last()).vr_vllanmto := 90.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647845;
  v_dados(v_dados.last()).vr_nrctremp := 192882;
  v_dados(v_dados.last()).vr_vllanmto := 92.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 269913;
  v_dados(v_dados.last()).vr_nrctremp := 68956;
  v_dados(v_dados.last()).vr_vllanmto := 93.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 291854;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 98.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1035673;
  v_dados(v_dados.last()).vr_nrctremp := 320862;
  v_dados(v_dados.last()).vr_vllanmto := 99.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 563498;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 104.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12292095;
  v_dados(v_dados.last()).vr_nrctremp := 5828078;
  v_dados(v_dados.last()).vr_vllanmto := 106.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1026089;
  v_dados(v_dados.last()).vr_nrctremp := 399005;
  v_dados(v_dados.last()).vr_vllanmto := 113.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1121170;
  v_dados(v_dados.last()).vr_nrctremp := 465246;
  v_dados(v_dados.last()).vr_vllanmto := 118.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 316091;
  v_dados(v_dados.last()).vr_nrctremp := 520270;
  v_dados(v_dados.last()).vr_vllanmto := 125.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575046;
  v_dados(v_dados.last()).vr_nrctremp := 383395;
  v_dados(v_dados.last()).vr_vllanmto := 127.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 352624;
  v_dados(v_dados.last()).vr_nrctremp := 149220;
  v_dados(v_dados.last()).vr_vllanmto := 137.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638579;
  v_dados(v_dados.last()).vr_nrctremp := 250085;
  v_dados(v_dados.last()).vr_vllanmto := 142.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3153886;
  v_dados(v_dados.last()).vr_nrctremp := 6748175;
  v_dados(v_dados.last()).vr_vllanmto := 144.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 141142;
  v_dados(v_dados.last()).vr_vllanmto := 146.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15367061;
  v_dados(v_dados.last()).vr_nrctremp := 98058;
  v_dados(v_dados.last()).vr_vllanmto := 148.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 150785;
  v_dados(v_dados.last()).vr_vllanmto := 155.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16251865;
  v_dados(v_dados.last()).vr_nrctremp := 329198;
  v_dados(v_dados.last()).vr_vllanmto := 166.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 3383461;
  v_dados(v_dados.last()).vr_vllanmto := 176.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186805;
  v_dados(v_dados.last()).vr_nrctremp := 63844;
  v_dados(v_dados.last()).vr_vllanmto := 181.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 229083;
  v_dados(v_dados.last()).vr_nrctremp := 288206;
  v_dados(v_dados.last()).vr_vllanmto := 183.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 184.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 323454;
  v_dados(v_dados.last()).vr_nrctremp := 95971;
  v_dados(v_dados.last()).vr_vllanmto := 188.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 197.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 4101609;
  v_dados(v_dados.last()).vr_vllanmto := 198.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 213.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349682;
  v_dados(v_dados.last()).vr_nrctremp := 60356;
  v_dados(v_dados.last()).vr_vllanmto := 221.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 154415;
  v_dados(v_dados.last()).vr_nrctremp := 22046;
  v_dados(v_dados.last()).vr_vllanmto := 221.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16125673;
  v_dados(v_dados.last()).vr_nrctremp := 309197;
  v_dados(v_dados.last()).vr_vllanmto := 225.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17012368;
  v_dados(v_dados.last()).vr_nrctremp := 109058;
  v_dados(v_dados.last()).vr_vllanmto := 230.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14068184;
  v_dados(v_dados.last()).vr_nrctremp := 5162184;
  v_dados(v_dados.last()).vr_vllanmto := 231.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 239.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 592781;
  v_dados(v_dados.last()).vr_nrctremp := 271052;
  v_dados(v_dados.last()).vr_vllanmto := 240.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 245.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14419394;
  v_dados(v_dados.last()).vr_nrctremp := 5573717;
  v_dados(v_dados.last()).vr_vllanmto := 251.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1981765;
  v_dados(v_dados.last()).vr_nrctremp := 384467;
  v_dados(v_dados.last()).vr_vllanmto := 265.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 272.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 67611;
  v_dados(v_dados.last()).vr_vllanmto := 277.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77038;
  v_dados(v_dados.last()).vr_nrctremp := 45687;
  v_dados(v_dados.last()).vr_vllanmto := 287.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15827607;
  v_dados(v_dados.last()).vr_nrctremp := 107083;
  v_dados(v_dados.last()).vr_vllanmto := 290.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10677542;
  v_dados(v_dados.last()).vr_nrctremp := 3986642;
  v_dados(v_dados.last()).vr_vllanmto := 302.9;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11310480;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 306.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14289083;
  v_dados(v_dados.last()).vr_nrctremp := 409576;
  v_dados(v_dados.last()).vr_vllanmto := 326.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 757365;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 327.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9561200;
  v_dados(v_dados.last()).vr_nrctremp := 6084116;
  v_dados(v_dados.last()).vr_vllanmto := 328.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 382.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 677442;
  v_dados(v_dados.last()).vr_nrctremp := 382071;
  v_dados(v_dados.last()).vr_vllanmto := 384.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14143836;
  v_dados(v_dados.last()).vr_nrctremp := 82239;
  v_dados(v_dados.last()).vr_vllanmto := 392.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16478320;
  v_dados(v_dados.last()).vr_nrctremp := 102406;
  v_dados(v_dados.last()).vr_vllanmto := 392.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7580592;
  v_dados(v_dados.last()).vr_nrctremp := 7433877;
  v_dados(v_dados.last()).vr_vllanmto := 416.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11223332;
  v_dados(v_dados.last()).vr_nrctremp := 4901463;
  v_dados(v_dados.last()).vr_vllanmto := 418.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 771511;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 424.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16145399;
  v_dados(v_dados.last()).vr_nrctremp := 264117;
  v_dados(v_dados.last()).vr_vllanmto := 434.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 476.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17107393;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 476.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15988198;
  v_dados(v_dados.last()).vr_nrctremp := 44283;
  v_dados(v_dados.last()).vr_vllanmto := 499.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 986950;
  v_dados(v_dados.last()).vr_nrctremp := 373726;
  v_dados(v_dados.last()).vr_vllanmto := 500.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 86347;
  v_dados(v_dados.last()).vr_nrctremp := 30531;
  v_dados(v_dados.last()).vr_vllanmto := 506.31;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16444256;
  v_dados(v_dados.last()).vr_nrctremp := 324902;
  v_dados(v_dados.last()).vr_vllanmto := 514.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 335690;
  v_dados(v_dados.last()).vr_nrctremp := 77871;
  v_dados(v_dados.last()).vr_vllanmto := 519.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 254372;
  v_dados(v_dados.last()).vr_vllanmto := 549.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 958883;
  v_dados(v_dados.last()).vr_nrctremp := 329872;
  v_dados(v_dados.last()).vr_vllanmto := 573.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 237400;
  v_dados(v_dados.last()).vr_nrctremp := 40666;
  v_dados(v_dados.last()).vr_vllanmto := 593.07;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16745965;
  v_dados(v_dados.last()).vr_nrctremp := 339590;
  v_dados(v_dados.last()).vr_vllanmto := 626.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 667.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261122;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 676.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14722720;
  v_dados(v_dados.last()).vr_nrctremp := 200765;
  v_dados(v_dados.last()).vr_vllanmto := 702.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15733807;
  v_dados(v_dados.last()).vr_nrctremp := 7155786;
  v_dados(v_dados.last()).vr_vllanmto := 703.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 705926;
  v_dados(v_dados.last()).vr_nrctremp := 245304;
  v_dados(v_dados.last()).vr_vllanmto := 717.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 539899;
  v_dados(v_dados.last()).vr_nrctremp := 250086;
  v_dados(v_dados.last()).vr_vllanmto := 750.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 306655;
  v_dados(v_dados.last()).vr_vllanmto := 779.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328014;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 792.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 275871;
  v_dados(v_dados.last()).vr_vllanmto := 801.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 247626;
  v_dados(v_dados.last()).vr_vllanmto := 820.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 820.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12943924;
  v_dados(v_dados.last()).vr_nrctremp := 5246245;
  v_dados(v_dados.last()).vr_vllanmto := 826.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 299304;
  v_dados(v_dados.last()).vr_vllanmto := 872.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 230666;
  v_dados(v_dados.last()).vr_vllanmto := 874.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 284704;
  v_dados(v_dados.last()).vr_vllanmto := 887.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 6131009;
  v_dados(v_dados.last()).vr_vllanmto := 891.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15779602;
  v_dados(v_dados.last()).vr_nrctremp := 247566;
  v_dados(v_dados.last()).vr_vllanmto := 903.28;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14193612;
  v_dados(v_dados.last()).vr_nrctremp := 77993;
  v_dados(v_dados.last()).vr_vllanmto := 917.06;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 656470;
  v_dados(v_dados.last()).vr_nrctremp := 213344;
  v_dados(v_dados.last()).vr_vllanmto := 921.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 287913;
  v_dados(v_dados.last()).vr_vllanmto := 929.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 230274;
  v_dados(v_dados.last()).vr_vllanmto := 933.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 273151;
  v_dados(v_dados.last()).vr_vllanmto := 939.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 309165;
  v_dados(v_dados.last()).vr_vllanmto := 945.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 248810;
  v_dados(v_dados.last()).vr_vllanmto := 947.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15126510;
  v_dados(v_dados.last()).vr_nrctremp := 43499;
  v_dados(v_dados.last()).vr_vllanmto := 964.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 984.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 149870;
  v_dados(v_dados.last()).vr_nrctremp := 42542;
  v_dados(v_dados.last()).vr_vllanmto := 1022.29;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 226904;
  v_dados(v_dados.last()).vr_nrctremp := 197811;
  v_dados(v_dados.last()).vr_vllanmto := 1076.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349712;
  v_dados(v_dados.last()).vr_nrctremp := 60062;
  v_dados(v_dados.last()).vr_vllanmto := 1153.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14317311;
  v_dados(v_dados.last()).vr_nrctremp := 74303;
  v_dados(v_dados.last()).vr_vllanmto := 1245.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 105884;
  v_dados(v_dados.last()).vr_vllanmto := 1317.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11951605;
  v_dados(v_dados.last()).vr_nrctremp := 4745153;
  v_dados(v_dados.last()).vr_vllanmto := 1385.59;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 230219;
  v_dados(v_dados.last()).vr_vllanmto := 1595.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729205;
  v_dados(v_dados.last()).vr_nrctremp := 309697;
  v_dados(v_dados.last()).vr_vllanmto := 1602.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 1881.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 978140;
  v_dados(v_dados.last()).vr_nrctremp := 425132;
  v_dados(v_dados.last()).vr_vllanmto := 1907.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9875638;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 1924.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 1933.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9696644;
  v_dados(v_dados.last()).vr_nrctremp := 6175077;
  v_dados(v_dados.last()).vr_vllanmto := 1934.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 478512;
  v_dados(v_dados.last()).vr_nrctremp := 185911;
  v_dados(v_dados.last()).vr_vllanmto := 2363.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16606752;
  v_dados(v_dados.last()).vr_nrctremp := 332772;
  v_dados(v_dados.last()).vr_vllanmto := 2515.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12221880;
  v_dados(v_dados.last()).vr_nrctremp := 5839105;
  v_dados(v_dados.last()).vr_vllanmto := 2534.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14317311;
  v_dados(v_dados.last()).vr_nrctremp := 74294;
  v_dados(v_dados.last()).vr_vllanmto := 2680.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 147699;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 2775.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9450572;
  v_dados(v_dados.last()).vr_nrctremp := 6930833;
  v_dados(v_dados.last()).vr_vllanmto := 2786.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10253769;
  v_dados(v_dados.last()).vr_nrctremp := 5312374;
  v_dados(v_dados.last()).vr_vllanmto := 2851.89;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 2856.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15880800;
  v_dados(v_dados.last()).vr_nrctremp := 426071;
  v_dados(v_dados.last()).vr_vllanmto := 2915.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 3082.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 80519;
  v_dados(v_dados.last()).vr_nrctremp := 34345;
  v_dados(v_dados.last()).vr_vllanmto := 3204.98;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1040189;
  v_dados(v_dados.last()).vr_nrctremp := 322113;
  v_dados(v_dados.last()).vr_vllanmto := 3763.64;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7864825;
  v_dados(v_dados.last()).vr_nrctremp := 4564568;
  v_dados(v_dados.last()).vr_vllanmto := 4199.14;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 245701;
  v_dados(v_dados.last()).vr_vllanmto := 4534.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348589;
  v_dados(v_dados.last()).vr_nrctremp := 70045;
  v_dados(v_dados.last()).vr_vllanmto := 4944.54;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 87696;
  v_dados(v_dados.last()).vr_nrctremp := 42976;
  v_dados(v_dados.last()).vr_vllanmto := 5236.06;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12651443;
  v_dados(v_dados.last()).vr_nrctremp := 4950509;
  v_dados(v_dados.last()).vr_vllanmto := 5440.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11371498;
  v_dados(v_dados.last()).vr_nrctremp := 5257242;
  v_dados(v_dados.last()).vr_vllanmto := 6837.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 6920.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 128092;
  v_dados(v_dados.last()).vr_vllanmto := 7441.69;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 303909;
  v_dados(v_dados.last()).vr_nrctremp := 59340;
  v_dados(v_dados.last()).vr_vllanmto := 7598.33;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 90530;
  v_dados(v_dados.last()).vr_nrctremp := 494717;
  v_dados(v_dados.last()).vr_vllanmto := 8253.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 577120;
  v_dados(v_dados.last()).vr_nrctremp := 199246;
  v_dados(v_dados.last()).vr_vllanmto := 8301.09;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 8598.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15265218;
  v_dados(v_dados.last()).vr_nrctremp := 6130812;
  v_dados(v_dados.last()).vr_vllanmto := 10242.91;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12860875;
  v_dados(v_dados.last()).vr_nrctremp := 6296769;
  v_dados(v_dados.last()).vr_vllanmto := 10394.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 106976;
  v_dados(v_dados.last()).vr_vllanmto := 10466.56;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 168572;
  v_dados(v_dados.last()).vr_nrctremp := 86810;
  v_dados(v_dados.last()).vr_vllanmto := 10700.41;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12860875;
  v_dados(v_dados.last()).vr_nrctremp := 6347624;
  v_dados(v_dados.last()).vr_vllanmto := 10867.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12317519;
  v_dados(v_dados.last()).vr_nrctremp := 5783533;
  v_dados(v_dados.last()).vr_vllanmto := 10954.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 213926;
  v_dados(v_dados.last()).vr_nrctremp := 257350;
  v_dados(v_dados.last()).vr_vllanmto := 13233.97;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15264734;
  v_dados(v_dados.last()).vr_nrctremp := 6627036;
  v_dados(v_dados.last()).vr_vllanmto := 14077.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 288730;
  v_dados(v_dados.last()).vr_nrctremp := 80332;
  v_dados(v_dados.last()).vr_vllanmto := 17719.57;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 153126;
  v_dados(v_dados.last()).vr_vllanmto := 25.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17345880;
  v_dados(v_dados.last()).vr_nrctremp := 309336;
  v_dados(v_dados.last()).vr_vllanmto := 1.39;
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
