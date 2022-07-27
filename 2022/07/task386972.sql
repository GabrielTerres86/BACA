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
  v_dados(v_dados.last()).vr_nrdconta := 174874;
  v_dados(v_dados.last()).vr_nrctremp := 51025;
  v_dados(v_dados.last()).vr_vllanmto := 1.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 292770;
  v_dados(v_dados.last()).vr_nrctremp := 51071;
  v_dados(v_dados.last()).vr_vllanmto := 131.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156396;
  v_dados(v_dados.last()).vr_nrctremp := 52531;
  v_dados(v_dados.last()).vr_vllanmto := 1065.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 214710;
  v_dados(v_dados.last()).vr_nrctremp := 53208;
  v_dados(v_dados.last()).vr_vllanmto := 28.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 180556;
  v_dados(v_dados.last()).vr_nrctremp := 54036;
  v_dados(v_dados.last()).vr_vllanmto := 7130.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136352;
  v_dados(v_dados.last()).vr_nrctremp := 54568;
  v_dados(v_dados.last()).vr_vllanmto := 285.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 228079;
  v_dados(v_dados.last()).vr_nrctremp := 54753;
  v_dados(v_dados.last()).vr_vllanmto := .22;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287113;
  v_dados(v_dados.last()).vr_nrctremp := 56588;
  v_dados(v_dados.last()).vr_vllanmto := 3.64;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143790;
  v_dados(v_dados.last()).vr_nrctremp := 56730;
  v_dados(v_dados.last()).vr_vllanmto := .07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 267015;
  v_dados(v_dados.last()).vr_nrctremp := 57081;
  v_dados(v_dados.last()).vr_vllanmto := 51.86;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153141;
  v_dados(v_dados.last()).vr_nrctremp := 57245;
  v_dados(v_dados.last()).vr_vllanmto := 5.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 367389;
  v_dados(v_dados.last()).vr_nrctremp := 59342;
  v_dados(v_dados.last()).vr_vllanmto := 140.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 23388;
  v_dados(v_dados.last()).vr_nrctremp := 59749;
  v_dados(v_dados.last()).vr_vllanmto := 6.13;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170453;
  v_dados(v_dados.last()).vr_nrctremp := 59887;
  v_dados(v_dados.last()).vr_vllanmto := 100.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 265187;
  v_dados(v_dados.last()).vr_nrctremp := 60113;
  v_dados(v_dados.last()).vr_vllanmto := .24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26590;
  v_dados(v_dados.last()).vr_nrctremp := 61342;
  v_dados(v_dados.last()).vr_vllanmto := 2.55;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 158259;
  v_dados(v_dados.last()).vr_nrctremp := 61665;
  v_dados(v_dados.last()).vr_vllanmto := .66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 292770;
  v_dados(v_dados.last()).vr_nrctremp := 65537;
  v_dados(v_dados.last()).vr_vllanmto := 33.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 339067;
  v_dados(v_dados.last()).vr_nrctremp := 67555;
  v_dados(v_dados.last()).vr_vllanmto := .41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299090;
  v_dados(v_dados.last()).vr_nrctremp := 68183;
  v_dados(v_dados.last()).vr_vllanmto := 83.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 226327;
  v_dados(v_dados.last()).vr_nrctremp := 70203;
  v_dados(v_dados.last()).vr_vllanmto := .04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129410;
  v_dados(v_dados.last()).vr_nrctremp := 70619;
  v_dados(v_dados.last()).vr_vllanmto := 361.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186201;
  v_dados(v_dados.last()).vr_nrctremp := 71865;
  v_dados(v_dados.last()).vr_vllanmto := 167.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 468380;
  v_dados(v_dados.last()).vr_nrctremp := 72484;
  v_dados(v_dados.last()).vr_vllanmto := .33;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26670;
  v_dados(v_dados.last()).vr_nrctremp := 73346;
  v_dados(v_dados.last()).vr_vllanmto := 74.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467448;
  v_dados(v_dados.last()).vr_nrctremp := 73978;
  v_dados(v_dados.last()).vr_vllanmto := 6.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 198030;
  v_dados(v_dados.last()).vr_nrctremp := 74436;
  v_dados(v_dados.last()).vr_vllanmto := .46;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316776;
  v_dados(v_dados.last()).vr_nrctremp := 78219;
  v_dados(v_dados.last()).vr_vllanmto := .48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 298980;
  v_dados(v_dados.last()).vr_nrctremp := 78268;
  v_dados(v_dados.last()).vr_vllanmto := 4670.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376744;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 177.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480991;
  v_dados(v_dados.last()).vr_nrctremp := 78627;
  v_dados(v_dados.last()).vr_vllanmto := 213.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179752;
  v_dados(v_dados.last()).vr_nrctremp := 79024;
  v_dados(v_dados.last()).vr_vllanmto := 859.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 105015;
  v_dados(v_dados.last()).vr_nrctremp := 79537;
  v_dados(v_dados.last()).vr_vllanmto := 10997.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 105015;
  v_dados(v_dados.last()).vr_nrctremp := 80153;
  v_dados(v_dados.last()).vr_vllanmto := 1662.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188662;
  v_dados(v_dados.last()).vr_nrctremp := 80612;
  v_dados(v_dados.last()).vr_vllanmto := 8.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163716;
  v_dados(v_dados.last()).vr_nrctremp := 81143;
  v_dados(v_dados.last()).vr_vllanmto := 435.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462160;
  v_dados(v_dados.last()).vr_nrctremp := 81229;
  v_dados(v_dados.last()).vr_vllanmto := 75.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 490695;
  v_dados(v_dados.last()).vr_nrctremp := 81575;
  v_dados(v_dados.last()).vr_vllanmto := 1590.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 298980;
  v_dados(v_dados.last()).vr_nrctremp := 83561;
  v_dados(v_dados.last()).vr_vllanmto := 8262.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 84128;
  v_dados(v_dados.last()).vr_vllanmto := 8.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15539;
  v_dados(v_dados.last()).vr_nrctremp := 84854;
  v_dados(v_dados.last()).vr_vllanmto := 1.3;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 241164;
  v_dados(v_dados.last()).vr_nrctremp := 86674;
  v_dados(v_dados.last()).vr_vllanmto := .57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 168572;
  v_dados(v_dados.last()).vr_nrctremp := 86810;
  v_dados(v_dados.last()).vr_vllanmto := 72.47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 501786;
  v_dados(v_dados.last()).vr_nrctremp := 86925;
  v_dados(v_dados.last()).vr_vllanmto := 8.27;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188662;
  v_dados(v_dados.last()).vr_nrctremp := 88267;
  v_dados(v_dados.last()).vr_vllanmto := .48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 31682;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 2.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187895;
  v_dados(v_dados.last()).vr_nrctremp := 91363;
  v_dados(v_dados.last()).vr_vllanmto := 408.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92428;
  v_dados(v_dados.last()).vr_nrctremp := 94314;
  v_dados(v_dados.last()).vr_vllanmto := 58.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167924;
  v_dados(v_dados.last()).vr_nrctremp := 94867;
  v_dados(v_dados.last()).vr_vllanmto := 7.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240540;
  v_dados(v_dados.last()).vr_nrctremp := 95357;
  v_dados(v_dados.last()).vr_vllanmto := 2.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163384;
  v_dados(v_dados.last()).vr_nrctremp := 95795;
  v_dados(v_dados.last()).vr_vllanmto := 595.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211036;
  v_dados(v_dados.last()).vr_nrctremp := 95812;
  v_dados(v_dados.last()).vr_vllanmto := 6.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 319929;
  v_dados(v_dados.last()).vr_nrctremp := 96594;
  v_dados(v_dados.last()).vr_vllanmto := .64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 64955;
  v_dados(v_dados.last()).vr_nrctremp := 98020;
  v_dados(v_dados.last()).vr_vllanmto := 4.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 212849;
  v_dados(v_dados.last()).vr_nrctremp := 99450;
  v_dados(v_dados.last()).vr_vllanmto := .54;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 201308;
  v_dados(v_dados.last()).vr_nrctremp := 99812;
  v_dados(v_dados.last()).vr_vllanmto := 24.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 100197;
  v_dados(v_dados.last()).vr_vllanmto := 726.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 103349;
  v_dados(v_dados.last()).vr_nrctremp := 100759;
  v_dados(v_dados.last()).vr_vllanmto := .36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480568;
  v_dados(v_dados.last()).vr_nrctremp := 100924;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78131;
  v_dados(v_dados.last()).vr_nrctremp := 101326;
  v_dados(v_dados.last()).vr_vllanmto := 4451.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187747;
  v_dados(v_dados.last()).vr_nrctremp := 101671;
  v_dados(v_dados.last()).vr_vllanmto := .12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 379093;
  v_dados(v_dados.last()).vr_nrctremp := 102367;
  v_dados(v_dados.last()).vr_vllanmto := 227.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 96245;
  v_dados(v_dados.last()).vr_nrctremp := 102741;
  v_dados(v_dados.last()).vr_vllanmto := 7.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 284220;
  v_dados(v_dados.last()).vr_nrctremp := 102835;
  v_dados(v_dados.last()).vr_vllanmto := 4.75;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188123;
  v_dados(v_dados.last()).vr_nrctremp := 102857;
  v_dados(v_dados.last()).vr_vllanmto := 2.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 142670;
  v_dados(v_dados.last()).vr_nrctremp := 103431;
  v_dados(v_dados.last()).vr_vllanmto := 1.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 549860;
  v_dados(v_dados.last()).vr_nrctremp := 107888;
  v_dados(v_dados.last()).vr_vllanmto := 21.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 282936;
  v_dados(v_dados.last()).vr_nrctremp := 109758;
  v_dados(v_dados.last()).vr_vllanmto := 53.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548685;
  v_dados(v_dados.last()).vr_nrctremp := 110594;
  v_dados(v_dados.last()).vr_vllanmto := .48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160318;
  v_dados(v_dados.last()).vr_nrctremp := 110737;
  v_dados(v_dados.last()).vr_vllanmto := .4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 334685;
  v_dados(v_dados.last()).vr_nrctremp := 111025;
  v_dados(v_dados.last()).vr_vllanmto := 77.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240133;
  v_dados(v_dados.last()).vr_nrctremp := 111158;
  v_dados(v_dados.last()).vr_vllanmto := .57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 25518;
  v_dados(v_dados.last()).vr_nrctremp := 111541;
  v_dados(v_dados.last()).vr_vllanmto := 26.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 112941;
  v_dados(v_dados.last()).vr_nrctremp := 112912;
  v_dados(v_dados.last()).vr_vllanmto := 2.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480568;
  v_dados(v_dados.last()).vr_nrctremp := 113358;
  v_dados(v_dados.last()).vr_vllanmto := 6.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 320935;
  v_dados(v_dados.last()).vr_nrctremp := 114943;
  v_dados(v_dados.last()).vr_vllanmto := 8.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179043;
  v_dados(v_dados.last()).vr_nrctremp := 117292;
  v_dados(v_dados.last()).vr_vllanmto := .24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 180815;
  v_dados(v_dados.last()).vr_nrctremp := 118018;
  v_dados(v_dados.last()).vr_vllanmto := .4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 571628;
  v_dados(v_dados.last()).vr_nrctremp := 118254;
  v_dados(v_dados.last()).vr_vllanmto := .57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 131091;
  v_dados(v_dados.last()).vr_nrctremp := 119113;
  v_dados(v_dados.last()).vr_vllanmto := .34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211036;
  v_dados(v_dados.last()).vr_nrctremp := 119774;
  v_dados(v_dados.last()).vr_vllanmto := 5.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 152455;
  v_dados(v_dados.last()).vr_nrctremp := 120690;
  v_dados(v_dados.last()).vr_vllanmto := 756.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160571;
  v_dados(v_dados.last()).vr_nrctremp := 123336;
  v_dados(v_dados.last()).vr_vllanmto := 6833.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190357;
  v_dados(v_dados.last()).vr_nrctremp := 129690;
  v_dados(v_dados.last()).vr_vllanmto := 19.75;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 75906;
  v_dados(v_dados.last()).vr_nrctremp := 133121;
  v_dados(v_dados.last()).vr_vllanmto := .36;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561142;
  v_dados(v_dados.last()).vr_nrctremp := 134641;
  v_dados(v_dados.last()).vr_vllanmto := .43;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350605;
  v_dados(v_dados.last()).vr_nrctremp := 135118;
  v_dados(v_dados.last()).vr_vllanmto := 5.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273724;
  v_dados(v_dados.last()).vr_nrctremp := 135478;
  v_dados(v_dados.last()).vr_vllanmto := .29;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328227;
  v_dados(v_dados.last()).vr_nrctremp := 136480;
  v_dados(v_dados.last()).vr_vllanmto := 3.89;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299227;
  v_dados(v_dados.last()).vr_nrctremp := 136637;
  v_dados(v_dados.last()).vr_vllanmto := 1.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146153;
  v_dados(v_dados.last()).vr_nrctremp := 136699;
  v_dados(v_dados.last()).vr_vllanmto := 25.19;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184586;
  v_dados(v_dados.last()).vr_nrctremp := 136806;
  v_dados(v_dados.last()).vr_vllanmto := 6.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 71757;
  v_dados(v_dados.last()).vr_nrctremp := 136891;
  v_dados(v_dados.last()).vr_vllanmto := 6.89;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614424;
  v_dados(v_dados.last()).vr_nrctremp := 136928;
  v_dados(v_dados.last()).vr_vllanmto := 13.52;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172421;
  v_dados(v_dados.last()).vr_nrctremp := 137031;
  v_dados(v_dados.last()).vr_vllanmto := 9.88;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172421;
  v_dados(v_dados.last()).vr_nrctremp := 137032;
  v_dados(v_dados.last()).vr_vllanmto := 1.85;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350605;
  v_dados(v_dados.last()).vr_nrctremp := 137039;
  v_dados(v_dados.last()).vr_vllanmto := 2.99;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 131091;
  v_dados(v_dados.last()).vr_nrctremp := 137047;
  v_dados(v_dados.last()).vr_vllanmto := .7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 256757;
  v_dados(v_dados.last()).vr_nrctremp := 137189;
  v_dados(v_dados.last()).vr_vllanmto := 4.39;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187020;
  v_dados(v_dados.last()).vr_nrctremp := 137318;
  v_dados(v_dados.last()).vr_vllanmto := 1.99;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 147990;
  v_dados(v_dados.last()).vr_nrctremp := 137559;
  v_dados(v_dados.last()).vr_vllanmto := 4.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 147990;
  v_dados(v_dados.last()).vr_nrctremp := 137561;
  v_dados(v_dados.last()).vr_vllanmto := 5.81;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 617482;
  v_dados(v_dados.last()).vr_nrctremp := 137775;
  v_dados(v_dados.last()).vr_vllanmto := 8.64;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 616346;
  v_dados(v_dados.last()).vr_nrctremp := 137941;
  v_dados(v_dados.last()).vr_vllanmto := 11.7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 318248;
  v_dados(v_dados.last()).vr_nrctremp := 137990;
  v_dados(v_dados.last()).vr_vllanmto := 4.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 67261;
  v_dados(v_dados.last()).vr_nrctremp := 138194;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 70386;
  v_dados(v_dados.last()).vr_nrctremp := 138212;
  v_dados(v_dados.last()).vr_vllanmto := 6.98;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145190;
  v_dados(v_dados.last()).vr_nrctremp := 138246;
  v_dados(v_dados.last()).vr_vllanmto := 2.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 495310;
  v_dados(v_dados.last()).vr_nrctremp := 138280;
  v_dados(v_dados.last()).vr_vllanmto := 2.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 615366;
  v_dados(v_dados.last()).vr_nrctremp := 138297;
  v_dados(v_dados.last()).vr_vllanmto := 84.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66800;
  v_dados(v_dados.last()).vr_nrctremp := 138302;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248789;
  v_dados(v_dados.last()).vr_nrctremp := 138349;
  v_dados(v_dados.last()).vr_vllanmto := 53.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129127;
  v_dados(v_dados.last()).vr_nrctremp := 138460;
  v_dados(v_dados.last()).vr_vllanmto := 6.08;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 302996;
  v_dados(v_dados.last()).vr_nrctremp := 138689;
  v_dados(v_dados.last()).vr_vllanmto := .96;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 442054;
  v_dados(v_dados.last()).vr_nrctremp := 138713;
  v_dados(v_dados.last()).vr_vllanmto := 1.35;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548685;
  v_dados(v_dados.last()).vr_nrctremp := 138828;
  v_dados(v_dados.last()).vr_vllanmto := 3.46;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 609447;
  v_dados(v_dados.last()).vr_nrctremp := 139009;
  v_dados(v_dados.last()).vr_vllanmto := 3.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185272;
  v_dados(v_dados.last()).vr_nrctremp := 139153;
  v_dados(v_dados.last()).vr_vllanmto := 4.17;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167193;
  v_dados(v_dados.last()).vr_nrctremp := 139399;
  v_dados(v_dados.last()).vr_vllanmto := 9.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167193;
  v_dados(v_dados.last()).vr_nrctremp := 139402;
  v_dados(v_dados.last()).vr_vllanmto := 4.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 497819;
  v_dados(v_dados.last()).vr_nrctremp := 139587;
  v_dados(v_dados.last()).vr_vllanmto := 10.43;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66877;
  v_dados(v_dados.last()).vr_nrctremp := 139636;
  v_dados(v_dados.last()).vr_vllanmto := 1439.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480568;
  v_dados(v_dados.last()).vr_nrctremp := 139833;
  v_dados(v_dados.last()).vr_vllanmto := 3.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 334936;
  v_dados(v_dados.last()).vr_nrctremp := 139875;
  v_dados(v_dados.last()).vr_vllanmto := .73;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129860;
  v_dados(v_dados.last()).vr_nrctremp := 139883;
  v_dados(v_dados.last()).vr_vllanmto := 5.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 252212;
  v_dados(v_dados.last()).vr_nrctremp := 140398;
  v_dados(v_dados.last()).vr_vllanmto := 3.12;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18180;
  v_dados(v_dados.last()).vr_nrctremp := 140475;
  v_dados(v_dados.last()).vr_vllanmto := 26.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 9.54;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 368857;
  v_dados(v_dados.last()).vr_nrctremp := 141765;
  v_dados(v_dados.last()).vr_vllanmto := 1.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141496;
  v_dados(v_dados.last()).vr_nrctremp := 143813;
  v_dados(v_dados.last()).vr_vllanmto := 4775.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143928;
  v_dados(v_dados.last()).vr_nrctremp := 143897;
  v_dados(v_dados.last()).vr_vllanmto := 8.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143480;
  v_dados(v_dados.last()).vr_nrctremp := 144084;
  v_dados(v_dados.last()).vr_vllanmto := 239.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141496;
  v_dados(v_dados.last()).vr_nrctremp := 144134;
  v_dados(v_dados.last()).vr_vllanmto := 5928.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190985;
  v_dados(v_dados.last()).vr_nrctremp := 144153;
  v_dados(v_dados.last()).vr_vllanmto := 9.52;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 461610;
  v_dados(v_dados.last()).vr_nrctremp := 145393;
  v_dados(v_dados.last()).vr_vllanmto := 5.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145998;
  v_dados(v_dados.last()).vr_nrctremp := 145708;
  v_dados(v_dados.last()).vr_vllanmto := 10.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145998;
  v_dados(v_dados.last()).vr_nrctremp := 145980;
  v_dados(v_dados.last()).vr_vllanmto := 2.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 635669;
  v_dados(v_dados.last()).vr_nrctremp := 146059;
  v_dados(v_dados.last()).vr_vllanmto := 1.09;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184349;
  v_dados(v_dados.last()).vr_nrctremp := 146087;
  v_dados(v_dados.last()).vr_vllanmto := 7.86;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187860;
  v_dados(v_dados.last()).vr_nrctremp := 146395;
  v_dados(v_dados.last()).vr_vllanmto := 4.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187860;
  v_dados(v_dados.last()).vr_nrctremp := 146397;
  v_dados(v_dados.last()).vr_vllanmto := 1.79;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 257214;
  v_dados(v_dados.last()).vr_nrctremp := 146417;
  v_dados(v_dados.last()).vr_vllanmto := 7.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 52507;
  v_dados(v_dados.last()).vr_nrctremp := 146859;
  v_dados(v_dados.last()).vr_vllanmto := 4.64;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350893;
  v_dados(v_dados.last()).vr_nrctremp := 146914;
  v_dados(v_dados.last()).vr_vllanmto := 5.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272116;
  v_dados(v_dados.last()).vr_nrctremp := 146978;
  v_dados(v_dados.last()).vr_vllanmto := 9.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420883;
  v_dados(v_dados.last()).vr_nrctremp := 147127;
  v_dados(v_dados.last()).vr_vllanmto := 4.39;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 159972;
  v_dados(v_dados.last()).vr_nrctremp := 147219;
  v_dados(v_dados.last()).vr_vllanmto := 6.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146153;
  v_dados(v_dados.last()).vr_nrctremp := 147274;
  v_dados(v_dados.last()).vr_vllanmto := 1.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193810;
  v_dados(v_dados.last()).vr_nrctremp := 147432;
  v_dados(v_dados.last()).vr_vllanmto := 5.7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 237396;
  v_dados(v_dados.last()).vr_nrctremp := 147484;
  v_dados(v_dados.last()).vr_vllanmto := 3.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 322890;
  v_dados(v_dados.last()).vr_nrctremp := 147538;
  v_dados(v_dados.last()).vr_vllanmto := 4.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420441;
  v_dados(v_dados.last()).vr_nrctremp := 147680;
  v_dados(v_dados.last()).vr_vllanmto := 9.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188557;
  v_dados(v_dados.last()).vr_nrctremp := 148103;
  v_dados(v_dados.last()).vr_vllanmto := 1.11;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 60658;
  v_dados(v_dados.last()).vr_nrctremp := 148215;
  v_dados(v_dados.last()).vr_vllanmto := 3.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 364037;
  v_dados(v_dados.last()).vr_nrctremp := 148552;
  v_dados(v_dados.last()).vr_vllanmto := 4.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467367;
  v_dados(v_dados.last()).vr_nrctremp := 149121;
  v_dados(v_dados.last()).vr_vllanmto := 2.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 323004;
  v_dados(v_dados.last()).vr_nrctremp := 149276;
  v_dados(v_dados.last()).vr_vllanmto := 5.76;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 213578;
  v_dados(v_dados.last()).vr_nrctremp := 149469;
  v_dados(v_dados.last()).vr_vllanmto := 2.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 266744;
  v_dados(v_dados.last()).vr_nrctremp := 149927;
  v_dados(v_dados.last()).vr_vllanmto := 8.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 266744;
  v_dados(v_dados.last()).vr_nrctremp := 149931;
  v_dados(v_dados.last()).vr_vllanmto := 1.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22187;
  v_dados(v_dados.last()).vr_nrctremp := 149937;
  v_dados(v_dados.last()).vr_vllanmto := 1.38;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 96229;
  v_dados(v_dados.last()).vr_nrctremp := 150075;
  v_dados(v_dados.last()).vr_vllanmto := 6.79;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 130923;
  v_dados(v_dados.last()).vr_nrctremp := 150081;
  v_dados(v_dados.last()).vr_vllanmto := 9.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561860;
  v_dados(v_dados.last()).vr_nrctremp := 150316;
  v_dados(v_dados.last()).vr_vllanmto := 1.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 626368;
  v_dados(v_dados.last()).vr_nrctremp := 150466;
  v_dados(v_dados.last()).vr_vllanmto := 6.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 103608;
  v_dados(v_dados.last()).vr_nrctremp := 150645;
  v_dados(v_dados.last()).vr_vllanmto := 7.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638315;
  v_dados(v_dados.last()).vr_nrctremp := 151150;
  v_dados(v_dados.last()).vr_vllanmto := 5.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172448;
  v_dados(v_dados.last()).vr_nrctremp := 151453;
  v_dados(v_dados.last()).vr_vllanmto := 7.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 360961;
  v_dados(v_dados.last()).vr_nrctremp := 151569;
  v_dados(v_dados.last()).vr_vllanmto := 2.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 151743;
  v_dados(v_dados.last()).vr_vllanmto := 6.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146013;
  v_dados(v_dados.last()).vr_nrctremp := 154533;
  v_dados(v_dados.last()).vr_vllanmto := 5.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 249505;
  v_dados(v_dados.last()).vr_nrctremp := 155016;
  v_dados(v_dados.last()).vr_vllanmto := 2.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 353507;
  v_dados(v_dados.last()).vr_nrctremp := 155363;
  v_dados(v_dados.last()).vr_vllanmto := 5.43;
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
