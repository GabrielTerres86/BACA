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
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 185.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49743;
    v_dados(v_dados.last()).vr_nrctremp := 13139;
    v_dados(v_dados.last()).vr_vllanmto := 227.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 256.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110833;
    v_dados(v_dados.last()).vr_nrctremp := 19761;
    v_dados(v_dados.last()).vr_vllanmto := 341.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141941;
    v_dados(v_dados.last()).vr_nrctremp := 20085;
    v_dados(v_dados.last()).vr_vllanmto := 155.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166898;
    v_dados(v_dados.last()).vr_nrctremp := 20193;
    v_dados(v_dados.last()).vr_vllanmto := 53.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123358;
    v_dados(v_dados.last()).vr_nrctremp := 20419;
    v_dados(v_dados.last()).vr_vllanmto := 353.81;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129100;
    v_dados(v_dados.last()).vr_nrctremp := 20657;
    v_dados(v_dados.last()).vr_vllanmto := .88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73130;
    v_dados(v_dados.last()).vr_nrctremp := 20750;
    v_dados(v_dados.last()).vr_vllanmto := 106.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164291;
    v_dados(v_dados.last()).vr_nrctremp := 20796;
    v_dados(v_dados.last()).vr_vllanmto := 70.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 90.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86177;
    v_dados(v_dados.last()).vr_nrctremp := 20920;
    v_dados(v_dados.last()).vr_vllanmto := 311.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 148.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 177075;
    v_dados(v_dados.last()).vr_nrctremp := 21289;
    v_dados(v_dados.last()).vr_vllanmto := 526.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138274;
    v_dados(v_dados.last()).vr_nrctremp := 22949;
    v_dados(v_dados.last()).vr_vllanmto := 704.67;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 176907;
    v_dados(v_dados.last()).vr_nrctremp := 24267;
    v_dados(v_dados.last()).vr_vllanmto := 157.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103845;
    v_dados(v_dados.last()).vr_nrctremp := 25269;
    v_dados(v_dados.last()).vr_vllanmto := 332.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48410;
    v_dados(v_dados.last()).vr_nrctremp := 26327;
    v_dados(v_dados.last()).vr_vllanmto := 27.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 88153;
    v_dados(v_dados.last()).vr_nrctremp := 26420;
    v_dados(v_dados.last()).vr_vllanmto := 459.92;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133418;
    v_dados(v_dados.last()).vr_nrctremp := 28512;
    v_dados(v_dados.last()).vr_vllanmto := 38.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77542;
    v_dados(v_dados.last()).vr_nrctremp := 29750;
    v_dados(v_dados.last()).vr_vllanmto := 110.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 68543;
    v_dados(v_dados.last()).vr_nrctremp := 29888;
    v_dados(v_dados.last()).vr_vllanmto := 36.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 122.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187810;
    v_dados(v_dados.last()).vr_nrctremp := 33278;
    v_dados(v_dados.last()).vr_vllanmto := 101.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 33.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133078;
    v_dados(v_dados.last()).vr_nrctremp := 33797;
    v_dados(v_dados.last()).vr_vllanmto := 9734.27;
    v_dados(v_dados.last()).vr_cdhistor := 3018;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 93734;
    v_dados(v_dados.last()).vr_nrctremp := 34131;
    v_dados(v_dados.last()).vr_vllanmto := 109.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 86.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 28.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166561;
    v_dados(v_dados.last()).vr_nrctremp := 36045;
    v_dados(v_dados.last()).vr_vllanmto := 50.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172707;
    v_dados(v_dados.last()).vr_nrctremp := 37810;
    v_dados(v_dados.last()).vr_vllanmto := 54.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104639;
    v_dados(v_dados.last()).vr_nrctremp := 37880;
    v_dados(v_dados.last()).vr_vllanmto := .57;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 198960;
    v_dados(v_dados.last()).vr_nrctremp := 38243;
    v_dados(v_dados.last()).vr_vllanmto := 28.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 80470;
    v_dados(v_dados.last()).vr_nrctremp := 38357;
    v_dados(v_dados.last()).vr_vllanmto := 28.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 38465;
    v_dados(v_dados.last()).vr_vllanmto := 58.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139521;
    v_dados(v_dados.last()).vr_nrctremp := 38619;
    v_dados(v_dados.last()).vr_vllanmto := 36.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85588;
    v_dados(v_dados.last()).vr_nrctremp := 38737;
    v_dados(v_dados.last()).vr_vllanmto := 67.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67415;
    v_dados(v_dados.last()).vr_nrctremp := 38778;
    v_dados(v_dados.last()).vr_vllanmto := 89.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 211630;
    v_dados(v_dados.last()).vr_nrctremp := 39120;
    v_dados(v_dados.last()).vr_vllanmto := 19.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187160;
    v_dados(v_dados.last()).vr_nrctremp := 39403;
    v_dados(v_dados.last()).vr_vllanmto := 64.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112550;
    v_dados(v_dados.last()).vr_nrctremp := 39600;
    v_dados(v_dados.last()).vr_vllanmto := 33.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 131601;
    v_dados(v_dados.last()).vr_nrctremp := 39667;
    v_dados(v_dados.last()).vr_vllanmto := 54.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127574;
    v_dados(v_dados.last()).vr_nrctremp := 39898;
    v_dados(v_dados.last()).vr_vllanmto := 17.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117463;
    v_dados(v_dados.last()).vr_nrctremp := 40166;
    v_dados(v_dados.last()).vr_vllanmto := 46.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 4294;
    v_dados(v_dados.last()).vr_nrctremp := 40170;
    v_dados(v_dados.last()).vr_vllanmto := 44.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 14963213;
    v_dados(v_dados.last()).vr_nrctremp := 40800;
    v_dados(v_dados.last()).vr_vllanmto := 36.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 15030032;
    v_dados(v_dados.last()).vr_nrctremp := 41069;
    v_dados(v_dados.last()).vr_vllanmto := 16.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 171069;
    v_dados(v_dados.last()).vr_nrctremp := 41213;
    v_dados(v_dados.last()).vr_vllanmto := 15.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 124737;
    v_dados(v_dados.last()).vr_nrctremp := 41313;
    v_dados(v_dados.last()).vr_vllanmto := 15.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108766;
    v_dados(v_dados.last()).vr_nrctremp := 41447;
    v_dados(v_dados.last()).vr_vllanmto := 14.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 220620;
    v_dados(v_dados.last()).vr_nrctremp := 41462;
    v_dados(v_dados.last()).vr_vllanmto := 30.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186147;
    v_dados(v_dados.last()).vr_nrctremp := 41645;
    v_dados(v_dados.last()).vr_vllanmto := 23.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 41651;
    v_dados(v_dados.last()).vr_vllanmto := 24.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75795;
    v_dados(v_dados.last()).vr_nrctremp := 41743;
    v_dados(v_dados.last()).vr_vllanmto := 29.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48135;
    v_dados(v_dados.last()).vr_nrctremp := 41813;
    v_dados(v_dados.last()).vr_vllanmto := 15.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166570;
    v_dados(v_dados.last()).vr_nrctremp := 41839;
    v_dados(v_dados.last()).vr_vllanmto := 19.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 196657;
    v_dados(v_dados.last()).vr_nrctremp := 41852;
    v_dados(v_dados.last()).vr_vllanmto := 18.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115908;
    v_dados(v_dados.last()).vr_nrctremp := 42002;
    v_dados(v_dados.last()).vr_vllanmto := 9.74;
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
