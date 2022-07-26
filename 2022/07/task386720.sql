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
    v_dados(v_dados.last()).vr_nrdconta := 117056;
    v_dados(v_dados.last()).vr_nrctremp := 51037;
    v_dados(v_dados.last()).vr_vllanmto := 3477.64;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180556;
    v_dados(v_dados.last()).vr_nrctremp := 54036;
    v_dados(v_dados.last()).vr_vllanmto := 7130.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 60075;
    v_dados(v_dados.last()).vr_vllanmto := 16.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 60113;
    v_dados(v_dados.last()).vr_vllanmto := 2.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 61665;
    v_dados(v_dados.last()).vr_vllanmto := .66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 65227;
    v_dados(v_dados.last()).vr_vllanmto := 810.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360287;
    v_dados(v_dados.last()).vr_nrctremp := 66651;
    v_dados(v_dados.last()).vr_vllanmto := 1309.91;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 2.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 77509;
    v_dados(v_dados.last()).vr_vllanmto := 1.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316776;
    v_dados(v_dados.last()).vr_nrctremp := 78219;
    v_dados(v_dados.last()).vr_vllanmto := 1.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396990;
    v_dados(v_dados.last()).vr_nrctremp := 80320;
    v_dados(v_dados.last()).vr_vllanmto := 285.1;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 375160;
    v_dados(v_dados.last()).vr_nrctremp := 85045;
    v_dados(v_dados.last()).vr_vllanmto := 11.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185426;
    v_dados(v_dados.last()).vr_nrctremp := 86080;
    v_dados(v_dados.last()).vr_vllanmto := .26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273872;
    v_dados(v_dados.last()).vr_nrctremp := 90163;
    v_dados(v_dados.last()).vr_vllanmto := 1.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 92615;
    v_dados(v_dados.last()).vr_vllanmto := .22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 95562;
    v_dados(v_dados.last()).vr_vllanmto := .77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 96427;
    v_dados(v_dados.last()).vr_vllanmto := 2.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290246;
    v_dados(v_dados.last()).vr_nrctremp := 96871;
    v_dados(v_dados.last()).vr_vllanmto := 1.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 98595;
    v_dados(v_dados.last()).vr_vllanmto := 340.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 99782;
    v_dados(v_dados.last()).vr_vllanmto := 2.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 436534;
    v_dados(v_dados.last()).vr_nrctremp := 100797;
    v_dados(v_dados.last()).vr_vllanmto := 1.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503533;
    v_dados(v_dados.last()).vr_nrctremp := 101013;
    v_dados(v_dados.last()).vr_vllanmto := 1.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503584;
    v_dados(v_dados.last()).vr_nrctremp := 102245;
    v_dados(v_dados.last()).vr_vllanmto := 34.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142670;
    v_dados(v_dados.last()).vr_nrctremp := 103431;
    v_dados(v_dados.last()).vr_vllanmto := 1.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 104655;
    v_dados(v_dados.last()).vr_vllanmto := 1.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 105430;
    v_dados(v_dados.last()).vr_vllanmto := 3.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 106540;
    v_dados(v_dados.last()).vr_vllanmto := 20.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26654;
    v_dados(v_dados.last()).vr_nrctremp := 108177;
    v_dados(v_dados.last()).vr_vllanmto := 5.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 108200;
    v_dados(v_dados.last()).vr_vllanmto := .27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110736;
    v_dados(v_dados.last()).vr_vllanmto := 2.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 5.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191833;
    v_dados(v_dados.last()).vr_nrctremp := 111117;
    v_dados(v_dados.last()).vr_vllanmto := 2.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 111312;
    v_dados(v_dados.last()).vr_vllanmto := 6.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102016;
    v_dados(v_dados.last()).vr_nrctremp := 111438;
    v_dados(v_dados.last()).vr_vllanmto := 21.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127027;
    v_dados(v_dados.last()).vr_nrctremp := 111887;
    v_dados(v_dados.last()).vr_vllanmto := .01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479080;
    v_dados(v_dados.last()).vr_nrctremp := 112509;
    v_dados(v_dados.last()).vr_vllanmto := 1.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112689;
    v_dados(v_dados.last()).vr_vllanmto := 1.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215937;
    v_dados(v_dados.last()).vr_nrctremp := 112915;
    v_dados(v_dados.last()).vr_vllanmto := 9.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150550;
    v_dados(v_dados.last()).vr_nrctremp := 113707;
    v_dados(v_dados.last()).vr_vllanmto := 6.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115869;
    v_dados(v_dados.last()).vr_vllanmto := 24.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 117990;
    v_dados(v_dados.last()).vr_vllanmto := 2.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180815;
    v_dados(v_dados.last()).vr_nrctremp := 118016;
    v_dados(v_dados.last()).vr_vllanmto := 2.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149896;
    v_dados(v_dados.last()).vr_nrctremp := 118073;
    v_dados(v_dados.last()).vr_vllanmto := 3.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 571628;
    v_dados(v_dados.last()).vr_nrctremp := 118254;
    v_dados(v_dados.last()).vr_vllanmto := 1.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 573957;
    v_dados(v_dados.last()).vr_nrctremp := 119378;
    v_dados(v_dados.last()).vr_vllanmto := 18.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 121365;
    v_dados(v_dados.last()).vr_vllanmto := 16.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 13.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124282;
    v_dados(v_dados.last()).vr_vllanmto := 6.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124334;
    v_dados(v_dados.last()).vr_vllanmto := 10.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 125887;
    v_dados(v_dados.last()).vr_vllanmto := 14.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 127079;
    v_dados(v_dados.last()).vr_vllanmto := 16.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128314;
    v_dados(v_dados.last()).vr_vllanmto := 3.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 543144;
    v_dados(v_dados.last()).vr_nrctremp := 128653;
    v_dados(v_dados.last()).vr_vllanmto := 1.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129574;
    v_dados(v_dados.last()).vr_vllanmto := 3.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 43.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 129804;
    v_dados(v_dados.last()).vr_vllanmto := 6.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90000;
    v_dados(v_dados.last()).vr_nrctremp := 129809;
    v_dados(v_dados.last()).vr_vllanmto := .86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129899;
    v_dados(v_dados.last()).vr_vllanmto := 5.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 515566;
    v_dados(v_dados.last()).vr_nrctremp := 131305;
    v_dados(v_dados.last()).vr_vllanmto := 2.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131375;
    v_dados(v_dados.last()).vr_vllanmto := 1.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132847;
    v_dados(v_dados.last()).vr_vllanmto := 39.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 132885;
    v_dados(v_dados.last()).vr_vllanmto := 8.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 13.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133795;
    v_dados(v_dados.last()).vr_vllanmto := 12.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325791;
    v_dados(v_dados.last()).vr_nrctremp := 134294;
    v_dados(v_dados.last()).vr_vllanmto := .42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 134311;
    v_dados(v_dados.last()).vr_vllanmto := 6.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151181;
    v_dados(v_dados.last()).vr_nrctremp := 134521;
    v_dados(v_dados.last()).vr_vllanmto := 1.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135085;
    v_dados(v_dados.last()).vr_vllanmto := 3.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450294;
    v_dados(v_dados.last()).vr_nrctremp := 135394;
    v_dados(v_dados.last()).vr_vllanmto := .36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135769;
    v_dados(v_dados.last()).vr_vllanmto := 11.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 66.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184586;
    v_dados(v_dados.last()).vr_nrctremp := 136806;
    v_dados(v_dados.last()).vr_vllanmto := 3.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71757;
    v_dados(v_dados.last()).vr_nrctremp := 136891;
    v_dados(v_dados.last()).vr_vllanmto := 12.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 35.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 2.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120219;
    v_dados(v_dados.last()).vr_nrctremp := 137617;
    v_dados(v_dados.last()).vr_vllanmto := 37.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185272;
    v_dados(v_dados.last()).vr_nrctremp := 139153;
    v_dados(v_dados.last()).vr_vllanmto := 9.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 12.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92487;
    v_dados(v_dados.last()).vr_nrctremp := 140770;
    v_dados(v_dados.last()).vr_vllanmto := 2.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141207;
    v_dados(v_dados.last()).vr_vllanmto := 20.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124311;
    v_dados(v_dados.last()).vr_nrctremp := 142173;
    v_dados(v_dados.last()).vr_vllanmto := 10.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328790;
    v_dados(v_dados.last()).vr_nrctremp := 142203;
    v_dados(v_dados.last()).vr_vllanmto := 1.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 142392;
    v_dados(v_dados.last()).vr_vllanmto := 3.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143897;
    v_dados(v_dados.last()).vr_vllanmto := 17.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143898;
    v_dados(v_dados.last()).vr_vllanmto := 3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462020;
    v_dados(v_dados.last()).vr_nrctremp := 144951;
    v_dados(v_dados.last()).vr_vllanmto := 2.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 145982;
    v_dados(v_dados.last()).vr_vllanmto := 21.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146397;
    v_dados(v_dados.last()).vr_vllanmto := 2.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 13.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240389;
    v_dados(v_dados.last()).vr_nrctremp := 147131;
    v_dados(v_dados.last()).vr_vllanmto := 2.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322890;
    v_dados(v_dados.last()).vr_nrctremp := 147538;
    v_dados(v_dados.last()).vr_vllanmto := 10.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148221;
    v_dados(v_dados.last()).vr_vllanmto := 36.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641790;
    v_dados(v_dados.last()).vr_nrctremp := 148852;
    v_dados(v_dados.last()).vr_vllanmto := 10.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149204;
    v_dados(v_dados.last()).vr_vllanmto := 21.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149205;
    v_dados(v_dados.last()).vr_vllanmto := 5.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 517399;
    v_dados(v_dados.last()).vr_nrctremp := 149458;
    v_dados(v_dados.last()).vr_vllanmto := 2.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 149556;
    v_dados(v_dados.last()).vr_vllanmto := .38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 150316;
    v_dados(v_dados.last()).vr_vllanmto := 3.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 151150;
    v_dados(v_dados.last()).vr_vllanmto := 6.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 649899;
    v_dados(v_dados.last()).vr_nrctremp := 153142;
    v_dados(v_dados.last()).vr_vllanmto := 11.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109428;
    v_dados(v_dados.last()).vr_nrctremp := 154257;
    v_dados(v_dados.last()).vr_vllanmto := 8.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155420;
    v_dados(v_dados.last()).vr_vllanmto := 3.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298980;
    v_dados(v_dados.last()).vr_nrctremp := 155781;
    v_dados(v_dados.last()).vr_vllanmto := 2.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155955;
    v_dados(v_dados.last()).vr_vllanmto := 7.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 630080;
    v_dados(v_dados.last()).vr_nrctremp := 157110;
    v_dados(v_dados.last()).vr_vllanmto := 5.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284874;
    v_dados(v_dados.last()).vr_nrctremp := 157311;
    v_dados(v_dados.last()).vr_vllanmto := 24.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190047;
    v_dados(v_dados.last()).vr_nrctremp := 158762;
    v_dados(v_dados.last()).vr_vllanmto := 2.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78140;
    v_dados(v_dados.last()).vr_nrctremp := 159388;
    v_dados(v_dados.last()).vr_vllanmto := 14.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 159595;
    v_dados(v_dados.last()).vr_vllanmto := 2.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321907;
    v_dados(v_dados.last()).vr_nrctremp := 162583;
    v_dados(v_dados.last()).vr_vllanmto := 3.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145742;
    v_dados(v_dados.last()).vr_nrctremp := 162708;
    v_dados(v_dados.last()).vr_vllanmto := 1.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435007;
    v_dados(v_dados.last()).vr_nrctremp := 162711;
    v_dados(v_dados.last()).vr_vllanmto := 6.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382833;
    v_dados(v_dados.last()).vr_nrctremp := 163160;
    v_dados(v_dados.last()).vr_vllanmto := 6.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 164001;
    v_dados(v_dados.last()).vr_vllanmto := 3.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464910;
    v_dados(v_dados.last()).vr_nrctremp := 164242;
    v_dados(v_dados.last()).vr_vllanmto := 5.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191434;
    v_dados(v_dados.last()).vr_nrctremp := 164271;
    v_dados(v_dados.last()).vr_vllanmto := 1.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 164345;
    v_dados(v_dados.last()).vr_vllanmto := 4.12;
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
