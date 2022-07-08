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
  v_dados(v_dados.last()).vr_vllanmto := 294.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 76368;
  v_dados(v_dados.last()).vr_nrctremp := 11017;
  v_dados(v_dados.last()).vr_vllanmto := 147.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 20290;
  v_dados(v_dados.last()).vr_nrctremp := 11604;
  v_dados(v_dados.last()).vr_vllanmto := 194.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 20290;
  v_dados(v_dados.last()).vr_nrctremp := 11604;
  v_dados(v_dados.last()).vr_vllanmto := 201.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 123986;
  v_dados(v_dados.last()).vr_nrctremp := 11731;
  v_dados(v_dados.last()).vr_vllanmto := 189.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 120499;
  v_dados(v_dados.last()).vr_nrctremp := 12216;
  v_dados(v_dados.last()).vr_vllanmto := 123.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 120499;
  v_dados(v_dados.last()).vr_nrctremp := 12216;
  v_dados(v_dados.last()).vr_vllanmto := 152.47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 4588;
  v_dados(v_dados.last()).vr_nrctremp := 12269;
  v_dados(v_dados.last()).vr_vllanmto := .47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

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
  v_dados(v_dados.last()).vr_vllanmto := 140.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 76449;
  v_dados(v_dados.last()).vr_nrctremp := 13040;
  v_dados(v_dados.last()).vr_vllanmto := 69.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 76449;
  v_dados(v_dados.last()).vr_nrctremp := 13040;
  v_dados(v_dados.last()).vr_vllanmto := 73.49;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 156337;
  v_dados(v_dados.last()).vr_nrctremp := 13135;
  v_dados(v_dados.last()).vr_vllanmto := 277.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 156337;
  v_dados(v_dados.last()).vr_nrctremp := 13135;
  v_dados(v_dados.last()).vr_vllanmto := 296.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49743;
  v_dados(v_dados.last()).vr_nrctremp := 13139;
  v_dados(v_dados.last()).vr_vllanmto := 187.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108898;
  v_dados(v_dados.last()).vr_nrctremp := 13288;
  v_dados(v_dados.last()).vr_vllanmto := 201.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142328;
  v_dados(v_dados.last()).vr_nrctremp := 13396;
  v_dados(v_dados.last()).vr_vllanmto := 27.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 127582;
  v_dados(v_dados.last()).vr_nrctremp := 13745;
  v_dados(v_dados.last()).vr_vllanmto := 71.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 155098;
  v_dados(v_dados.last()).vr_nrctremp := 14109;
  v_dados(v_dados.last()).vr_vllanmto := 26.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 145122;
  v_dados(v_dados.last()).vr_nrctremp := 14113;
  v_dados(v_dados.last()).vr_vllanmto := 65.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143324;
  v_dados(v_dados.last()).vr_nrctremp := 14165;
  v_dados(v_dados.last()).vr_vllanmto := 16.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 79359;
  v_dados(v_dados.last()).vr_nrctremp := 14930;
  v_dados(v_dados.last()).vr_vllanmto := 224.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 119717;
  v_dados(v_dados.last()).vr_nrctremp := 15448;
  v_dados(v_dados.last()).vr_vllanmto := 107.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 119717;
  v_dados(v_dados.last()).vr_nrctremp := 15448;
  v_dados(v_dados.last()).vr_vllanmto := 189.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 42641;
  v_dados(v_dados.last()).vr_nrctremp := 15890;
  v_dados(v_dados.last()).vr_vllanmto := 97.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 42641;
  v_dados(v_dados.last()).vr_nrctremp := 15890;
  v_dados(v_dados.last()).vr_vllanmto := 150.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 56987;
  v_dados(v_dados.last()).vr_nrctremp := 15962;
  v_dados(v_dados.last()).vr_vllanmto := 38.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 56987;
  v_dados(v_dados.last()).vr_nrctremp := 15962;
  v_dados(v_dados.last()).vr_vllanmto := 19.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103853;
  v_dados(v_dados.last()).vr_nrctremp := 16241;
  v_dados(v_dados.last()).vr_vllanmto := 30.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103748;
  v_dados(v_dados.last()).vr_nrctremp := 16479;
  v_dados(v_dados.last()).vr_vllanmto := 82.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103748;
  v_dados(v_dados.last()).vr_nrctremp := 16479;
  v_dados(v_dados.last()).vr_vllanmto := 202.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142395;
  v_dados(v_dados.last()).vr_nrctremp := 16565;
  v_dados(v_dados.last()).vr_vllanmto := 13.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 106739;
  v_dados(v_dados.last()).vr_nrctremp := 16580;
  v_dados(v_dados.last()).vr_vllanmto := 816.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 75906;
  v_dados(v_dados.last()).vr_nrctremp := 17006;
  v_dados(v_dados.last()).vr_vllanmto := 57.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 129119;
  v_dados(v_dados.last()).vr_nrctremp := 17075;
  v_dados(v_dados.last()).vr_vllanmto := 214.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152749;
  v_dados(v_dados.last()).vr_nrctremp := 17436;
  v_dados(v_dados.last()).vr_vllanmto := 118.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 121720;
  v_dados(v_dados.last()).vr_nrctremp := 17476;
  v_dados(v_dados.last()).vr_vllanmto := 88.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143553;
  v_dados(v_dados.last()).vr_nrctremp := 17894;
  v_dados(v_dados.last()).vr_vllanmto := 248.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 149101;
  v_dados(v_dados.last()).vr_nrctremp := 19244;
  v_dados(v_dados.last()).vr_vllanmto := 35.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 149101;
  v_dados(v_dados.last()).vr_nrctremp := 19244;
  v_dados(v_dados.last()).vr_vllanmto := 42.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 110833;
  v_dados(v_dados.last()).vr_nrctremp := 19761;
  v_dados(v_dados.last()).vr_vllanmto := 177.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 110833;
  v_dados(v_dados.last()).vr_nrctremp := 19761;
  v_dados(v_dados.last()).vr_vllanmto := 256.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 141895;
  v_dados(v_dados.last()).vr_nrctremp := 20181;
  v_dados(v_dados.last()).vr_vllanmto := 2.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166898;
  v_dados(v_dados.last()).vr_nrctremp := 20193;
  v_dados(v_dados.last()).vr_vllanmto := 39.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 169854;
  v_dados(v_dados.last()).vr_nrctremp := 20352;
  v_dados(v_dados.last()).vr_vllanmto := 45.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73130;
  v_dados(v_dados.last()).vr_nrctremp := 20750;
  v_dados(v_dados.last()).vr_vllanmto := 78.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 109134;
  v_dados(v_dados.last()).vr_nrctremp := 20782;
  v_dados(v_dados.last()).vr_vllanmto := 112.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 109134;
  v_dados(v_dados.last()).vr_nrctremp := 20782;
  v_dados(v_dados.last()).vr_vllanmto := 221.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 164291;
  v_dados(v_dados.last()).vr_nrctremp := 20796;
  v_dados(v_dados.last()).vr_vllanmto := 42.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 145122;
  v_dados(v_dados.last()).vr_nrctremp := 20797;
  v_dados(v_dados.last()).vr_vllanmto := 45.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 145122;
  v_dados(v_dados.last()).vr_nrctremp := 20797;
  v_dados(v_dados.last()).vr_vllanmto := 67.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 91952;
  v_dados(v_dados.last()).vr_nrctremp := 20906;
  v_dados(v_dados.last()).vr_vllanmto := 166.85;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 86177;
  v_dados(v_dados.last()).vr_nrctremp := 20920;
  v_dados(v_dados.last()).vr_vllanmto := 130.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108804;
  v_dados(v_dados.last()).vr_nrctremp := 21233;
  v_dados(v_dados.last()).vr_vllanmto := 60.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108804;
  v_dados(v_dados.last()).vr_nrctremp := 21233;
  v_dados(v_dados.last()).vr_vllanmto := 105.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 177075;
  v_dados(v_dados.last()).vr_nrctremp := 21289;
  v_dados(v_dados.last()).vr_vllanmto := 212.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 177075;
  v_dados(v_dados.last()).vr_nrctremp := 21289;
  v_dados(v_dados.last()).vr_vllanmto := 375.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 72931;
  v_dados(v_dados.last()).vr_nrctremp := 21381;
  v_dados(v_dados.last()).vr_vllanmto := 90.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

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
  v_dados(v_dados.last()).vr_vllanmto := 27.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142867;
  v_dados(v_dados.last()).vr_nrctremp := 21554;
  v_dados(v_dados.last()).vr_vllanmto := 32.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143227;
  v_dados(v_dados.last()).vr_nrctremp := 21595;
  v_dados(v_dados.last()).vr_vllanmto := 17.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152080;
  v_dados(v_dados.last()).vr_nrctremp := 21626;
  v_dados(v_dados.last()).vr_vllanmto := 108.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 140554;
  v_dados(v_dados.last()).vr_nrctremp := 21866;
  v_dados(v_dados.last()).vr_vllanmto := 66.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 48038;
  v_dados(v_dados.last()).vr_nrctremp := 22133;
  v_dados(v_dados.last()).vr_vllanmto := 7.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166650;
  v_dados(v_dados.last()).vr_nrctremp := 22713;
  v_dados(v_dados.last()).vr_vllanmto := 44.69;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 85065;
  v_dados(v_dados.last()).vr_nrctremp := 22767;
  v_dados(v_dados.last()).vr_vllanmto := 27.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49956;
  v_dados(v_dados.last()).vr_nrctremp := 24468;
  v_dados(v_dados.last()).vr_vllanmto := 58.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166634;
  v_dados(v_dados.last()).vr_nrctremp := 24549;
  v_dados(v_dados.last()).vr_vllanmto := 28.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 94943;
  v_dados(v_dados.last()).vr_nrctremp := 24595;
  v_dados(v_dados.last()).vr_vllanmto := 158.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128481;
  v_dados(v_dados.last()).vr_nrctremp := 25048;
  v_dados(v_dados.last()).vr_vllanmto := 69.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103845;
  v_dados(v_dados.last()).vr_nrctremp := 25269;
  v_dados(v_dados.last()).vr_vllanmto := 125.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103845;
  v_dados(v_dados.last()).vr_nrctremp := 25269;
  v_dados(v_dados.last()).vr_vllanmto := 224.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 151017;
  v_dados(v_dados.last()).vr_nrctremp := 25746;
  v_dados(v_dados.last()).vr_vllanmto := 23.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 83682;
  v_dados(v_dados.last()).vr_nrctremp := 26001;
  v_dados(v_dados.last()).vr_vllanmto := 48.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 183946;
  v_dados(v_dados.last()).vr_nrctremp := 26040;
  v_dados(v_dados.last()).vr_vllanmto := 52.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 48410;
  v_dados(v_dados.last()).vr_nrctremp := 26327;
  v_dados(v_dados.last()).vr_vllanmto := 88.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 29025;
  v_dados(v_dados.last()).vr_nrctremp := 26466;
  v_dados(v_dados.last()).vr_vllanmto := 63.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 29025;
  v_dados(v_dados.last()).vr_nrctremp := 26466;
  v_dados(v_dados.last()).vr_vllanmto := 76.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 27006;
  v_dados(v_dados.last()).vr_vllanmto := 33.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 27006;
  v_dados(v_dados.last()).vr_vllanmto := 49.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 111210;
  v_dados(v_dados.last()).vr_nrctremp := 27222;
  v_dados(v_dados.last()).vr_vllanmto := 67.09;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 111210;
  v_dados(v_dados.last()).vr_nrctremp := 27222;
  v_dados(v_dados.last()).vr_vllanmto := 84.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142824;
  v_dados(v_dados.last()).vr_nrctremp := 27383;
  v_dados(v_dados.last()).vr_vllanmto := 165.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 126322;
  v_dados(v_dados.last()).vr_nrctremp := 27516;
  v_dados(v_dados.last()).vr_vllanmto := 29.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 126322;
  v_dados(v_dados.last()).vr_nrctremp := 27516;
  v_dados(v_dados.last()).vr_vllanmto := 15.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 165867;
  v_dados(v_dados.last()).vr_nrctremp := 27952;
  v_dados(v_dados.last()).vr_vllanmto := 148.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166480;
  v_dados(v_dados.last()).vr_nrctremp := 28356;
  v_dados(v_dados.last()).vr_vllanmto := 7.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 133418;
  v_dados(v_dados.last()).vr_nrctremp := 28512;
  v_dados(v_dados.last()).vr_vllanmto := 82.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184063;
  v_dados(v_dados.last()).vr_nrctremp := 28875;
  v_dados(v_dados.last()).vr_vllanmto := 42.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

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
  v_dados(v_dados.last()).vr_vllanmto := 25.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 5797;
  v_dados(v_dados.last()).vr_nrctremp := 29441;
  v_dados(v_dados.last()).vr_vllanmto := 29.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49794;
  v_dados(v_dados.last()).vr_nrctremp := 29556;
  v_dados(v_dados.last()).vr_vllanmto := 15.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77542;
  v_dados(v_dados.last()).vr_nrctremp := 29750;
  v_dados(v_dados.last()).vr_vllanmto := 17.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 72966;
  v_dados(v_dados.last()).vr_nrctremp := 29759;
  v_dados(v_dados.last()).vr_vllanmto := 160.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 180874;
  v_dados(v_dados.last()).vr_nrctremp := 29859;
  v_dados(v_dados.last()).vr_vllanmto := 27.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 68543;
  v_dados(v_dados.last()).vr_nrctremp := 29888;
  v_dados(v_dados.last()).vr_vllanmto := 21.67;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84840;
  v_dados(v_dados.last()).vr_nrctremp := 30015;
  v_dados(v_dados.last()).vr_vllanmto := 52.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 90662;
  v_dados(v_dados.last()).vr_nrctremp := 30402;
  v_dados(v_dados.last()).vr_vllanmto := 22.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 90662;
  v_dados(v_dados.last()).vr_nrctremp := 30402;
  v_dados(v_dados.last()).vr_vllanmto := 27.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128090;
  v_dados(v_dados.last()).vr_nrctremp := 30674;
  v_dados(v_dados.last()).vr_vllanmto := 31.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 155314;
  v_dados(v_dados.last()).vr_nrctremp := 30952;
  v_dados(v_dados.last()).vr_vllanmto := 64.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 116661;
  v_dados(v_dados.last()).vr_nrctremp := 31685;
  v_dados(v_dados.last()).vr_vllanmto := 30.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 141623;
  v_dados(v_dados.last()).vr_nrctremp := 31901;
  v_dados(v_dados.last()).vr_vllanmto := 44.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166545;
  v_dados(v_dados.last()).vr_nrctremp := 32681;
  v_dados(v_dados.last()).vr_vllanmto := 35.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77038;
  v_dados(v_dados.last()).vr_nrctremp := 32862;
  v_dados(v_dados.last()).vr_vllanmto := 70.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184039;
  v_dados(v_dados.last()).vr_nrctremp := 32925;
  v_dados(v_dados.last()).vr_vllanmto := 28.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184039;
  v_dados(v_dados.last()).vr_nrctremp := 32925;
  v_dados(v_dados.last()).vr_vllanmto := 49.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 183989;
  v_dados(v_dados.last()).vr_nrctremp := 33015;
  v_dados(v_dados.last()).vr_vllanmto := 13.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166863;
  v_dados(v_dados.last()).vr_nrctremp := 33682;
  v_dados(v_dados.last()).vr_vllanmto := 19.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 194719;
  v_dados(v_dados.last()).vr_nrctremp := 33742;
  v_dados(v_dados.last()).vr_vllanmto := 27.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 14974;
  v_dados(v_dados.last()).vr_nrctremp := 34026;
  v_dados(v_dados.last()).vr_vllanmto := 25.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 71145;
  v_dados(v_dados.last()).vr_nrctremp := 34416;
  v_dados(v_dados.last()).vr_vllanmto := 38.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128481;
  v_dados(v_dados.last()).vr_nrctremp := 34580;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108286;
  v_dados(v_dados.last()).vr_nrctremp := 34780;
  v_dados(v_dados.last()).vr_vllanmto := 920.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152978;
  v_dados(v_dados.last()).vr_nrctremp := 34887;
  v_dados(v_dados.last()).vr_vllanmto := 97.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 200450;
  v_dados(v_dados.last()).vr_nrctremp := 35953;
  v_dados(v_dados.last()).vr_vllanmto := 20.09;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166561;
  v_dados(v_dados.last()).vr_nrctremp := 36045;
  v_dados(v_dados.last()).vr_vllanmto := 21.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166693;
  v_dados(v_dados.last()).vr_nrctremp := 36303;
  v_dados(v_dados.last()).vr_vllanmto := 28.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 220035;
  v_dados(v_dados.last()).vr_nrctremp := 36437;
  v_dados(v_dados.last()).vr_vllanmto := 324.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 147753;
  v_dados(v_dados.last()).vr_nrctremp := 37039;
  v_dados(v_dados.last()).vr_vllanmto := 204.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 194743;
  v_dados(v_dados.last()).vr_nrctremp := 37044;
  v_dados(v_dados.last()).vr_vllanmto := 56.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 172707;
  v_dados(v_dados.last()).vr_nrctremp := 37810;
  v_dados(v_dados.last()).vr_vllanmto := 19.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 104639;
  v_dados(v_dados.last()).vr_nrctremp := 37880;
  v_dados(v_dados.last()).vr_vllanmto := 26.78;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 115908;
  v_dados(v_dados.last()).vr_nrctremp := 37902;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 115908;
  v_dados(v_dados.last()).vr_nrctremp := 37902;
  v_dados(v_dados.last()).vr_vllanmto := 15.69;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 198960;
  v_dados(v_dados.last()).vr_nrctremp := 38243;
  v_dados(v_dados.last()).vr_vllanmto := 41.74;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 198960;
  v_dados(v_dados.last()).vr_nrctremp := 38243;
  v_dados(v_dados.last()).vr_vllanmto := 23.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 212636;
  v_dados(v_dados.last()).vr_nrctremp := 38270;
  v_dados(v_dados.last()).vr_vllanmto := 30.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 190039;
  v_dados(v_dados.last()).vr_nrctremp := 38452;
  v_dados(v_dados.last()).vr_vllanmto := 72.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 94960;
  v_dados(v_dados.last()).vr_nrctremp := 38465;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166472;
  v_dados(v_dados.last()).vr_nrctremp := 38594;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 139521;
  v_dados(v_dados.last()).vr_nrctremp := 38619;
  v_dados(v_dados.last()).vr_vllanmto := 11.23;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 67415;
  v_dados(v_dados.last()).vr_nrctremp := 38778;
  v_dados(v_dados.last()).vr_vllanmto := 21.08;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 115819;
  v_dados(v_dados.last()).vr_nrctremp := 38950;
  v_dados(v_dados.last()).vr_vllanmto := 11.46;
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
