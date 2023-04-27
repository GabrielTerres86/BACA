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
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 245701;
  v_dados(v_dados.last()).vr_vllanmto := 2938.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 444499;
  v_dados(v_dados.last()).vr_nrctremp := 90846;
  v_dados(v_dados.last()).vr_vllanmto := 1760.09;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 318639;
  v_dados(v_dados.last()).vr_nrctremp := 58849;
  v_dados(v_dados.last()).vr_vllanmto := 1065.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 326941;
  v_dados(v_dados.last()).vr_nrctremp := 56659;
  v_dados(v_dados.last()).vr_vllanmto := 511.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 511986;
  v_dados(v_dados.last()).vr_nrctremp := 185743;
  v_dados(v_dados.last()).vr_vllanmto := 665.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 568350;
  v_dados(v_dados.last()).vr_nrctremp := 116414;
  v_dados(v_dados.last()).vr_vllanmto := 635.58;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84085;
  v_dados(v_dados.last()).vr_nrctremp := 51903;
  v_dados(v_dados.last()).vr_vllanmto := 510.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561142;
  v_dados(v_dados.last()).vr_nrctremp := 113595;
  v_dados(v_dados.last()).vr_vllanmto := 338.22;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211524;
  v_dados(v_dados.last()).vr_nrctremp := 107457;
  v_dados(v_dados.last()).vr_vllanmto := 265.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 263.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 107620;
  v_dados(v_dados.last()).vr_nrctremp := 132064;
  v_dados(v_dados.last()).vr_vllanmto := 136.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 673854;
  v_dados(v_dados.last()).vr_nrctremp := 167201;
  v_dados(v_dados.last()).vr_vllanmto := 172.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 88480;
  v_dados(v_dados.last()).vr_nrctremp := 97562;
  v_dados(v_dados.last()).vr_vllanmto := 88.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 256544;
  v_dados(v_dados.last()).vr_nrctremp := 58944;
  v_dados(v_dados.last()).vr_vllanmto := 135.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 436801;
  v_dados(v_dados.last()).vr_nrctremp := 218225;
  v_dados(v_dados.last()).vr_vllanmto := 120.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 391549;
  v_dados(v_dados.last()).vr_nrctremp := 112749;
  v_dados(v_dados.last()).vr_vllanmto := 116.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 168572;
  v_dados(v_dados.last()).vr_nrctremp := 86810;
  v_dados(v_dados.last()).vr_vllanmto := 103.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 106976;
  v_dados(v_dados.last()).vr_vllanmto := 101.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 280844;
  v_dados(v_dados.last()).vr_nrctremp := 155954;
  v_dados(v_dados.last()).vr_vllanmto := 85.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 303348;
  v_dados(v_dados.last()).vr_nrctremp := 205922;
  v_dados(v_dados.last()).vr_vllanmto := 79.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 391549;
  v_dados(v_dados.last()).vr_nrctremp := 233462;
  v_dados(v_dados.last()).vr_vllanmto := 78.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 437832;
  v_dados(v_dados.last()).vr_nrctremp := 177937;
  v_dados(v_dados.last()).vr_vllanmto := 52.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 338206;
  v_dados(v_dados.last()).vr_nrctremp := 206053;
  v_dados(v_dados.last()).vr_vllanmto := 33.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 391549;
  v_dados(v_dados.last()).vr_nrctremp := 112758;
  v_dados(v_dados.last()).vr_vllanmto := 56.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638315;
  v_dados(v_dados.last()).vr_nrctremp := 151150;
  v_dados(v_dados.last()).vr_vllanmto := 44.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 128092;
  v_dados(v_dados.last()).vr_vllanmto := 22.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 320935;
  v_dados(v_dados.last()).vr_nrctremp := 231053;
  v_dados(v_dados.last()).vr_vllanmto := 20.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273309;
  v_dados(v_dados.last()).vr_nrctremp := 197758;
  v_dados(v_dados.last()).vr_vllanmto := 18.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156272;
  v_dados(v_dados.last()).vr_nrctremp := 210406;
  v_dados(v_dados.last()).vr_vllanmto := 4.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 352624;
  v_dados(v_dados.last()).vr_nrctremp := 200841;
  v_dados(v_dados.last()).vr_vllanmto := .48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 471828;
  v_dados(v_dados.last()).vr_nrctremp := 208990;
  v_dados(v_dados.last()).vr_vllanmto := 16.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 222053;
  v_dados(v_dados.last()).vr_vllanmto := 18.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 354325;
  v_dados(v_dados.last()).vr_nrctremp := 241840;
  v_dados(v_dados.last()).vr_vllanmto := 22.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 384461;
  v_dados(v_dados.last()).vr_nrctremp := 51220;
  v_dados(v_dados.last()).vr_vllanmto := 23.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 654485;
  v_dados(v_dados.last()).vr_nrctremp := 193159;
  v_dados(v_dados.last()).vr_vllanmto := 25.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698199;
  v_dados(v_dados.last()).vr_nrctremp := 203008;
  v_dados(v_dados.last()).vr_vllanmto := 25.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 319929;
  v_dados(v_dados.last()).vr_nrctremp := 96594;
  v_dados(v_dados.last()).vr_vllanmto := 28.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480568;
  v_dados(v_dados.last()).vr_nrctremp := 173188;
  v_dados(v_dados.last()).vr_vllanmto := 38.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136816;
  v_dados(v_dados.last()).vr_nrctremp := 189224;
  v_dados(v_dados.last()).vr_vllanmto := 50.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 211585;
  v_dados(v_dados.last()).vr_vllanmto := 58.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 608203;
  v_dados(v_dados.last()).vr_nrctremp := 192597;
  v_dados(v_dados.last()).vr_vllanmto := 74.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 379301;
  v_dados(v_dados.last()).vr_nrctremp := 52196;
  v_dados(v_dados.last()).vr_vllanmto := 81.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14404796;
  v_dados(v_dados.last()).vr_nrctremp := 204015;
  v_dados(v_dados.last()).vr_vllanmto := 86.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 625566;
  v_dados(v_dados.last()).vr_nrctremp := 196091;
  v_dados(v_dados.last()).vr_vllanmto := 95.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 493341;
  v_dados(v_dados.last()).vr_nrctremp := 193908;
  v_dados(v_dados.last()).vr_vllanmto := 100.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 199788;
  v_dados(v_dados.last()).vr_nrctremp := 164878;
  v_dados(v_dados.last()).vr_vllanmto := 104.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 654426;
  v_dados(v_dados.last()).vr_nrctremp := 265365;
  v_dados(v_dados.last()).vr_vllanmto := 126.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 386545;
  v_dados(v_dados.last()).vr_nrctremp := 51508;
  v_dados(v_dados.last()).vr_vllanmto := 147.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 209066;
  v_dados(v_dados.last()).vr_nrctremp := 56508;
  v_dados(v_dados.last()).vr_vllanmto := 150.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 672130;
  v_dados(v_dados.last()).vr_nrctremp := 166378;
  v_dados(v_dados.last()).vr_vllanmto := 260.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 206679;
  v_dados(v_dados.last()).vr_nrctremp := 111871;
  v_dados(v_dados.last()).vr_vllanmto := 263.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 282.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240540;
  v_dados(v_dados.last()).vr_nrctremp := 95357;
  v_dados(v_dados.last()).vr_vllanmto := 358.46;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149896;
  v_dados(v_dados.last()).vr_nrctremp := 190247;
  v_dados(v_dados.last()).vr_vllanmto := 385.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 452360;
  v_dados(v_dados.last()).vr_nrctremp := 239638;
  v_dados(v_dados.last()).vr_vllanmto := 436.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 598410;
  v_dados(v_dados.last()).vr_nrctremp := 172974;
  v_dados(v_dados.last()).vr_vllanmto := 518.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 311863;
  v_dados(v_dados.last()).vr_nrctremp := 135708;
  v_dados(v_dados.last()).vr_vllanmto := 548.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149896;
  v_dados(v_dados.last()).vr_nrctremp := 191066;
  v_dados(v_dados.last()).vr_vllanmto := 580.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 655724;
  v_dados(v_dados.last()).vr_nrctremp := 264353;
  v_dados(v_dados.last()).vr_vllanmto := 749.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16102690;
  v_dados(v_dados.last()).vr_nrctremp := 266089;
  v_dados(v_dados.last()).vr_vllanmto := 754.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 576042;
  v_dados(v_dados.last()).vr_nrctremp := 268554;
  v_dados(v_dados.last()).vr_vllanmto := 871.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16148312;
  v_dados(v_dados.last()).vr_nrctremp := 264341;
  v_dados(v_dados.last()).vr_vllanmto := 947.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 951.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211036;
  v_dados(v_dados.last()).vr_nrctremp := 197376;
  v_dados(v_dados.last()).vr_vllanmto := 1614.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561142;
  v_dados(v_dados.last()).vr_nrctremp := 122251;
  v_dados(v_dados.last()).vr_vllanmto := 2301.28;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561142;
  v_dados(v_dados.last()).vr_nrctremp := 134641;
  v_dados(v_dados.last()).vr_vllanmto := 3192.05;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 355771;
  v_dados(v_dados.last()).vr_nrctremp := 144078;
  v_dados(v_dados.last()).vr_vllanmto := 3266.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 568350;
  v_dados(v_dados.last()).vr_nrctremp := 153429;
  v_dados(v_dados.last()).vr_vllanmto := 4069.73;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

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
