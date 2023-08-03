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
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 310190;
  v_dados(v_dados.last()).vr_nrctremp := 40091;
  v_dados(v_dados.last()).vr_vllanmto := 25.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 103756;
  v_dados(v_dados.last()).vr_nrctremp := 41507;
  v_dados(v_dados.last()).vr_vllanmto := 91.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 195065;
  v_dados(v_dados.last()).vr_nrctremp := 43146;
  v_dados(v_dados.last()).vr_vllanmto := 53.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 360929;
  v_dados(v_dados.last()).vr_nrctremp := 62245;
  v_dados(v_dados.last()).vr_vllanmto := 31.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 333816;
  v_dados(v_dados.last()).vr_nrctremp := 67729;
  v_dados(v_dados.last()).vr_vllanmto := 5.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14548798;
  v_dados(v_dados.last()).vr_nrctremp := 77486;
  v_dados(v_dados.last()).vr_vllanmto := 3389.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 335690;
  v_dados(v_dados.last()).vr_nrctremp := 77871;
  v_dados(v_dados.last()).vr_vllanmto := 1985.09;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 333352;
  v_dados(v_dados.last()).vr_nrctremp := 94753;
  v_dados(v_dados.last()).vr_vllanmto := 17.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 34738;
  v_dados(v_dados.last()).vr_nrctremp := 24502;
  v_dados(v_dados.last()).vr_vllanmto := 41.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 147699;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 28.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 150045;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 62.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 154164;
  v_dados(v_dados.last()).vr_nrctremp := 23600;
  v_dados(v_dados.last()).vr_vllanmto := 4313.21;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 155020;
  v_dados(v_dados.last()).vr_nrctremp := 102339;
  v_dados(v_dados.last()).vr_vllanmto := 20.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 231320;
  v_dados(v_dados.last()).vr_nrctremp := 44198;
  v_dados(v_dados.last()).vr_vllanmto := 129.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 255211;
  v_dados(v_dados.last()).vr_nrctremp := 79618;
  v_dados(v_dados.last()).vr_vllanmto := 15.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 257427;
  v_dados(v_dados.last()).vr_nrctremp := 59721;
  v_dados(v_dados.last()).vr_vllanmto := 88.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 278920;
  v_dados(v_dados.last()).vr_nrctremp := 32677;
  v_dados(v_dados.last()).vr_vllanmto := 165.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 63200;
  v_dados(v_dados.last()).vr_vllanmto := 64.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 55893;
  v_dados(v_dados.last()).vr_vllanmto := 97.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 287237;
  v_dados(v_dados.last()).vr_nrctremp := 36484;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348465;
  v_dados(v_dados.last()).vr_nrctremp := 59850;
  v_dados(v_dados.last()).vr_vllanmto := 43.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348589;
  v_dados(v_dados.last()).vr_nrctremp := 70045;
  v_dados(v_dados.last()).vr_vllanmto := 61.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348759;
  v_dados(v_dados.last()).vr_nrctremp := 63209;
  v_dados(v_dados.last()).vr_vllanmto := 21.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349372;
  v_dados(v_dados.last()).vr_nrctremp := 98361;
  v_dados(v_dados.last()).vr_vllanmto := 19.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349712;
  v_dados(v_dados.last()).vr_nrctremp := 60062;
  v_dados(v_dados.last()).vr_vllanmto := 2595.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 351652;
  v_dados(v_dados.last()).vr_nrctremp := 66094;
  v_dados(v_dados.last()).vr_vllanmto := 533.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14216221;
  v_dados(v_dados.last()).vr_nrctremp := 62853;
  v_dados(v_dados.last()).vr_vllanmto := 22.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14430177;
  v_dados(v_dados.last()).vr_nrctremp := 65975;
  v_dados(v_dados.last()).vr_vllanmto := 36.65;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14516950;
  v_dados(v_dados.last()).vr_nrctremp := 71862;
  v_dados(v_dados.last()).vr_vllanmto := 10.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15154521;
  v_dados(v_dados.last()).vr_nrctremp := 92379;
  v_dados(v_dados.last()).vr_vllanmto := 2653.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 50935;
  v_dados(v_dados.last()).vr_vllanmto := 92.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 419869;
  v_dados(v_dados.last()).vr_nrctremp := 55947;
  v_dados(v_dados.last()).vr_vllanmto := 76.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 209066;
  v_dados(v_dados.last()).vr_nrctremp := 56508;
  v_dados(v_dados.last()).vr_vllanmto := 207.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 256544;
  v_dados(v_dados.last()).vr_nrctremp := 58944;
  v_dados(v_dados.last()).vr_vllanmto := 339.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 466.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 441376;
  v_dados(v_dados.last()).vr_nrctremp := 62504;
  v_dados(v_dados.last()).vr_vllanmto := 87.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186805;
  v_dados(v_dados.last()).vr_nrctremp := 63844;
  v_dados(v_dados.last()).vr_vllanmto := 35.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 339067;
  v_dados(v_dados.last()).vr_nrctremp := 67555;
  v_dados(v_dados.last()).vr_vllanmto := 13.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 331490;
  v_dados(v_dados.last()).vr_nrctremp := 73958;
  v_dados(v_dados.last()).vr_vllanmto := 3404.4;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 76421;
  v_dados(v_dados.last()).vr_vllanmto := 141.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 77074;
  v_dados(v_dados.last()).vr_vllanmto := 89.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376744;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 102.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287806;
  v_dados(v_dados.last()).vr_nrctremp := 85063;
  v_dados(v_dados.last()).vr_vllanmto := 1235.72;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 31682;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 20.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521256;
  v_dados(v_dados.last()).vr_nrctremp := 92946;
  v_dados(v_dados.last()).vr_vllanmto := 7.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 61.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 528234;
  v_dados(v_dados.last()).vr_nrctremp := 97211;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 284220;
  v_dados(v_dados.last()).vr_nrctremp := 102835;
  v_dados(v_dados.last()).vr_vllanmto := 845.44;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 544167;
  v_dados(v_dados.last()).vr_nrctremp := 104635;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 331490;
  v_dados(v_dados.last()).vr_nrctremp := 105708;
  v_dados(v_dados.last()).vr_vllanmto := 1159.01;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 105884;
  v_dados(v_dados.last()).vr_vllanmto := 55.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 106976;
  v_dados(v_dados.last()).vr_vllanmto := 13.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 584959;
  v_dados(v_dados.last()).vr_nrctremp := 125901;
  v_dados(v_dados.last()).vr_vllanmto := 5750.9;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 303771;
  v_dados(v_dados.last()).vr_nrctremp := 128054;
  v_dados(v_dados.last()).vr_vllanmto := 49.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 128092;
  v_dados(v_dados.last()).vr_vllanmto := 55.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 584959;
  v_dados(v_dados.last()).vr_nrctremp := 132748;
  v_dados(v_dados.last()).vr_vllanmto := 3942.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 172.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 49.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 544.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150550;
  v_dados(v_dados.last()).vr_nrctremp := 146498;
  v_dados(v_dados.last()).vr_vllanmto := 8.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 153126;
  v_dados(v_dados.last()).vr_vllanmto := 34.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 349780;
  v_dados(v_dados.last()).vr_nrctremp := 153608;
  v_dados(v_dados.last()).vr_vllanmto := 32.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 142565;
  v_dados(v_dados.last()).vr_nrctremp := 157479;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287806;
  v_dados(v_dados.last()).vr_nrctremp := 159595;
  v_dados(v_dados.last()).vr_vllanmto := 5130.12;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 291854;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 157.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 202657;
  v_dados(v_dados.last()).vr_nrctremp := 163091;
  v_dados(v_dados.last()).vr_vllanmto := 295.29;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 140856;
  v_dados(v_dados.last()).vr_nrctremp := 165756;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 252514;
  v_dados(v_dados.last()).vr_nrctremp := 172328;
  v_dados(v_dados.last()).vr_vllanmto := 9.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 598410;
  v_dados(v_dados.last()).vr_nrctremp := 172974;
  v_dados(v_dados.last()).vr_vllanmto := 425.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167924;
  v_dados(v_dados.last()).vr_nrctremp := 175206;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289086;
  v_dados(v_dados.last()).vr_nrctremp := 179357;
  v_dados(v_dados.last()).vr_vllanmto := 33.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 716839;
  v_dados(v_dados.last()).vr_nrctremp := 185741;
  v_dados(v_dados.last()).vr_vllanmto := 103.84;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 192497;
  v_dados(v_dados.last()).vr_vllanmto := 30.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 296295;
  v_dados(v_dados.last()).vr_nrctremp := 194685;
  v_dados(v_dados.last()).vr_vllanmto := 2349.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 625566;
  v_dados(v_dados.last()).vr_nrctremp := 196091;
  v_dados(v_dados.last()).vr_vllanmto := 60.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179922;
  v_dados(v_dados.last()).vr_nrctremp := 196857;
  v_dados(v_dados.last()).vr_vllanmto := 9.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273309;
  v_dados(v_dados.last()).vr_nrctremp := 197758;
  v_dados(v_dados.last()).vr_vllanmto := 80.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14723220;
  v_dados(v_dados.last()).vr_nrctremp := 198279;
  v_dados(v_dados.last()).vr_vllanmto := 9.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61751;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 193.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 385.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647322;
  v_dados(v_dados.last()).vr_nrctremp := 218057;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15205681;
  v_dados(v_dados.last()).vr_nrctremp := 220654;
  v_dados(v_dados.last()).vr_vllanmto := 6.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15209199;
  v_dados(v_dados.last()).vr_nrctremp := 220834;
  v_dados(v_dados.last()).vr_vllanmto := 6.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 680940;
  v_dados(v_dados.last()).vr_nrctremp := 221583;
  v_dados(v_dados.last()).vr_vllanmto := 91.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15241882;
  v_dados(v_dados.last()).vr_nrctremp := 222548;
  v_dados(v_dados.last()).vr_vllanmto := 6.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 6.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66940;
  v_dados(v_dados.last()).vr_nrctremp := 223404;
  v_dados(v_dados.last()).vr_vllanmto := 153.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 696374;
  v_dados(v_dados.last()).vr_nrctremp := 225993;
  v_dados(v_dados.last()).vr_vllanmto := 8.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647462;
  v_dados(v_dados.last()).vr_nrctremp := 227041;
  v_dados(v_dados.last()).vr_vllanmto := 24.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565849;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 22.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 646598;
  v_dados(v_dados.last()).vr_nrctremp := 229644;
  v_dados(v_dados.last()).vr_vllanmto := 16.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172910;
  v_dados(v_dados.last()).vr_nrctremp := 230776;
  v_dados(v_dados.last()).vr_vllanmto := 24.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 639222;
  v_dados(v_dados.last()).vr_nrctremp := 231780;
  v_dados(v_dados.last()).vr_vllanmto := 355.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 246662;
  v_dados(v_dados.last()).vr_nrctremp := 233279;
  v_dados(v_dados.last()).vr_vllanmto := 28.78;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14544717;
  v_dados(v_dados.last()).vr_nrctremp := 236868;
  v_dados(v_dados.last()).vr_vllanmto := 115.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 132560;
  v_dados(v_dados.last()).vr_nrctremp := 239001;
  v_dados(v_dados.last()).vr_vllanmto := 58.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14771675;
  v_dados(v_dados.last()).vr_nrctremp := 240186;
  v_dados(v_dados.last()).vr_vllanmto := 14.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 132560;
  v_dados(v_dados.last()).vr_nrctremp := 244311;
  v_dados(v_dados.last()).vr_vllanmto := 49.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 245701;
  v_dados(v_dados.last()).vr_vllanmto := 8233.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 317250;
  v_dados(v_dados.last()).vr_nrctremp := 247190;
  v_dados(v_dados.last()).vr_vllanmto := 9.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 108561;
  v_dados(v_dados.last()).vr_nrctremp := 249037;
  v_dados(v_dados.last()).vr_vllanmto := 12.97;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15849309;
  v_dados(v_dados.last()).vr_nrctremp := 250564;
  v_dados(v_dados.last()).vr_vllanmto := 9.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 451088;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 13.37;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 695009;
  v_dados(v_dados.last()).vr_nrctremp := 251085;
  v_dados(v_dados.last()).vr_vllanmto := 263.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15940349;
  v_dados(v_dados.last()).vr_nrctremp := 254682;
  v_dados(v_dados.last()).vr_vllanmto := 21.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15941566;
  v_dados(v_dados.last()).vr_nrctremp := 256408;
  v_dados(v_dados.last()).vr_vllanmto := 5.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445517;
  v_dados(v_dados.last()).vr_nrctremp := 256438;
  v_dados(v_dados.last()).vr_vllanmto := 6.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 213926;
  v_dados(v_dados.last()).vr_nrctremp := 257350;
  v_dados(v_dados.last()).vr_vllanmto := 288.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 649856;
  v_dados(v_dados.last()).vr_nrctremp := 259911;
  v_dados(v_dados.last()).vr_vllanmto := 33.43;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16210107;
  v_dados(v_dados.last()).vr_nrctremp := 266658;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 701564;
  v_dados(v_dados.last()).vr_nrctremp := 267305;
  v_dados(v_dados.last()).vr_vllanmto := 20.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211524;
  v_dados(v_dados.last()).vr_nrctremp := 273099;
  v_dados(v_dados.last()).vr_vllanmto := 2814.68;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 214558;
  v_dados(v_dados.last()).vr_nrctremp := 49549;
  v_dados(v_dados.last()).vr_vllanmto := 68.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 265918;
  v_dados(v_dados.last()).vr_nrctremp := 64501;
  v_dados(v_dados.last()).vr_vllanmto := 37.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14096960;
  v_dados(v_dados.last()).vr_nrctremp := 71290;
  v_dados(v_dados.last()).vr_vllanmto := 2081.82;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14096960;
  v_dados(v_dados.last()).vr_nrctremp := 71325;
  v_dados(v_dados.last()).vr_vllanmto := 276.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14132826;
  v_dados(v_dados.last()).vr_nrctremp := 71407;
  v_dados(v_dados.last()).vr_vllanmto := 1651.21;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14186047;
  v_dados(v_dados.last()).vr_nrctremp := 72163;
  v_dados(v_dados.last()).vr_vllanmto := 44.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227789;
  v_dados(v_dados.last()).vr_nrctremp := 72609;
  v_dados(v_dados.last()).vr_vllanmto := 55.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14096960;
  v_dados(v_dados.last()).vr_nrctremp := 73531;
  v_dados(v_dados.last()).vr_vllanmto := 1535.66;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14348390;
  v_dados(v_dados.last()).vr_nrctremp := 74050;
  v_dados(v_dados.last()).vr_vllanmto := 59.87;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14317311;
  v_dados(v_dados.last()).vr_nrctremp := 74301;
  v_dados(v_dados.last()).vr_vllanmto := 46.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14317311;
  v_dados(v_dados.last()).vr_nrctremp := 74303;
  v_dados(v_dados.last()).vr_vllanmto := 36.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14285886;
  v_dados(v_dados.last()).vr_nrctremp := 77187;
  v_dados(v_dados.last()).vr_vllanmto := 55.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 441139;
  v_dados(v_dados.last()).vr_nrctremp := 77668;
  v_dados(v_dados.last()).vr_vllanmto := 11.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14193612;
  v_dados(v_dados.last()).vr_nrctremp := 77995;
  v_dados(v_dados.last()).vr_vllanmto := 2751.65;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14193612;
  v_dados(v_dados.last()).vr_nrctremp := 79376;
  v_dados(v_dados.last()).vr_vllanmto := 2561.97;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203324;
  v_dados(v_dados.last()).vr_nrctremp := 85135;
  v_dados(v_dados.last()).vr_vllanmto := 49.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15145158;
  v_dados(v_dados.last()).vr_nrctremp := 85613;
  v_dados(v_dados.last()).vr_vllanmto := 29.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 414085;
  v_dados(v_dados.last()).vr_nrctremp := 88622;
  v_dados(v_dados.last()).vr_vllanmto := 31.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15695530;
  v_dados(v_dados.last()).vr_nrctremp := 92488;
  v_dados(v_dados.last()).vr_vllanmto := 147.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15912647;
  v_dados(v_dados.last()).vr_nrctremp := 95590;
  v_dados(v_dados.last()).vr_vllanmto := 50.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 95863;
  v_dados(v_dados.last()).vr_vllanmto := 25.26;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15994848;
  v_dados(v_dados.last()).vr_nrctremp := 100163;
  v_dados(v_dados.last()).vr_vllanmto := 58.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16023080;
  v_dados(v_dados.last()).vr_nrctremp := 100243;
  v_dados(v_dados.last()).vr_vllanmto := 520.83;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 288705;
  v_dados(v_dados.last()).vr_nrctremp := 100601;
  v_dados(v_dados.last()).vr_vllanmto := 18.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 155098;
  v_dados(v_dados.last()).vr_nrctremp := 14109;
  v_dados(v_dados.last()).vr_vllanmto := 1004.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 20206;
  v_dados(v_dados.last()).vr_nrctremp := 14702;
  v_dados(v_dados.last()).vr_vllanmto := 2.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143553;
  v_dados(v_dados.last()).vr_nrctremp := 17894;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 76910;
  v_dados(v_dados.last()).vr_nrctremp := 19065;
  v_dados(v_dados.last()).vr_vllanmto := 46.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 165298;
  v_dados(v_dados.last()).vr_nrctremp := 19286;
  v_dados(v_dados.last()).vr_vllanmto := 2.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128244;
  v_dados(v_dados.last()).vr_nrctremp := 20022;
  v_dados(v_dados.last()).vr_vllanmto := 951.74;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166898;
  v_dados(v_dados.last()).vr_nrctremp := 20193;
  v_dados(v_dados.last()).vr_vllanmto := 66.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73130;
  v_dados(v_dados.last()).vr_nrctremp := 20750;
  v_dados(v_dados.last()).vr_vllanmto := 130.84;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 80772;
  v_dados(v_dados.last()).vr_nrctremp := 25808;
  v_dados(v_dados.last()).vr_vllanmto := 100.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73164;
  v_dados(v_dados.last()).vr_nrctremp := 26413;
  v_dados(v_dados.last()).vr_vllanmto := 65.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 164321;
  v_dados(v_dados.last()).vr_nrctremp := 28487;
  v_dados(v_dados.last()).vr_vllanmto := 12.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 133418;
  v_dados(v_dados.last()).vr_nrctremp := 28512;
  v_dados(v_dados.last()).vr_vllanmto := 9.86;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142581;
  v_dados(v_dados.last()).vr_nrctremp := 35077;
  v_dados(v_dados.last()).vr_vllanmto := 58.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187160;
  v_dados(v_dados.last()).vr_nrctremp := 39403;
  v_dados(v_dados.last()).vr_vllanmto := 19.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 129135;
  v_dados(v_dados.last()).vr_nrctremp := 41281;
  v_dados(v_dados.last()).vr_vllanmto := 17.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 204730;
  v_dados(v_dados.last()).vr_nrctremp := 41771;
  v_dados(v_dados.last()).vr_vllanmto := 32.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 52035;
  v_dados(v_dados.last()).vr_nrctremp := 42492;
  v_dados(v_dados.last()).vr_vllanmto := 64.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15988198;
  v_dados(v_dados.last()).vr_nrctremp := 44283;
  v_dados(v_dados.last()).vr_vllanmto := 2180.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 165140;
  v_dados(v_dados.last()).vr_nrctremp := 44775;
  v_dados(v_dados.last()).vr_vllanmto := 38.5;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128228;
  v_dados(v_dados.last()).vr_nrctremp := 45777;
  v_dados(v_dados.last()).vr_vllanmto := 26.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 37605;
  v_dados(v_dados.last()).vr_nrctremp := 45963;
  v_dados(v_dados.last()).vr_vllanmto := 520.83;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16471725;
  v_dados(v_dados.last()).vr_nrctremp := 46086;
  v_dados(v_dados.last()).vr_vllanmto := 72.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 80519;
  v_dados(v_dados.last()).vr_nrctremp := 34345;
  v_dados(v_dados.last()).vr_vllanmto := 13.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 143421;
  v_dados(v_dados.last()).vr_nrctremp := 36375;
  v_dados(v_dados.last()).vr_vllanmto := 2298.79;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 87696;
  v_dados(v_dados.last()).vr_nrctremp := 42976;
  v_dados(v_dados.last()).vr_vllanmto := 64.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 13944347;
  v_dados(v_dados.last()).vr_nrctremp := 49990;
  v_dados(v_dados.last()).vr_vllanmto := 73.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 333425;
  v_dados(v_dados.last()).vr_nrctremp := 63378;
  v_dados(v_dados.last()).vr_vllanmto := 102.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15155455;
  v_dados(v_dados.last()).vr_nrctremp := 80571;
  v_dados(v_dados.last()).vr_vllanmto := 17.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501743;
  v_dados(v_dados.last()).vr_nrctremp := 20100309;
  v_dados(v_dados.last()).vr_vllanmto := 92.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 530689;
  v_dados(v_dados.last()).vr_nrctremp := 21100201;
  v_dados(v_dados.last()).vr_vllanmto := 786.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503185;
  v_dados(v_dados.last()).vr_nrctremp := 21100212;
  v_dados(v_dados.last()).vr_vllanmto := 270.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505757;
  v_dados(v_dados.last()).vr_nrctremp := 21100228;
  v_dados(v_dados.last()).vr_vllanmto := 905.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506087;
  v_dados(v_dados.last()).vr_nrctremp := 21300025;
  v_dados(v_dados.last()).vr_vllanmto := 950.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 962074;
  v_dados(v_dados.last()).vr_nrctremp := 360299;
  v_dados(v_dados.last()).vr_vllanmto := 24.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 989886;
  v_dados(v_dados.last()).vr_nrctremp := 377163;
  v_dados(v_dados.last()).vr_vllanmto := 1363.37;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977101;
  v_dados(v_dados.last()).vr_nrctremp := 396529;
  v_dados(v_dados.last()).vr_vllanmto := 4927.59;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 430933;
  v_dados(v_dados.last()).vr_vllanmto := 53.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 90530;
  v_dados(v_dados.last()).vr_nrctremp := 494717;
  v_dados(v_dados.last()).vr_vllanmto := 2129.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1080253;
  v_dados(v_dados.last()).vr_nrctremp := 617809;
  v_dados(v_dados.last()).vr_vllanmto := 63.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8652007;
  v_dados(v_dados.last()).vr_nrctremp := 2507442;
  v_dados(v_dados.last()).vr_vllanmto := 190.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7669437;
  v_dados(v_dados.last()).vr_nrctremp := 2507640;
  v_dados(v_dados.last()).vr_vllanmto := 95.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80101062;
  v_dados(v_dados.last()).vr_nrctremp := 2955278;
  v_dados(v_dados.last()).vr_vllanmto := 249.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80337074;
  v_dados(v_dados.last()).vr_nrctremp := 2955519;
  v_dados(v_dados.last()).vr_vllanmto := 120.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11776340;
  v_dados(v_dados.last()).vr_nrctremp := 3032948;
  v_dados(v_dados.last()).vr_vllanmto := 37.85;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10654445;
  v_dados(v_dados.last()).vr_nrctremp := 3046625;
  v_dados(v_dados.last()).vr_vllanmto := 8657.36;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80170781;
  v_dados(v_dados.last()).vr_nrctremp := 3472408;
  v_dados(v_dados.last()).vr_vllanmto := 34.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 49.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12425770;
  v_dados(v_dados.last()).vr_nrctremp := 3620293;
  v_dados(v_dados.last()).vr_vllanmto := 212.53;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2752336;
  v_dados(v_dados.last()).vr_nrctremp := 3884678;
  v_dados(v_dados.last()).vr_vllanmto := 8410.39;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12710563;
  v_dados(v_dados.last()).vr_nrctremp := 4075169;
  v_dados(v_dados.last()).vr_vllanmto := 139.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12891185;
  v_dados(v_dados.last()).vr_nrctremp := 4090475;
  v_dados(v_dados.last()).vr_vllanmto := 172.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8390681;
  v_dados(v_dados.last()).vr_nrctremp := 4131111;
  v_dados(v_dados.last()).vr_vllanmto := 107.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7374763;
  v_dados(v_dados.last()).vr_nrctremp := 4178604;
  v_dados(v_dados.last()).vr_vllanmto := 62.28;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11453680;
  v_dados(v_dados.last()).vr_nrctremp := 4189966;
  v_dados(v_dados.last()).vr_vllanmto := 48.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3790622;
  v_dados(v_dados.last()).vr_nrctremp := 4307968;
  v_dados(v_dados.last()).vr_vllanmto := 98.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11204800;
  v_dados(v_dados.last()).vr_nrctremp := 4349266;
  v_dados(v_dados.last()).vr_vllanmto := 236.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9942831;
  v_dados(v_dados.last()).vr_nrctremp := 4445492;
  v_dados(v_dados.last()).vr_vllanmto := 34.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3595803;
  v_dados(v_dados.last()).vr_nrctremp := 4521182;
  v_dados(v_dados.last()).vr_vllanmto := 450.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11934425;
  v_dados(v_dados.last()).vr_nrctremp := 4573117;
  v_dados(v_dados.last()).vr_vllanmto := 324.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7914857;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 46.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11576537;
  v_dados(v_dados.last()).vr_nrctremp := 4674681;
  v_dados(v_dados.last()).vr_vllanmto := 29.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9660143;
  v_dados(v_dados.last()).vr_nrctremp := 4680083;
  v_dados(v_dados.last()).vr_vllanmto := 103.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10670807;
  v_dados(v_dados.last()).vr_nrctremp := 4692518;
  v_dados(v_dados.last()).vr_vllanmto := 82.63;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4045645;
  v_dados(v_dados.last()).vr_nrctremp := 4815888;
  v_dados(v_dados.last()).vr_vllanmto := 609.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8304440;
  v_dados(v_dados.last()).vr_nrctremp := 4879513;
  v_dados(v_dados.last()).vr_vllanmto := 18.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8034656;
  v_dados(v_dados.last()).vr_nrctremp := 5097439;
  v_dados(v_dados.last()).vr_vllanmto := 103.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12381020;
  v_dados(v_dados.last()).vr_nrctremp := 5103175;
  v_dados(v_dados.last()).vr_vllanmto := 319.33;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14310562;
  v_dados(v_dados.last()).vr_nrctremp := 5199705;
  v_dados(v_dados.last()).vr_vllanmto := 40.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739103;
  v_dados(v_dados.last()).vr_nrctremp := 5231445;
  v_dados(v_dados.last()).vr_vllanmto := 26.75;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12809918;
  v_dados(v_dados.last()).vr_nrctremp := 5361272;
  v_dados(v_dados.last()).vr_vllanmto := 184.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10688803;
  v_dados(v_dados.last()).vr_nrctremp := 5460810;
  v_dados(v_dados.last()).vr_vllanmto := 104.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12508551;
  v_dados(v_dados.last()).vr_nrctremp := 5535397;
  v_dados(v_dados.last()).vr_vllanmto := 168.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8624780;
  v_dados(v_dados.last()).vr_nrctremp := 5555185;
  v_dados(v_dados.last()).vr_vllanmto := 343.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14419394;
  v_dados(v_dados.last()).vr_nrctremp := 5573717;
  v_dados(v_dados.last()).vr_vllanmto := 742.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12445959;
  v_dados(v_dados.last()).vr_nrctremp := 5622328;
  v_dados(v_dados.last()).vr_vllanmto := 284.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80338526;
  v_dados(v_dados.last()).vr_nrctremp := 5672938;
  v_dados(v_dados.last()).vr_vllanmto := 14.04;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12202681;
  v_dados(v_dados.last()).vr_nrctremp := 5753900;
  v_dados(v_dados.last()).vr_vllanmto := 172.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12784630;
  v_dados(v_dados.last()).vr_nrctremp := 5782397;
  v_dados(v_dados.last()).vr_vllanmto := 130.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6819567;
  v_dados(v_dados.last()).vr_nrctremp := 5783710;
  v_dados(v_dados.last()).vr_vllanmto := 2149.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916746;
  v_dados(v_dados.last()).vr_vllanmto := 5.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12714666;
  v_dados(v_dados.last()).vr_nrctremp := 5916802;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11326816;
  v_dados(v_dados.last()).vr_nrctremp := 6024671;
  v_dados(v_dados.last()).vr_vllanmto := 62.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9561200;
  v_dados(v_dados.last()).vr_nrctremp := 6084116;
  v_dados(v_dados.last()).vr_vllanmto := 40.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 6131009;
  v_dados(v_dados.last()).vr_vllanmto := 22.63;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9456430;
  v_dados(v_dados.last()).vr_nrctremp := 6215110;
  v_dados(v_dados.last()).vr_vllanmto := 10.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10888314;
  v_dados(v_dados.last()).vr_nrctremp := 6266710;
  v_dados(v_dados.last()).vr_vllanmto := 16.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9519947;
  v_dados(v_dados.last()).vr_nrctremp := 6301326;
  v_dados(v_dados.last()).vr_vllanmto := 2473.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10222243;
  v_dados(v_dados.last()).vr_nrctremp := 6347024;
  v_dados(v_dados.last()).vr_vllanmto := 78.83;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15949559;
  v_dados(v_dados.last()).vr_nrctremp := 6394083;
  v_dados(v_dados.last()).vr_vllanmto := 27.21;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12535150;
  v_dados(v_dados.last()).vr_nrctremp := 6439282;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13436848;
  v_dados(v_dados.last()).vr_nrctremp := 6542144;
  v_dados(v_dados.last()).vr_vllanmto := 19.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2660776;
  v_dados(v_dados.last()).vr_nrctremp := 6682966;
  v_dados(v_dados.last()).vr_vllanmto := 1947.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

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
