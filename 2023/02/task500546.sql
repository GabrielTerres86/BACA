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
	v_dados(v_dados.last()).vr_nrdconta := 80093159;
	v_dados(v_dados.last()).vr_nrctremp := 1886421;
	v_dados(v_dados.last()).vr_vllanmto := 470.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80431135;
	v_dados(v_dados.last()).vr_nrctremp := 1901589;
	v_dados(v_dados.last()).vr_vllanmto := 2.72;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80147194;
	v_dados(v_dados.last()).vr_nrctremp := 2040841;
	v_dados(v_dados.last()).vr_vllanmto := 58.43;
	v_dados(v_dados.last()).vr_cdhistor := 1040;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80060242;
	v_dados(v_dados.last()).vr_nrctremp := 2214162;
	v_dados(v_dados.last()).vr_vllanmto := 410.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8713529;
	v_dados(v_dados.last()).vr_nrctremp := 2661058;
	v_dados(v_dados.last()).vr_vllanmto := 146.64;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9355146;
	v_dados(v_dados.last()).vr_nrctremp := 2728862;
	v_dados(v_dados.last()).vr_vllanmto := 238.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11586915;
	v_dados(v_dados.last()).vr_nrctremp := 2909668;
	v_dados(v_dados.last()).vr_vllanmto := 262.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7434928;
	v_dados(v_dados.last()).vr_nrctremp := 2955176;
	v_dados(v_dados.last()).vr_vllanmto := 176.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10403655;
	v_dados(v_dados.last()).vr_nrctremp := 2955266;
	v_dados(v_dados.last()).vr_vllanmto := 221.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80101062;
	v_dados(v_dados.last()).vr_nrctremp := 2955278;
	v_dados(v_dados.last()).vr_vllanmto := 394.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10605843;
	v_dados(v_dados.last()).vr_nrctremp := 2955350;
	v_dados(v_dados.last()).vr_vllanmto := 225.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80337074;
	v_dados(v_dados.last()).vr_nrctremp := 2955519;
	v_dados(v_dados.last()).vr_vllanmto := 60.45;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8837813;
	v_dados(v_dados.last()).vr_nrctremp := 2955566;
	v_dados(v_dados.last()).vr_vllanmto := 596.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9659293;
	v_dados(v_dados.last()).vr_nrctremp := 2955761;
	v_dados(v_dados.last()).vr_vllanmto := 185.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6334423;
	v_dados(v_dados.last()).vr_nrctremp := 2955764;
	v_dados(v_dados.last()).vr_vllanmto := 105.83;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10279890;
	v_dados(v_dados.last()).vr_nrctremp := 2955808;
	v_dados(v_dados.last()).vr_vllanmto := 2359.45;
	v_dados(v_dados.last()).vr_cdhistor := 1040;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7521537;
	v_dados(v_dados.last()).vr_nrctremp := 2955842;
	v_dados(v_dados.last()).vr_vllanmto := 264.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9783792;
	v_dados(v_dados.last()).vr_nrctremp := 2955856;
	v_dados(v_dados.last()).vr_vllanmto := 162.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11779608;
	v_dados(v_dados.last()).vr_nrctremp := 2979926;
	v_dados(v_dados.last()).vr_vllanmto := 199.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11766522;
	v_dados(v_dados.last()).vr_nrctremp := 2988271;
	v_dados(v_dados.last()).vr_vllanmto := 582.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6935915;
	v_dados(v_dados.last()).vr_nrctremp := 2991942;
	v_dados(v_dados.last()).vr_vllanmto := 1267.46;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11776340;
	v_dados(v_dados.last()).vr_nrctremp := 3032948;
	v_dados(v_dados.last()).vr_vllanmto := 38.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80277829;
	v_dados(v_dados.last()).vr_nrctremp := 3087767;
	v_dados(v_dados.last()).vr_vllanmto := 207.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10657673;
	v_dados(v_dados.last()).vr_nrctremp := 3167828;
	v_dados(v_dados.last()).vr_vllanmto := 59.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7894694;
	v_dados(v_dados.last()).vr_nrctremp := 3222606;
	v_dados(v_dados.last()).vr_vllanmto := 37.96;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9868925;
	v_dados(v_dados.last()).vr_nrctremp := 3230862;
	v_dados(v_dados.last()).vr_vllanmto := 100.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12026786;
	v_dados(v_dados.last()).vr_nrctremp := 3231886;
	v_dados(v_dados.last()).vr_vllanmto := 264.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11691700;
	v_dados(v_dados.last()).vr_nrctremp := 3235912;
	v_dados(v_dados.last()).vr_vllanmto := 244.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8289077;
	v_dados(v_dados.last()).vr_nrctremp := 3293193;
	v_dados(v_dados.last()).vr_vllanmto := 293.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12019178;
	v_dados(v_dados.last()).vr_nrctremp := 3430704;
	v_dados(v_dados.last()).vr_vllanmto := 190.36;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12019178;
	v_dados(v_dados.last()).vr_nrctremp := 3449703;
	v_dados(v_dados.last()).vr_vllanmto := 108.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12311170;
	v_dados(v_dados.last()).vr_nrctremp := 3502234;
	v_dados(v_dados.last()).vr_vllanmto := 108.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11889195;
	v_dados(v_dados.last()).vr_nrctremp := 3521680;
	v_dados(v_dados.last()).vr_vllanmto := 216.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80101089;
	v_dados(v_dados.last()).vr_nrctremp := 3549323;
	v_dados(v_dados.last()).vr_vllanmto := 212.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12360082;
	v_dados(v_dados.last()).vr_nrctremp := 3555694;
	v_dados(v_dados.last()).vr_vllanmto := 151.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12389080;
	v_dados(v_dados.last()).vr_nrctremp := 3584084;
	v_dados(v_dados.last()).vr_vllanmto := 123.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11747820;
	v_dados(v_dados.last()).vr_nrctremp := 3604371;
	v_dados(v_dados.last()).vr_vllanmto := 179.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12422320;
	v_dados(v_dados.last()).vr_nrctremp := 3615395;
	v_dados(v_dados.last()).vr_vllanmto := 117.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12420085;
	v_dados(v_dados.last()).vr_nrctremp := 3621331;
	v_dados(v_dados.last()).vr_vllanmto := 115.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11093293;
	v_dados(v_dados.last()).vr_nrctremp := 3646338;
	v_dados(v_dados.last()).vr_vllanmto := 135.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12475408;
	v_dados(v_dados.last()).vr_nrctremp := 3680350;
	v_dados(v_dados.last()).vr_vllanmto := 140;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12111422;
	v_dados(v_dados.last()).vr_nrctremp := 3684282;
	v_dados(v_dados.last()).vr_vllanmto := 137.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12488968;
	v_dados(v_dados.last()).vr_nrctremp := 3695197;
	v_dados(v_dados.last()).vr_vllanmto := 91.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12488968;
	v_dados(v_dados.last()).vr_nrctremp := 3695226;
	v_dados(v_dados.last()).vr_vllanmto := 106.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10735224;
	v_dados(v_dados.last()).vr_nrctremp := 3701725;
	v_dados(v_dados.last()).vr_vllanmto := 81.14;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12274135;
	v_dados(v_dados.last()).vr_nrctremp := 3706648;
	v_dados(v_dados.last()).vr_vllanmto := 210.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12519421;
	v_dados(v_dados.last()).vr_nrctremp := 3726006;
	v_dados(v_dados.last()).vr_vllanmto := 142.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12362778;
	v_dados(v_dados.last()).vr_nrctremp := 3742862;
	v_dados(v_dados.last()).vr_vllanmto := 400.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12548650;
	v_dados(v_dados.last()).vr_nrctremp := 3753649;
	v_dados(v_dados.last()).vr_vllanmto := 246.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12541265;
	v_dados(v_dados.last()).vr_nrctremp := 3760813;
	v_dados(v_dados.last()).vr_vllanmto := 178.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12557889;
	v_dados(v_dados.last()).vr_nrctremp := 3762595;
	v_dados(v_dados.last()).vr_vllanmto := 204.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12568457;
	v_dados(v_dados.last()).vr_nrctremp := 3774764;
	v_dados(v_dados.last()).vr_vllanmto := 233.46;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12584541;
	v_dados(v_dados.last()).vr_nrctremp := 3808261;
	v_dados(v_dados.last()).vr_vllanmto := 88.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12560448;
	v_dados(v_dados.last()).vr_nrctremp := 3815662;
	v_dados(v_dados.last()).vr_vllanmto := 93.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8177589;
	v_dados(v_dados.last()).vr_nrctremp := 3837514;
	v_dados(v_dados.last()).vr_vllanmto := 83.31;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3820408;
	v_dados(v_dados.last()).vr_nrctremp := 3838282;
	v_dados(v_dados.last()).vr_vllanmto := 175.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10140425;
	v_dados(v_dados.last()).vr_nrctremp := 3852530;
	v_dados(v_dados.last()).vr_vllanmto := 271.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6880924;
	v_dados(v_dados.last()).vr_nrctremp := 3859002;
	v_dados(v_dados.last()).vr_vllanmto := 53.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7797320;
	v_dados(v_dados.last()).vr_nrctremp := 3869609;
	v_dados(v_dados.last()).vr_vllanmto := 202;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2183315;
	v_dados(v_dados.last()).vr_nrctremp := 3907302;
	v_dados(v_dados.last()).vr_vllanmto := 187.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11251891;
	v_dados(v_dados.last()).vr_nrctremp := 3919578;
	v_dados(v_dados.last()).vr_vllanmto := 439.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12293407;
	v_dados(v_dados.last()).vr_nrctremp := 3938066;
	v_dados(v_dados.last()).vr_vllanmto := 256.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12700860;
	v_dados(v_dados.last()).vr_nrctremp := 3939478;
	v_dados(v_dados.last()).vr_vllanmto := 94.76;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12752827;
	v_dados(v_dados.last()).vr_nrctremp := 3960181;
	v_dados(v_dados.last()).vr_vllanmto := 28.97;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3628280;
	v_dados(v_dados.last()).vr_nrctremp := 3965338;
	v_dados(v_dados.last()).vr_vllanmto := 70.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12760102;
	v_dados(v_dados.last()).vr_nrctremp := 3965764;
	v_dados(v_dados.last()).vr_vllanmto := 111.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2515938;
	v_dados(v_dados.last()).vr_nrctremp := 3969605;
	v_dados(v_dados.last()).vr_vllanmto := 346.74;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12582565;
	v_dados(v_dados.last()).vr_nrctremp := 3986201;
	v_dados(v_dados.last()).vr_vllanmto := 276.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3004031;
	v_dados(v_dados.last()).vr_nrctremp := 3990299;
	v_dados(v_dados.last()).vr_vllanmto := 33.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8058717;
	v_dados(v_dados.last()).vr_nrctremp := 3990688;
	v_dados(v_dados.last()).vr_vllanmto := 278.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12720828;
	v_dados(v_dados.last()).vr_nrctremp := 3995814;
	v_dados(v_dados.last()).vr_vllanmto := 75.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12716200;
	v_dados(v_dados.last()).vr_nrctremp := 3996934;
	v_dados(v_dados.last()).vr_vllanmto := 121.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12762067;
	v_dados(v_dados.last()).vr_nrctremp := 4020012;
	v_dados(v_dados.last()).vr_vllanmto := 126.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12744786;
	v_dados(v_dados.last()).vr_nrctremp := 4024341;
	v_dados(v_dados.last()).vr_vllanmto := 98.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10206345;
	v_dados(v_dados.last()).vr_nrctremp := 4035306;
	v_dados(v_dados.last()).vr_vllanmto := 118.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12737640;
	v_dados(v_dados.last()).vr_nrctremp := 4038250;
	v_dados(v_dados.last()).vr_vllanmto := 367.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12752916;
	v_dados(v_dados.last()).vr_nrctremp := 4073735;
	v_dados(v_dados.last()).vr_vllanmto := 178.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12873853;
	v_dados(v_dados.last()).vr_nrctremp := 4082058;
	v_dados(v_dados.last()).vr_vllanmto := 281.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12785369;
	v_dados(v_dados.last()).vr_nrctremp := 4083531;
	v_dados(v_dados.last()).vr_vllanmto := 168.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12873632;
	v_dados(v_dados.last()).vr_nrctremp := 4085979;
	v_dados(v_dados.last()).vr_vllanmto := 284.92;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12891185;
	v_dados(v_dados.last()).vr_nrctremp := 4090475;
	v_dados(v_dados.last()).vr_vllanmto := 208.58;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2125579;
	v_dados(v_dados.last()).vr_nrctremp := 4097261;
	v_dados(v_dados.last()).vr_vllanmto := 112.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12813826;
	v_dados(v_dados.last()).vr_nrctremp := 4097768;
	v_dados(v_dados.last()).vr_vllanmto := 75.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12739090;
	v_dados(v_dados.last()).vr_nrctremp := 4102671;
	v_dados(v_dados.last()).vr_vllanmto := 367.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6319572;
	v_dados(v_dados.last()).vr_nrctremp := 4108542;
	v_dados(v_dados.last()).vr_vllanmto := 42.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12949353;
	v_dados(v_dados.last()).vr_nrctremp := 4148318;
	v_dados(v_dados.last()).vr_vllanmto := 86.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6613314;
	v_dados(v_dados.last()).vr_nrctremp := 4152976;
	v_dados(v_dados.last()).vr_vllanmto := 15.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12979236;
	v_dados(v_dados.last()).vr_nrctremp := 4161519;
	v_dados(v_dados.last()).vr_vllanmto := 40.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10605843;
	v_dados(v_dados.last()).vr_nrctremp := 4164558;
	v_dados(v_dados.last()).vr_vllanmto := 139.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10571760;
	v_dados(v_dados.last()).vr_nrctremp := 4167462;
	v_dados(v_dados.last()).vr_vllanmto := 231.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7374763;
	v_dados(v_dados.last()).vr_nrctremp := 4178604;
	v_dados(v_dados.last()).vr_vllanmto := 126.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6365639;
	v_dados(v_dados.last()).vr_nrctremp := 4185048;
	v_dados(v_dados.last()).vr_vllanmto := 164.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12632643;
	v_dados(v_dados.last()).vr_nrctremp := 4194374;
	v_dados(v_dados.last()).vr_vllanmto := 38.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12756466;
	v_dados(v_dados.last()).vr_nrctremp := 4210230;
	v_dados(v_dados.last()).vr_vllanmto := 148.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12113743;
	v_dados(v_dados.last()).vr_nrctremp := 4221205;
	v_dados(v_dados.last()).vr_vllanmto := 179.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12504998;
	v_dados(v_dados.last()).vr_nrctremp := 4229059;
	v_dados(v_dados.last()).vr_vllanmto := 325.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13063928;
	v_dados(v_dados.last()).vr_nrctremp := 4229100;
	v_dados(v_dados.last()).vr_vllanmto := 24.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12412902;
	v_dados(v_dados.last()).vr_nrctremp := 4244848;
	v_dados(v_dados.last()).vr_vllanmto := 104.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12146870;
	v_dados(v_dados.last()).vr_nrctremp := 4251082;
	v_dados(v_dados.last()).vr_vllanmto := 40.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13065661;
	v_dados(v_dados.last()).vr_nrctremp := 4267714;
	v_dados(v_dados.last()).vr_vllanmto := 99.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13133039;
	v_dados(v_dados.last()).vr_nrctremp := 4273075;
	v_dados(v_dados.last()).vr_vllanmto := 123.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11875283;
	v_dados(v_dados.last()).vr_nrctremp := 4276059;
	v_dados(v_dados.last()).vr_vllanmto := 23.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8078793;
	v_dados(v_dados.last()).vr_nrctremp := 4301243;
	v_dados(v_dados.last()).vr_vllanmto := 36.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 1705660;
	v_dados(v_dados.last()).vr_nrctremp := 4310541;
	v_dados(v_dados.last()).vr_vllanmto := 206.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10645292;
	v_dados(v_dados.last()).vr_nrctremp := 4312871;
	v_dados(v_dados.last()).vr_vllanmto := 90.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13184270;
	v_dados(v_dados.last()).vr_nrctremp := 4313478;
	v_dados(v_dados.last()).vr_vllanmto := 492.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11044039;
	v_dados(v_dados.last()).vr_nrctremp := 4344288;
	v_dados(v_dados.last()).vr_vllanmto := 250.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12998052;
	v_dados(v_dados.last()).vr_nrctremp := 4346665;
	v_dados(v_dados.last()).vr_vllanmto := 98.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13174894;
	v_dados(v_dados.last()).vr_nrctremp := 4364977;
	v_dados(v_dados.last()).vr_vllanmto := 28.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13246003;
	v_dados(v_dados.last()).vr_nrctremp := 4375937;
	v_dados(v_dados.last()).vr_vllanmto := 351.34;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12544515;
	v_dados(v_dados.last()).vr_nrctremp := 4376574;
	v_dados(v_dados.last()).vr_vllanmto := 53.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11717017;
	v_dados(v_dados.last()).vr_nrctremp := 4394694;
	v_dados(v_dados.last()).vr_vllanmto := 17.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13177630;
	v_dados(v_dados.last()).vr_nrctremp := 4428083;
	v_dados(v_dados.last()).vr_vllanmto := 97.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8456445;
	v_dados(v_dados.last()).vr_nrctremp := 4438913;
	v_dados(v_dados.last()).vr_vllanmto := 39.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13147110;
	v_dados(v_dados.last()).vr_nrctremp := 4439926;
	v_dados(v_dados.last()).vr_vllanmto := 48.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12089613;
	v_dados(v_dados.last()).vr_nrctremp := 4445918;
	v_dados(v_dados.last()).vr_vllanmto := 334.36;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12020192;
	v_dados(v_dados.last()).vr_nrctremp := 4452101;
	v_dados(v_dados.last()).vr_vllanmto := 114.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10637753;
	v_dados(v_dados.last()).vr_nrctremp := 4453483;
	v_dados(v_dados.last()).vr_vllanmto := 25.57;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13344048;
	v_dados(v_dados.last()).vr_nrctremp := 4462768;
	v_dados(v_dados.last()).vr_vllanmto := 222.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12823350;
	v_dados(v_dados.last()).vr_nrctremp := 4463112;
	v_dados(v_dados.last()).vr_vllanmto := 51.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12737640;
	v_dados(v_dados.last()).vr_nrctremp := 4471080;
	v_dados(v_dados.last()).vr_vllanmto := 32.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13413341;
	v_dados(v_dados.last()).vr_nrctremp := 4488146;
	v_dados(v_dados.last()).vr_vllanmto := 39.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12744786;
	v_dados(v_dados.last()).vr_nrctremp := 4488682;
	v_dados(v_dados.last()).vr_vllanmto := 25.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12300349;
	v_dados(v_dados.last()).vr_nrctremp := 4494631;
	v_dados(v_dados.last()).vr_vllanmto := 33.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13432109;
	v_dados(v_dados.last()).vr_nrctremp := 4500315;
	v_dados(v_dados.last()).vr_vllanmto := 24.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10092366;
	v_dados(v_dados.last()).vr_nrctremp := 4521572;
	v_dados(v_dados.last()).vr_vllanmto := 143.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12595080;
	v_dados(v_dados.last()).vr_nrctremp := 4522660;
	v_dados(v_dados.last()).vr_vllanmto := 19.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9638997;
	v_dados(v_dados.last()).vr_nrctremp := 4527665;
	v_dados(v_dados.last()).vr_vllanmto := 365.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10065903;
	v_dados(v_dados.last()).vr_nrctremp := 4529120;
	v_dados(v_dados.last()).vr_vllanmto := 111.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12413887;
	v_dados(v_dados.last()).vr_nrctremp := 4535597;
	v_dados(v_dados.last()).vr_vllanmto := 71.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11875283;
	v_dados(v_dados.last()).vr_nrctremp := 4559125;
	v_dados(v_dados.last()).vr_vllanmto := 35.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9433171;
	v_dados(v_dados.last()).vr_nrctremp := 4559377;
	v_dados(v_dados.last()).vr_vllanmto := 186.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13523252;
	v_dados(v_dados.last()).vr_nrctremp := 4564654;
	v_dados(v_dados.last()).vr_vllanmto := 131.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2741741;
	v_dados(v_dados.last()).vr_nrctremp := 4570333;
	v_dados(v_dados.last()).vr_vllanmto := 227.36;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13545418;
	v_dados(v_dados.last()).vr_nrctremp := 4576196;
	v_dados(v_dados.last()).vr_vllanmto := 42.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8753822;
	v_dados(v_dados.last()).vr_nrctremp := 4577604;
	v_dados(v_dados.last()).vr_vllanmto := 101.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3013529;
	v_dados(v_dados.last()).vr_nrctremp := 4615616;
	v_dados(v_dados.last()).vr_vllanmto := 613.5;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10752188;
	v_dados(v_dados.last()).vr_nrctremp := 4616770;
	v_dados(v_dados.last()).vr_vllanmto := 118.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11820004;
	v_dados(v_dados.last()).vr_nrctremp := 4617074;
	v_dados(v_dados.last()).vr_vllanmto := 55.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12897400;
	v_dados(v_dados.last()).vr_nrctremp := 4617687;
	v_dados(v_dados.last()).vr_vllanmto := 46.64;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8683352;
	v_dados(v_dados.last()).vr_nrctremp := 4624468;
	v_dados(v_dados.last()).vr_vllanmto := 209.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6635369;
	v_dados(v_dados.last()).vr_nrctremp := 4627413;
	v_dados(v_dados.last()).vr_vllanmto := 55.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10204547;
	v_dados(v_dados.last()).vr_nrctremp := 4635900;
	v_dados(v_dados.last()).vr_vllanmto := 80.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6155677;
	v_dados(v_dados.last()).vr_nrctremp := 4638991;
	v_dados(v_dados.last()).vr_vllanmto := 106.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13389408;
	v_dados(v_dados.last()).vr_nrctremp := 4639193;
	v_dados(v_dados.last()).vr_vllanmto := 188.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8171645;
	v_dados(v_dados.last()).vr_nrctremp := 4644755;
	v_dados(v_dados.last()).vr_vllanmto := 3.86;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13481622;
	v_dados(v_dados.last()).vr_nrctremp := 4650705;
	v_dados(v_dados.last()).vr_vllanmto := 131.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10735224;
	v_dados(v_dados.last()).vr_nrctremp := 4660748;
	v_dados(v_dados.last()).vr_vllanmto := 16.34;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8861056;
	v_dados(v_dados.last()).vr_nrctremp := 4660846;
	v_dados(v_dados.last()).vr_vllanmto := 164.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13298216;
	v_dados(v_dados.last()).vr_nrctremp := 4662710;
	v_dados(v_dados.last()).vr_vllanmto := 118.3;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13440241;
	v_dados(v_dados.last()).vr_nrctremp := 4672702;
	v_dados(v_dados.last()).vr_vllanmto := 135.32;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13689533;
	v_dados(v_dados.last()).vr_nrctremp := 4685615;
	v_dados(v_dados.last()).vr_vllanmto := 76.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8496293;
	v_dados(v_dados.last()).vr_nrctremp := 4694140;
	v_dados(v_dados.last()).vr_vllanmto := 433.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8928029;
	v_dados(v_dados.last()).vr_nrctremp := 4702686;
	v_dados(v_dados.last()).vr_vllanmto := 58.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80434720;
	v_dados(v_dados.last()).vr_nrctremp := 4705785;
	v_dados(v_dados.last()).vr_vllanmto := 550.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9676902;
	v_dados(v_dados.last()).vr_nrctremp := 4729697;
	v_dados(v_dados.last()).vr_vllanmto := 62.36;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 4077008;
	v_dados(v_dados.last()).vr_nrctremp := 4746811;
	v_dados(v_dados.last()).vr_vllanmto := 85.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7204612;
	v_dados(v_dados.last()).vr_nrctremp := 4750120;
	v_dados(v_dados.last()).vr_vllanmto := 110.3;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11717017;
	v_dados(v_dados.last()).vr_nrctremp := 4751830;
	v_dados(v_dados.last()).vr_vllanmto := 27.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6389643;
	v_dados(v_dados.last()).vr_nrctremp := 4754021;
	v_dados(v_dados.last()).vr_vllanmto := 45.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12288195;
	v_dados(v_dados.last()).vr_nrctremp := 4761996;
	v_dados(v_dados.last()).vr_vllanmto := 67.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10278630;
	v_dados(v_dados.last()).vr_nrctremp := 4778376;
	v_dados(v_dados.last()).vr_vllanmto := 76.98;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11887176;
	v_dados(v_dados.last()).vr_nrctremp := 4778799;
	v_dados(v_dados.last()).vr_vllanmto := 38.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12637106;
	v_dados(v_dados.last()).vr_nrctremp := 4782826;
	v_dados(v_dados.last()).vr_vllanmto := 27.5;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10640622;
	v_dados(v_dados.last()).vr_nrctremp := 4784340;
	v_dados(v_dados.last()).vr_vllanmto := 133.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8060266;
	v_dados(v_dados.last()).vr_nrctremp := 4800878;
	v_dados(v_dados.last()).vr_vllanmto := 179.74;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80069665;
	v_dados(v_dados.last()).vr_nrctremp := 4829674;
	v_dados(v_dados.last()).vr_vllanmto := 316.92;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10636048;
	v_dados(v_dados.last()).vr_nrctremp := 4839172;
	v_dados(v_dados.last()).vr_vllanmto := 35.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13197967;
	v_dados(v_dados.last()).vr_nrctremp := 4846390;
	v_dados(v_dados.last()).vr_vllanmto := 30.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8737665;
	v_dados(v_dados.last()).vr_nrctremp := 4850258;
	v_dados(v_dados.last()).vr_vllanmto := 59.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13666053;
	v_dados(v_dados.last()).vr_nrctremp := 4852622;
	v_dados(v_dados.last()).vr_vllanmto := 22.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3761240;
	v_dados(v_dados.last()).vr_nrctremp := 4898751;
	v_dados(v_dados.last()).vr_vllanmto := 238.6;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11009993;
	v_dados(v_dados.last()).vr_nrctremp := 4901511;
	v_dados(v_dados.last()).vr_vllanmto := 91.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11751169;
	v_dados(v_dados.last()).vr_nrctremp := 4904813;
	v_dados(v_dados.last()).vr_vllanmto := 23.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7448619;
	v_dados(v_dados.last()).vr_nrctremp := 4914399;
	v_dados(v_dados.last()).vr_vllanmto := 47.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 773565;
	v_dados(v_dados.last()).vr_nrctremp := 4922540;
	v_dados(v_dados.last()).vr_vllanmto := 83.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11629410;
	v_dados(v_dados.last()).vr_nrctremp := 4924495;
	v_dados(v_dados.last()).vr_vllanmto := 75.32;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2984628;
	v_dados(v_dados.last()).vr_nrctremp := 4935932;
	v_dados(v_dados.last()).vr_vllanmto := 42.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12651443;
	v_dados(v_dados.last()).vr_nrctremp := 4950509;
	v_dados(v_dados.last()).vr_vllanmto := 44.05;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80140939;
	v_dados(v_dados.last()).vr_nrctremp := 5042593;
	v_dados(v_dados.last()).vr_vllanmto := 64.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14134489;
	v_dados(v_dados.last()).vr_nrctremp := 5076253;
	v_dados(v_dados.last()).vr_vllanmto := 57.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8034656;
	v_dados(v_dados.last()).vr_nrctremp := 5097439;
	v_dados(v_dados.last()).vr_vllanmto := 29.13;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13639080;
	v_dados(v_dados.last()).vr_nrctremp := 5104902;
	v_dados(v_dados.last()).vr_vllanmto := 72.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10782524;
	v_dados(v_dados.last()).vr_nrctremp := 5126283;
	v_dados(v_dados.last()).vr_vllanmto := 371.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12141534;
	v_dados(v_dados.last()).vr_nrctremp := 5130609;
	v_dados(v_dados.last()).vr_vllanmto := 58.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9697128;
	v_dados(v_dados.last()).vr_nrctremp := 5139065;
	v_dados(v_dados.last()).vr_vllanmto := 70.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 1927337;
	v_dados(v_dados.last()).vr_nrctremp := 5139328;
	v_dados(v_dados.last()).vr_vllanmto := 230.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7310595;
	v_dados(v_dados.last()).vr_nrctremp := 5146936;
	v_dados(v_dados.last()).vr_vllanmto := 228.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10066020;
	v_dados(v_dados.last()).vr_nrctremp := 5157236;
	v_dados(v_dados.last()).vr_vllanmto := 76.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14134489;
	v_dados(v_dados.last()).vr_nrctremp := 5157927;
	v_dados(v_dados.last()).vr_vllanmto := 33.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12518581;
	v_dados(v_dados.last()).vr_nrctremp := 5165015;
	v_dados(v_dados.last()).vr_vllanmto := 143.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7364695;
	v_dados(v_dados.last()).vr_nrctremp := 5172208;
	v_dados(v_dados.last()).vr_vllanmto := 304.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14310562;
	v_dados(v_dados.last()).vr_nrctremp := 5199705;
	v_dados(v_dados.last()).vr_vllanmto := 55.5;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8401411;
	v_dados(v_dados.last()).vr_nrctremp := 5235619;
	v_dados(v_dados.last()).vr_vllanmto := 192.57;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11357096;
	v_dados(v_dados.last()).vr_nrctremp := 5247177;
	v_dados(v_dados.last()).vr_vllanmto := 113.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8498750;
	v_dados(v_dados.last()).vr_nrctremp := 5285090;
	v_dados(v_dados.last()).vr_vllanmto := 314.09;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10099468;
	v_dados(v_dados.last()).vr_nrctremp := 5308286;
	v_dados(v_dados.last()).vr_vllanmto := 78.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80141501;
	v_dados(v_dados.last()).vr_nrctremp := 5314168;
	v_dados(v_dados.last()).vr_vllanmto := 134.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12182249;
	v_dados(v_dados.last()).vr_nrctremp := 5319781;
	v_dados(v_dados.last()).vr_vllanmto := 64.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3183076;
	v_dados(v_dados.last()).vr_nrctremp := 5369358;
	v_dados(v_dados.last()).vr_vllanmto := 154.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8727880;
	v_dados(v_dados.last()).vr_nrctremp := 5373802;
	v_dados(v_dados.last()).vr_vllanmto := 64.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8737940;
	v_dados(v_dados.last()).vr_nrctremp := 5375592;
	v_dados(v_dados.last()).vr_vllanmto := 55.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14549700;
	v_dados(v_dados.last()).vr_nrctremp := 5390465;
	v_dados(v_dados.last()).vr_vllanmto := 63.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11286024;
	v_dados(v_dados.last()).vr_nrctremp := 5397806;
	v_dados(v_dados.last()).vr_vllanmto := 112.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6337015;
	v_dados(v_dados.last()).vr_nrctremp := 5414143;
	v_dados(v_dados.last()).vr_vllanmto := 55.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7986726;
	v_dados(v_dados.last()).vr_nrctremp := 5427406;
	v_dados(v_dados.last()).vr_vllanmto := 16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12170194;
	v_dados(v_dados.last()).vr_nrctremp := 5448447;
	v_dados(v_dados.last()).vr_vllanmto := 111.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13525760;
	v_dados(v_dados.last()).vr_nrctremp := 5457508;
	v_dados(v_dados.last()).vr_vllanmto := 23.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80091288;
	v_dados(v_dados.last()).vr_nrctremp := 5458102;
	v_dados(v_dados.last()).vr_vllanmto := 92.58;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11734647;
	v_dados(v_dados.last()).vr_nrctremp := 5462321;
	v_dados(v_dados.last()).vr_vllanmto := 56.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9700242;
	v_dados(v_dados.last()).vr_nrctremp := 5500652;
	v_dados(v_dados.last()).vr_vllanmto := 52.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11766522;
	v_dados(v_dados.last()).vr_nrctremp := 5500927;
	v_dados(v_dados.last()).vr_vllanmto := 74.64;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11725753;
	v_dados(v_dados.last()).vr_nrctremp := 5503501;
	v_dados(v_dados.last()).vr_vllanmto := 165.64;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13575325;
	v_dados(v_dados.last()).vr_nrctremp := 5509560;
	v_dados(v_dados.last()).vr_vllanmto := 18.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14702932;
	v_dados(v_dados.last()).vr_nrctremp := 5510678;
	v_dados(v_dados.last()).vr_vllanmto := 101.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13581155;
	v_dados(v_dados.last()).vr_nrctremp := 5533233;
	v_dados(v_dados.last()).vr_vllanmto := 43.66;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12212202;
	v_dados(v_dados.last()).vr_nrctremp := 5533981;
	v_dados(v_dados.last()).vr_vllanmto := 48.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8928797;
	v_dados(v_dados.last()).vr_nrctremp := 5537237;
	v_dados(v_dados.last()).vr_vllanmto := 116.87;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12183890;
	v_dados(v_dados.last()).vr_nrctremp := 5541276;
	v_dados(v_dados.last()).vr_vllanmto := 48.76;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10400354;
	v_dados(v_dados.last()).vr_nrctremp := 5541382;
	v_dados(v_dados.last()).vr_vllanmto := 167.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12739090;
	v_dados(v_dados.last()).vr_nrctremp := 5545715;
	v_dados(v_dados.last()).vr_vllanmto := 67.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10031146;
	v_dados(v_dados.last()).vr_nrctremp := 5552972;
	v_dados(v_dados.last()).vr_vllanmto := 159.69;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10950842;
	v_dados(v_dados.last()).vr_nrctremp := 5554395;
	v_dados(v_dados.last()).vr_vllanmto := 89.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8479631;
	v_dados(v_dados.last()).vr_nrctremp := 5565614;
	v_dados(v_dados.last()).vr_vllanmto := 87.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9084720;
	v_dados(v_dados.last()).vr_nrctremp := 5566176;
	v_dados(v_dados.last()).vr_vllanmto := 90.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10181202;
	v_dados(v_dados.last()).vr_nrctremp := 5569526;
	v_dados(v_dados.last()).vr_vllanmto := 15.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14700344;
	v_dados(v_dados.last()).vr_nrctremp := 5571768;
	v_dados(v_dados.last()).vr_vllanmto := 82.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14419394;
	v_dados(v_dados.last()).vr_nrctremp := 5573717;
	v_dados(v_dados.last()).vr_vllanmto := 48.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10816186;
	v_dados(v_dados.last()).vr_nrctremp := 5575486;
	v_dados(v_dados.last()).vr_vllanmto := 90.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9674233;
	v_dados(v_dados.last()).vr_nrctremp := 5584453;
	v_dados(v_dados.last()).vr_vllanmto := 59.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3521109;
	v_dados(v_dados.last()).vr_nrctremp := 5592146;
	v_dados(v_dados.last()).vr_vllanmto := 128.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13481622;
	v_dados(v_dados.last()).vr_nrctremp := 5597672;
	v_dados(v_dados.last()).vr_vllanmto := 25.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10325689;
	v_dados(v_dados.last()).vr_nrctremp := 5598139;
	v_dados(v_dados.last()).vr_vllanmto := 104.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12487937;
	v_dados(v_dados.last()).vr_nrctremp := 5598211;
	v_dados(v_dados.last()).vr_vllanmto := 29.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14142350;
	v_dados(v_dados.last()).vr_nrctremp := 5611560;
	v_dados(v_dados.last()).vr_vllanmto := 72.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12445959;
	v_dados(v_dados.last()).vr_nrctremp := 5622328;
	v_dados(v_dados.last()).vr_vllanmto := 65.49;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11576537;
	v_dados(v_dados.last()).vr_nrctremp := 5627369;
	v_dados(v_dados.last()).vr_vllanmto := 21.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12741450;
	v_dados(v_dados.last()).vr_nrctremp := 5646627;
	v_dados(v_dados.last()).vr_vllanmto := 31.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2845555;
	v_dados(v_dados.last()).vr_nrctremp := 5651748;
	v_dados(v_dados.last()).vr_vllanmto := 15.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11788704;
	v_dados(v_dados.last()).vr_nrctremp := 5654123;
	v_dados(v_dados.last()).vr_vllanmto := 61.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12578827;
	v_dados(v_dados.last()).vr_nrctremp := 5665047;
	v_dados(v_dados.last()).vr_vllanmto := 275.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12407836;
	v_dados(v_dados.last()).vr_nrctremp := 5666405;
	v_dados(v_dados.last()).vr_vllanmto := 24.36;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13979655;
	v_dados(v_dados.last()).vr_nrctremp := 5682898;
	v_dados(v_dados.last()).vr_vllanmto := 96.5;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11712643;
	v_dados(v_dados.last()).vr_nrctremp := 5690700;
	v_dados(v_dados.last()).vr_vllanmto := 46.46;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14976994;
	v_dados(v_dados.last()).vr_nrctremp := 5708888;
	v_dados(v_dados.last()).vr_vllanmto := 123.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80110002;
	v_dados(v_dados.last()).vr_nrctremp := 5718829;
	v_dados(v_dados.last()).vr_vllanmto := 15.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12601179;
	v_dados(v_dados.last()).vr_nrctremp := 5736851;
	v_dados(v_dados.last()).vr_vllanmto := 45.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12711586;
	v_dados(v_dados.last()).vr_nrctremp := 5748667;
	v_dados(v_dados.last()).vr_vllanmto := 51.18;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 15029433;
	v_dados(v_dados.last()).vr_nrctremp := 5748692;
	v_dados(v_dados.last()).vr_vllanmto := 47.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7471955;
	v_dados(v_dados.last()).vr_nrctremp := 5750249;
	v_dados(v_dados.last()).vr_vllanmto := 36.74;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10891978;
	v_dados(v_dados.last()).vr_nrctremp := 5755818;
	v_dados(v_dados.last()).vr_vllanmto := 95.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8830797;
	v_dados(v_dados.last()).vr_nrctremp := 5758179;
	v_dados(v_dados.last()).vr_vllanmto := 70.72;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11779713;
	v_dados(v_dados.last()).vr_nrctremp := 5761359;
	v_dados(v_dados.last()).vr_vllanmto := 41.76;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9655336;
	v_dados(v_dados.last()).vr_nrctremp := 5768105;
	v_dados(v_dados.last()).vr_vllanmto := 125.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8613010;
	v_dados(v_dados.last()).vr_nrctremp := 5775082;
	v_dados(v_dados.last()).vr_vllanmto := 30.58;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12182249;
	v_dados(v_dados.last()).vr_nrctremp := 5777537;
	v_dados(v_dados.last()).vr_vllanmto := 21.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9995552;
	v_dados(v_dados.last()).vr_nrctremp := 5777598;
	v_dados(v_dados.last()).vr_vllanmto := 127.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10408592;
	v_dados(v_dados.last()).vr_nrctremp := 5778130;
	v_dados(v_dados.last()).vr_vllanmto := 21.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6819567;
	v_dados(v_dados.last()).vr_nrctremp := 5783710;
	v_dados(v_dados.last()).vr_vllanmto := 31.92;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8410674;
	v_dados(v_dados.last()).vr_nrctremp := 5785057;
	v_dados(v_dados.last()).vr_vllanmto := 37.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7740611;
	v_dados(v_dados.last()).vr_nrctremp := 5786085;
	v_dados(v_dados.last()).vr_vllanmto := 29.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80066810;
	v_dados(v_dados.last()).vr_nrctremp := 5793704;
	v_dados(v_dados.last()).vr_vllanmto := 52.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13625950;
	v_dados(v_dados.last()).vr_nrctremp := 5806140;
	v_dados(v_dados.last()).vr_vllanmto := 80.45;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8479631;
	v_dados(v_dados.last()).vr_nrctremp := 5821254;
	v_dados(v_dados.last()).vr_vllanmto := 17.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12292095;
	v_dados(v_dados.last()).vr_nrctremp := 5828078;
	v_dados(v_dados.last()).vr_vllanmto := 97.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13571257;
	v_dados(v_dados.last()).vr_nrctremp := 5843345;
	v_dados(v_dados.last()).vr_vllanmto := 104.62;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11149604;
	v_dados(v_dados.last()).vr_nrctremp := 5848383;
	v_dados(v_dados.last()).vr_vllanmto := 84.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11824867;
	v_dados(v_dados.last()).vr_nrctremp := 5863502;
	v_dados(v_dados.last()).vr_vllanmto := 16.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12084824;
	v_dados(v_dados.last()).vr_nrctremp := 5872763;
	v_dados(v_dados.last()).vr_vllanmto := 271.08;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8560420;
	v_dados(v_dados.last()).vr_nrctremp := 5875147;
	v_dados(v_dados.last()).vr_vllanmto := 411.46;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 80123694;
	v_dados(v_dados.last()).vr_nrctremp := 5898411;
	v_dados(v_dados.last()).vr_vllanmto := 44.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14775832;
	v_dados(v_dados.last()).vr_nrctremp := 5900438;
	v_dados(v_dados.last()).vr_vllanmto := 25.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2375389;
	v_dados(v_dados.last()).vr_nrctremp := 5900493;
	v_dados(v_dados.last()).vr_vllanmto := 44.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12350800;
	v_dados(v_dados.last()).vr_nrctremp := 5926250;
	v_dados(v_dados.last()).vr_vllanmto := 25.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7326327;
	v_dados(v_dados.last()).vr_nrctremp := 5933181;
	v_dados(v_dados.last()).vr_vllanmto := 16.5;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6942032;
	v_dados(v_dados.last()).vr_nrctremp := 5953798;
	v_dados(v_dados.last()).vr_vllanmto := 20.06;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9348808;
	v_dados(v_dados.last()).vr_nrctremp := 5959615;
	v_dados(v_dados.last()).vr_vllanmto := 15.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 13101420;
	v_dados(v_dados.last()).vr_nrctremp := 5970124;
	v_dados(v_dados.last()).vr_vllanmto := 47.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11505184;
	v_dados(v_dados.last()).vr_nrctremp := 5974368;
	v_dados(v_dados.last()).vr_vllanmto := 266.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 12187259;
	v_dados(v_dados.last()).vr_nrctremp := 5989356;
	v_dados(v_dados.last()).vr_vllanmto := 44.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14185261;
	v_dados(v_dados.last()).vr_nrctremp := 6009251;
	v_dados(v_dados.last()).vr_vllanmto := 24.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8561117;
	v_dados(v_dados.last()).vr_nrctremp := 6019467;
	v_dados(v_dados.last()).vr_vllanmto := 28.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 6720390;
	v_dados(v_dados.last()).vr_nrctremp := 6030356;
	v_dados(v_dados.last()).vr_vllanmto := 18.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 7495323;
	v_dados(v_dados.last()).vr_nrctremp := 6051794;
	v_dados(v_dados.last()).vr_vllanmto := 123.51;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 10955917;
	v_dados(v_dados.last()).vr_nrctremp := 6080290;
	v_dados(v_dados.last()).vr_vllanmto := 18.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9381368;
	v_dados(v_dados.last()).vr_nrctremp := 6088559;
	v_dados(v_dados.last()).vr_vllanmto := 18.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 11100664;
	v_dados(v_dados.last()).vr_nrctremp := 6132418;
	v_dados(v_dados.last()).vr_vllanmto := 73.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14133660;
	v_dados(v_dados.last()).vr_nrctremp := 6137614;
	v_dados(v_dados.last()).vr_vllanmto := 27.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 2195399;
	v_dados(v_dados.last()).vr_nrctremp := 6144299;
	v_dados(v_dados.last()).vr_vllanmto := 20.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 8147019;
	v_dados(v_dados.last()).vr_nrctremp := 6155977;
	v_dados(v_dados.last()).vr_vllanmto := 41.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 14547643;
	v_dados(v_dados.last()).vr_nrctremp := 6225305;
	v_dados(v_dados.last()).vr_vllanmto := 70.29;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 3603270;
	v_dados(v_dados.last()).vr_nrctremp := 6301879;
	v_dados(v_dados.last()).vr_vllanmto := 1427.56;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 1;
	v_dados(v_dados.last()).vr_nrdconta := 9165819;
	v_dados(v_dados.last()).vr_nrctremp := 6315875;
	v_dados(v_dados.last()).vr_vllanmto := 702.89;
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
