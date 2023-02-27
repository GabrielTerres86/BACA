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
	v_dados(v_dados.last()).vr_nrdconta := 221694;
	v_dados(v_dados.last()).vr_nrctremp := 43157;
	v_dados(v_dados.last()).vr_vllanmto := 20.64;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 142824;
	v_dados(v_dados.last()).vr_nrctremp := 27383;
	v_dados(v_dados.last()).vr_vllanmto := 208.18;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 238465;
	v_dados(v_dados.last()).vr_nrctremp := 41176;
	v_dados(v_dados.last()).vr_vllanmto := 22.11;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 115908;
	v_dados(v_dados.last()).vr_nrctremp := 42002;
	v_dados(v_dados.last()).vr_vllanmto := 22.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 227838;
	v_dados(v_dados.last()).vr_nrctremp := 41623;
	v_dados(v_dados.last()).vr_vllanmto := 42.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 155314;
	v_dados(v_dados.last()).vr_nrctremp := 30952;
	v_dados(v_dados.last()).vr_vllanmto := 77.55;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 127574;
	v_dados(v_dados.last()).vr_nrctremp := 39898;
	v_dados(v_dados.last()).vr_vllanmto := 34.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 71145;
	v_dados(v_dados.last()).vr_nrctremp := 41651;
	v_dados(v_dados.last()).vr_vllanmto := 62.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 77542;
	v_dados(v_dados.last()).vr_nrctremp := 29750;
	v_dados(v_dados.last()).vr_vllanmto := 220.74;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 84840;
	v_dados(v_dados.last()).vr_nrctremp := 30015;
	v_dados(v_dados.last()).vr_vllanmto := 188.5;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 94960;
	v_dados(v_dados.last()).vr_nrctremp := 38465;
	v_dados(v_dados.last()).vr_vllanmto := 124.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 108804;
	v_dados(v_dados.last()).vr_nrctremp := 21233;
	v_dados(v_dados.last()).vr_vllanmto := 292.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 4294;
	v_dados(v_dados.last()).vr_nrctremp := 40170;
	v_dados(v_dados.last()).vr_vllanmto := 90.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 14963213;
	v_dados(v_dados.last()).vr_nrctremp := 40800;
	v_dados(v_dados.last()).vr_vllanmto := 103.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 79359;
	v_dados(v_dados.last()).vr_nrctremp := 42754;
	v_dados(v_dados.last()).vr_vllanmto := 17.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 142867;
	v_dados(v_dados.last()).vr_nrctremp := 21554;
	v_dados(v_dados.last()).vr_vllanmto := 92.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 71145;
	v_dados(v_dados.last()).vr_nrctremp := 34416;
	v_dados(v_dados.last()).vr_vllanmto := 178.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 104388;
	v_dados(v_dados.last()).vr_nrctremp := 41599;
	v_dados(v_dados.last()).vr_vllanmto := 78.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 117463;
	v_dados(v_dados.last()).vr_nrctremp := 40166;
	v_dados(v_dados.last()).vr_vllanmto := 92.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 166898;
	v_dados(v_dados.last()).vr_nrctremp := 20193;
	v_dados(v_dados.last()).vr_vllanmto := 107.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 164321;
	v_dados(v_dados.last()).vr_nrctremp := 28487;
	v_dados(v_dados.last()).vr_vllanmto := 64.61;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 239445;
	v_dados(v_dados.last()).vr_nrctremp := 41131;
	v_dados(v_dados.last()).vr_vllanmto := 57.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 15001156;
	v_dados(v_dados.last()).vr_nrctremp := 40974;
	v_dados(v_dados.last()).vr_vllanmto := 39.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 15050246;
	v_dados(v_dados.last()).vr_nrctremp := 43201;
	v_dados(v_dados.last()).vr_vllanmto := 20.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 15385469;
	v_dados(v_dados.last()).vr_nrctremp := 42224;
	v_dados(v_dados.last()).vr_vllanmto := 26.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 139521;
	v_dados(v_dados.last()).vr_nrctremp := 38619;
	v_dados(v_dados.last()).vr_vllanmto := 96.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 108286;
	v_dados(v_dados.last()).vr_nrctremp := 34780;
	v_dados(v_dados.last()).vr_vllanmto := 28.28;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 183962;
	v_dados(v_dados.last()).vr_nrctremp := 27699;
	v_dados(v_dados.last()).vr_vllanmto := 88.37;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 204730;
	v_dados(v_dados.last()).vr_nrctremp := 41771;
	v_dados(v_dados.last()).vr_vllanmto := 26.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 92665;
	v_dados(v_dados.last()).vr_nrctremp := 40917;
	v_dados(v_dados.last()).vr_vllanmto := 39.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 104396;
	v_dados(v_dados.last()).vr_nrctremp := 40916;
	v_dados(v_dados.last()).vr_vllanmto := 80.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 83682;
	v_dados(v_dados.last()).vr_nrctremp := 26001;
	v_dados(v_dados.last()).vr_vllanmto := 75.33;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 20290;
	v_dados(v_dados.last()).vr_nrctremp := 11604;
	v_dados(v_dados.last()).vr_vllanmto := 513.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 68543;
	v_dados(v_dados.last()).vr_nrctremp := 29888;
	v_dados(v_dados.last()).vr_vllanmto := 75.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 166561;
	v_dados(v_dados.last()).vr_nrctremp := 36045;
	v_dados(v_dados.last()).vr_vllanmto := 106.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 190160;
	v_dados(v_dados.last()).vr_nrctremp := 42509;
	v_dados(v_dados.last()).vr_vllanmto := 19.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 103748;
	v_dados(v_dados.last()).vr_nrctremp := 16479;
	v_dados(v_dados.last()).vr_vllanmto := 512.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 120499;
	v_dados(v_dados.last()).vr_nrctremp := 12216;
	v_dados(v_dados.last()).vr_vllanmto := 373.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 186686;
	v_dados(v_dados.last()).vr_nrctremp := 39007;
	v_dados(v_dados.last()).vr_vllanmto := 119.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 117579;
	v_dados(v_dados.last()).vr_nrctremp := 12692;
	v_dados(v_dados.last()).vr_vllanmto := 24.16;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 194743;
	v_dados(v_dados.last()).vr_nrctremp := 37044;
	v_dados(v_dados.last()).vr_vllanmto := 72.41;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 141623;
	v_dados(v_dados.last()).vr_nrctremp := 31901;
	v_dados(v_dados.last()).vr_vllanmto := 423.77;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 119717;
	v_dados(v_dados.last()).vr_nrctremp := 15448;
	v_dados(v_dados.last()).vr_vllanmto := 5452.34;
	v_dados(v_dados.last()).vr_cdhistor := 1040;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 142581;
	v_dados(v_dados.last()).vr_nrctremp := 35077;
	v_dados(v_dados.last()).vr_vllanmto := 507.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 106739;
	v_dados(v_dados.last()).vr_nrctremp := 40157;
	v_dados(v_dados.last()).vr_vllanmto := 66.3;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 177075;
	v_dados(v_dados.last()).vr_nrctremp := 21289;
	v_dados(v_dados.last()).vr_vllanmto := 1042.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 75795;
	v_dados(v_dados.last()).vr_nrctremp := 41743;
	v_dados(v_dados.last()).vr_vllanmto := 90;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 176907;
	v_dados(v_dados.last()).vr_nrctremp := 24267;
	v_dados(v_dados.last()).vr_vllanmto := 169.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 163007;
	v_dados(v_dados.last()).vr_nrctremp := 30697;
	v_dados(v_dados.last()).vr_vllanmto := 739.41;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 103845;
	v_dados(v_dados.last()).vr_nrctremp := 25269;
	v_dados(v_dados.last()).vr_vllanmto := 665.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 198960;
	v_dados(v_dados.last()).vr_nrctremp := 38243;
	v_dados(v_dados.last()).vr_vllanmto := 236.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 116661;
	v_dados(v_dados.last()).vr_nrctremp := 31685;
	v_dados(v_dados.last()).vr_vllanmto := 120.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 145122;
	v_dados(v_dados.last()).vr_nrctremp := 20797;
	v_dados(v_dados.last()).vr_vllanmto := 181.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 151017;
	v_dados(v_dados.last()).vr_nrctremp := 25746;
	v_dados(v_dados.last()).vr_vllanmto := 19.65;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 164291;
	v_dados(v_dados.last()).vr_nrctremp := 20796;
	v_dados(v_dados.last()).vr_vllanmto := 165.16;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 225606;
	v_dados(v_dados.last()).vr_nrctremp := 42328;
	v_dados(v_dados.last()).vr_vllanmto := 50.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 15030032;
	v_dados(v_dados.last()).vr_nrctremp := 41069;
	v_dados(v_dados.last()).vr_vllanmto := 48.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 15375137;
	v_dados(v_dados.last()).vr_nrctremp := 42421;
	v_dados(v_dados.last()).vr_vllanmto := 30.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 133418;
	v_dados(v_dados.last()).vr_nrctremp := 28512;
	v_dados(v_dados.last()).vr_vllanmto := 50.19;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 10;
	v_dados(v_dados.last()).vr_nrdconta := 139351;
	v_dados(v_dados.last()).vr_nrctremp := 40835;
	v_dados(v_dados.last()).vr_vllanmto := 34.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;


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
