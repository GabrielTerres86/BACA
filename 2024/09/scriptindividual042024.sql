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
  v_dados(v_dados.last()).vr_nrdconta := 99967693;
  v_dados(v_dados.last()).vr_nrctremp := 57479;
  v_dados(v_dados.last()).vr_vllanmto := 8558.1;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99918986;
  v_dados(v_dados.last()).vr_nrctremp := 38185;
  v_dados(v_dados.last()).vr_vllanmto := 22155.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99887690;
  v_dados(v_dados.last()).vr_nrctremp := 49467;
  v_dados(v_dados.last()).vr_vllanmto := 147.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99775212;
  v_dados(v_dados.last()).vr_nrctremp := 35191;
  v_dados(v_dados.last()).vr_vllanmto := 175.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99735407;
  v_dados(v_dados.last()).vr_nrctremp := 80922;
  v_dados(v_dados.last()).vr_vllanmto := 325.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99726866;
  v_dados(v_dados.last()).vr_nrctremp := 72254;
  v_dados(v_dados.last()).vr_vllanmto := 2026.36;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99722780;
  v_dados(v_dados.last()).vr_nrctremp := 42448;
  v_dados(v_dados.last()).vr_vllanmto := 487.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99664240;
  v_dados(v_dados.last()).vr_nrctremp := 77871;
  v_dados(v_dados.last()).vr_vllanmto := 479.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99639017;
  v_dados(v_dados.last()).vr_nrctremp := 62245;
  v_dados(v_dados.last()).vr_vllanmto := 3205.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99639017;
  v_dados(v_dados.last()).vr_nrctremp := 73782;
  v_dados(v_dados.last()).vr_vllanmto := 1162.26;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 99636654;
  v_dados(v_dados.last()).vr_nrctremp := 77990;
  v_dados(v_dados.last()).vr_vllanmto := 2308.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 85200573;
  v_dados(v_dados.last()).vr_nrctremp := 67446;
  v_dados(v_dados.last()).vr_vllanmto := 2746.92;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84632879;
  v_dados(v_dados.last()).vr_nrctremp := 98058;
  v_dados(v_dados.last()).vr_vllanmto := 937.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84530189;
  v_dados(v_dados.last()).vr_nrctremp := 99358;
  v_dados(v_dados.last()).vr_vllanmto := 171.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 84172339;
  v_dados(v_dados.last()).vr_nrctremp := 107083;
  v_dados(v_dados.last()).vr_vllanmto := 1706.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83798587;
  v_dados(v_dados.last()).vr_nrctremp := 107408;
  v_dados(v_dados.last()).vr_vllanmto := 2089.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99999242;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 3784.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99744635;
  v_dados(v_dados.last()).vr_nrctremp := 57141;
  v_dados(v_dados.last()).vr_vllanmto := 18010.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99977370;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 8035.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99968258;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 1429.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99938189;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 2791.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99921308;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 2727.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99905205;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 1555.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883449;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 2552.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883406;
  v_dados(v_dados.last()).vr_nrctremp := 247445;
  v_dados(v_dados.last()).vr_vllanmto := 2481.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99883406;
  v_dados(v_dados.last()).vr_nrctremp := 298187;
  v_dados(v_dados.last()).vr_vllanmto := 3165.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99871602;
  v_dados(v_dados.last()).vr_nrctremp := 174807;
  v_dados(v_dados.last()).vr_vllanmto := 3233.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99850044;
  v_dados(v_dados.last()).vr_nrctremp := 190247;
  v_dados(v_dados.last()).vr_vllanmto := 5746.75;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99850044;
  v_dados(v_dados.last()).vr_nrctremp := 191066;
  v_dados(v_dados.last()).vr_vllanmto := 1568.81;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99849631;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 3920.68;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99844338;
  v_dados(v_dados.last()).vr_nrctremp := 311610;
  v_dados(v_dados.last()).vr_vllanmto := 1109.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99829452;
  v_dados(v_dados.last()).vr_nrctremp := 252797;
  v_dados(v_dados.last()).vr_vllanmto := 1246.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 230666;
  v_dados(v_dados.last()).vr_vllanmto := 2365.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 248810;
  v_dados(v_dados.last()).vr_vllanmto := 2449.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 254372;
  v_dados(v_dados.last()).vr_vllanmto := 1476.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 273151;
  v_dados(v_dados.last()).vr_vllanmto := 3119.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99827069;
  v_dados(v_dados.last()).vr_nrctremp := 287913;
  v_dados(v_dados.last()).vr_vllanmto := 3103.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99814404;
  v_dados(v_dados.last()).vr_nrctremp := 205263;
  v_dados(v_dados.last()).vr_vllanmto := 939.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99813696;
  v_dados(v_dados.last()).vr_nrctremp := 278887;
  v_dados(v_dados.last()).vr_vllanmto := 1046.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810140;
  v_dados(v_dados.last()).vr_nrctremp := 212748;
  v_dados(v_dados.last()).vr_vllanmto := 1233.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99810140;
  v_dados(v_dados.last()).vr_nrctremp := 231817;
  v_dados(v_dados.last()).vr_vllanmto := 1233.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99757850;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 1054.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99746883;
  v_dados(v_dados.last()).vr_nrctremp := 94143;
  v_dados(v_dados.last()).vr_vllanmto := 1746.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738813;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 1840.39;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738350;
  v_dados(v_dados.last()).vr_nrctremp := 192919;
  v_dados(v_dados.last()).vr_vllanmto := 915.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99738350;
  v_dados(v_dados.last()).vr_nrctremp := 238468;
  v_dados(v_dados.last()).vr_vllanmto := 1230.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99735016;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 1304.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99710846;
  v_dados(v_dados.last()).vr_nrctremp := 227800;
  v_dados(v_dados.last()).vr_vllanmto := 2774.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99708086;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 1549.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99671921;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 1676.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99655748;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 3821.92;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99631938;
  v_dados(v_dados.last()).vr_nrctremp := 202776;
  v_dados(v_dados.last()).vr_vllanmto := 9910.34;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99623196;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 5312.31;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99616939;
  v_dados(v_dados.last()).vr_nrctremp := 104758;
  v_dados(v_dados.last()).vr_vllanmto := 4224.08;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99579030;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 2202.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99579030;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 832.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99564840;
  v_dados(v_dados.last()).vr_nrctremp := 305094;
  v_dados(v_dados.last()).vr_vllanmto := 1101.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99563371;
  v_dados(v_dados.last()).vr_nrctremp := 263881;
  v_dados(v_dados.last()).vr_vllanmto := 2004.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99554380;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 1522.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99548852;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 2045.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99537915;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 2036.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99537915;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 965.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99536617;
  v_dados(v_dados.last()).vr_nrctremp := 269042;
  v_dados(v_dados.last()).vr_vllanmto := 1233.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99528649;
  v_dados(v_dados.last()).vr_nrctremp := 282785;
  v_dados(v_dados.last()).vr_vllanmto := 3129.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99519429;
  v_dados(v_dados.last()).vr_nrctremp := 209089;
  v_dados(v_dados.last()).vr_vllanmto := 941.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99465922;
  v_dados(v_dados.last()).vr_nrctremp := 145861;
  v_dados(v_dados.last()).vr_vllanmto := 1549.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99465922;
  v_dados(v_dados.last()).vr_nrctremp := 290708;
  v_dados(v_dados.last()).vr_vllanmto := 903.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99460041;
  v_dados(v_dados.last()).vr_nrctremp := 250086;
  v_dados(v_dados.last()).vr_vllanmto := 2222.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99456796;
  v_dados(v_dados.last()).vr_nrctremp := 210362;
  v_dados(v_dados.last()).vr_vllanmto := 986.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99448408;
  v_dados(v_dados.last()).vr_nrctremp := 261412;
  v_dados(v_dados.last()).vr_vllanmto := 1071.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99436442;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 1097.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99434091;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 980.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99422840;
  v_dados(v_dados.last()).vr_nrctremp := 198976;
  v_dados(v_dados.last()).vr_vllanmto := 1003.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99417898;
  v_dados(v_dados.last()).vr_nrctremp := 166819;
  v_dados(v_dados.last()).vr_vllanmto := 2504.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99407159;
  v_dados(v_dados.last()).vr_nrctremp := 271052;
  v_dados(v_dados.last()).vr_vllanmto := 1367.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99389045;
  v_dados(v_dados.last()).vr_nrctremp := 227415;
  v_dados(v_dados.last()).vr_vllanmto := 2046.5;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99385325;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 5168.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99361361;
  v_dados(v_dados.last()).vr_nrctremp := 250085;
  v_dados(v_dados.last()).vr_vllanmto := 1585.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99353342;
  v_dados(v_dados.last()).vr_nrctremp := 229644;
  v_dados(v_dados.last()).vr_vllanmto := 15389.26;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99352478;
  v_dados(v_dados.last()).vr_nrctremp := 288114;
  v_dados(v_dados.last()).vr_vllanmto := 1626.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99352095;
  v_dados(v_dados.last()).vr_nrctremp := 192882;
  v_dados(v_dados.last()).vr_vllanmto := 1146.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99347326;
  v_dados(v_dados.last()).vr_nrctremp := 212819;
  v_dados(v_dados.last()).vr_vllanmto := 1264.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99321084;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 4013.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99304937;
  v_dados(v_dados.last()).vr_nrctremp := 251085;
  v_dados(v_dados.last()).vr_vllanmto := 718.77;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99302454;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 2309.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99302454;
  v_dados(v_dados.last()).vr_nrctremp := 292212;
  v_dados(v_dados.last()).vr_vllanmto := 3024.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99294010;
  v_dados(v_dados.last()).vr_nrctremp := 245304;
  v_dados(v_dados.last()).vr_vllanmto := 1489.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 99245418;
  v_dados(v_dados.last()).vr_nrctremp := 261384;
  v_dados(v_dados.last()).vr_vllanmto := 2770.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85845850;
  v_dados(v_dados.last()).vr_nrctremp := 291115;
  v_dados(v_dados.last()).vr_vllanmto := 3147.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85775681;
  v_dados(v_dados.last()).vr_nrctremp := 176904;
  v_dados(v_dados.last()).vr_vllanmto := 916.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85775681;
  v_dados(v_dados.last()).vr_nrctremp := 176905;
  v_dados(v_dados.last()).vr_vllanmto := 916.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85447595;
  v_dados(v_dados.last()).vr_nrctremp := 241295;
  v_dados(v_dados.last()).vr_vllanmto := 2101.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85397202;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 753.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85277215;
  v_dados(v_dados.last()).vr_nrctremp := 200765;
  v_dados(v_dados.last()).vr_vllanmto := 2493.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85228265;
  v_dados(v_dados.last()).vr_nrctremp := 240186;
  v_dados(v_dados.last()).vr_vllanmto := 998.28;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85207284;
  v_dados(v_dados.last()).vr_nrctremp := 234156;
  v_dados(v_dados.last()).vr_vllanmto := 1729.75;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 215815;
  v_dados(v_dados.last()).vr_vllanmto := 1332.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84946865;
  v_dados(v_dados.last()).vr_nrctremp := 219069;
  v_dados(v_dados.last()).vr_vllanmto := 1596.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84622270;
  v_dados(v_dados.last()).vr_nrctremp := 280792;
  v_dados(v_dados.last()).vr_vllanmto := 777.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84598140;
  v_dados(v_dados.last()).vr_nrctremp := 275871;
  v_dados(v_dados.last()).vr_vllanmto := 1113.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84598140;
  v_dados(v_dados.last()).vr_nrctremp := 306655;
  v_dados(v_dados.last()).vr_vllanmto := 1179.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84559810;
  v_dados(v_dados.last()).vr_nrctremp := 240660;
  v_dados(v_dados.last()).vr_vllanmto := 2345.4;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84273968;
  v_dados(v_dados.last()).vr_nrctremp := 245466;
  v_dados(v_dados.last()).vr_vllanmto := 1542.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84155558;
  v_dados(v_dados.last()).vr_nrctremp := 250425;
  v_dados(v_dados.last()).vr_vllanmto := 16801.8;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84059591;
  v_dados(v_dados.last()).vr_nrctremp := 254682;
  v_dados(v_dados.last()).vr_vllanmto := 766.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83881140;
  v_dados(v_dados.last()).vr_nrctremp := 264780;
  v_dados(v_dados.last()).vr_vllanmto := 904.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83742611;
  v_dados(v_dados.last()).vr_nrctremp := 268640;
  v_dados(v_dados.last()).vr_vllanmto := 1865.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83534423;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 1261.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83261354;
  v_dados(v_dados.last()).vr_nrctremp := 287882;
  v_dados(v_dados.last()).vr_vllanmto := 1205.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 83080058;
  v_dados(v_dados.last()).vr_nrctremp := 294398;
  v_dados(v_dados.last()).vr_vllanmto := 1256.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82950989;
  v_dados(v_dados.last()).vr_nrctremp := 318419;
  v_dados(v_dados.last()).vr_vllanmto := 1587.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82863202;
  v_dados(v_dados.last()).vr_nrctremp := 302270;
  v_dados(v_dados.last()).vr_vllanmto := 1655.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 82664013;
  v_dados(v_dados.last()).vr_nrctremp := 326548;
  v_dados(v_dados.last()).vr_vllanmto := 1336.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350688;
  v_dados(v_dados.last()).vr_vllanmto := 16696.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350692;
  v_dados(v_dados.last()).vr_vllanmto := 17393.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81520131;
  v_dados(v_dados.last()).vr_nrctremp := 350695;
  v_dados(v_dados.last()).vr_vllanmto := 12801.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 81399014;
  v_dados(v_dados.last()).vr_nrctremp := 354971;
  v_dados(v_dados.last()).vr_vllanmto := 89462.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 99978652;
  v_dados(v_dados.last()).vr_nrctremp := 41053;
  v_dados(v_dados.last()).vr_vllanmto := 2061.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 99952246;
  v_dados(v_dados.last()).vr_nrctremp := 32701;
  v_dados(v_dados.last()).vr_vllanmto := 6328.58;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 99812770;
  v_dados(v_dados.last()).vr_nrctremp := 39403;
  v_dados(v_dados.last()).vr_vllanmto := 3279.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 99779811;
  v_dados(v_dados.last()).vr_nrctremp := 40724;
  v_dados(v_dados.last()).vr_vllanmto := 1257.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84873426;
  v_dados(v_dados.last()).vr_nrctremp := 43499;
  v_dados(v_dados.last()).vr_vllanmto := 1379.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84784784;
  v_dados(v_dados.last()).vr_nrctremp := 46629;
  v_dados(v_dados.last()).vr_vllanmto := 3563.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84011742;
  v_dados(v_dados.last()).vr_nrctremp := 44283;
  v_dados(v_dados.last()).vr_vllanmto := 10268.9;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99475235;
  v_dados(v_dados.last()).vr_nrctremp := 97512;
  v_dados(v_dados.last()).vr_vllanmto := 251.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99661306;
  v_dados(v_dados.last()).vr_nrctremp := 103790;
  v_dados(v_dados.last()).vr_vllanmto := 10142.96;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99612160;
  v_dados(v_dados.last()).vr_nrctremp := 85855;
  v_dados(v_dados.last()).vr_vllanmto := 1224.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99476576;
  v_dados(v_dados.last()).vr_nrctremp := 92417;
  v_dados(v_dados.last()).vr_vllanmto := 7195.96;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 99450470;
  v_dados(v_dados.last()).vr_nrctremp := 81619;
  v_dados(v_dados.last()).vr_vllanmto := 2667.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 84757329;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 1292.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82892547;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 1513.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 82317658;
  v_dados(v_dados.last()).vr_nrctremp := 95649;
  v_dados(v_dados.last()).vr_vllanmto := 736.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99714132;
  v_dados(v_dados.last()).vr_nrctremp := 101130;
  v_dados(v_dados.last()).vr_vllanmto := 1885.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99558807;
  v_dados(v_dados.last()).vr_nrctremp := 77668;
  v_dados(v_dados.last()).vr_vllanmto := 964.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 99553996;
  v_dados(v_dados.last()).vr_nrctremp := 82037;
  v_dados(v_dados.last()).vr_vllanmto := 1168.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85914037;
  v_dados(v_dados.last()).vr_nrctremp := 130285;
  v_dados(v_dados.last()).vr_vllanmto := 7115.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85813893;
  v_dados(v_dados.last()).vr_nrctremp := 72163;
  v_dados(v_dados.last()).vr_vllanmto := 1432.92;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85796611;
  v_dados(v_dados.last()).vr_nrctremp := 72406;
  v_dados(v_dados.last()).vr_vllanmto := 1938.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85796611;
  v_dados(v_dados.last()).vr_nrctremp := 85135;
  v_dados(v_dados.last()).vr_vllanmto := 2407.69;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85772151;
  v_dados(v_dados.last()).vr_nrctremp := 72609;
  v_dados(v_dados.last()).vr_vllanmto := 1997.71;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85729230;
  v_dados(v_dados.last()).vr_nrctremp := 79504;
  v_dados(v_dados.last()).vr_vllanmto := 718.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85714054;
  v_dados(v_dados.last()).vr_nrctremp := 77187;
  v_dados(v_dados.last()).vr_vllanmto := 1726.69;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85712892;
  v_dados(v_dados.last()).vr_nrctremp := 74325;
  v_dados(v_dados.last()).vr_vllanmto := 732.59;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85700401;
  v_dados(v_dados.last()).vr_nrctremp := 97212;
  v_dados(v_dados.last()).vr_vllanmto := 4940;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 85580996;
  v_dados(v_dados.last()).vr_nrctremp := 75101;
  v_dados(v_dados.last()).vr_vllanmto := 2288.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84754079;
  v_dados(v_dados.last()).vr_nrctremp := 86919;
  v_dados(v_dados.last()).vr_vllanmto := 3215.86;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84742615;
  v_dados(v_dados.last()).vr_nrctremp := 87201;
  v_dados(v_dados.last()).vr_vllanmto := 1238.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84742615;
  v_dados(v_dados.last()).vr_nrctremp := 91962;
  v_dados(v_dados.last()).vr_vllanmto := 1081.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84436743;
  v_dados(v_dados.last()).vr_nrctremp := 93355;
  v_dados(v_dados.last()).vr_vllanmto := 1077.34;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84137118;
  v_dados(v_dados.last()).vr_nrctremp := 94656;
  v_dados(v_dados.last()).vr_vllanmto := 872.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84135875;
  v_dados(v_dados.last()).vr_nrctremp := 97094;
  v_dados(v_dados.last()).vr_vllanmto := 717.1;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84105631;
  v_dados(v_dados.last()).vr_nrctremp := 95251;
  v_dados(v_dados.last()).vr_vllanmto := 3203.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 84083549;
  v_dados(v_dados.last()).vr_nrctremp := 101061;
  v_dados(v_dados.last()).vr_vllanmto := 3811.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83839577;
  v_dados(v_dados.last()).vr_nrctremp := 101364;
  v_dados(v_dados.last()).vr_vllanmto := 1527.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83521615;
  v_dados(v_dados.last()).vr_nrctremp := 102406;
  v_dados(v_dados.last()).vr_vllanmto := 1404.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 83184945;
  v_dados(v_dados.last()).vr_nrctremp := 118234;
  v_dados(v_dados.last()).vr_vllanmto := 873.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 82987572;
  v_dados(v_dados.last()).vr_nrctremp := 109058;
  v_dados(v_dados.last()).vr_vllanmto := 2213.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99979926;
  v_dados(v_dados.last()).vr_nrctremp := 78448;
  v_dados(v_dados.last()).vr_vllanmto := 972.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99940396;
  v_dados(v_dados.last()).vr_nrctremp := 106670;
  v_dados(v_dados.last()).vr_vllanmto := 1508.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99852241;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 2214.31;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99849895;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 3647.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99650258;
  v_dados(v_dados.last()).vr_nrctremp := 60356;
  v_dados(v_dados.last()).vr_vllanmto := 1116.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 99648288;
  v_dados(v_dados.last()).vr_nrctremp := 66094;
  v_dados(v_dados.last()).vr_vllanmto := 9020.39;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85569763;
  v_dados(v_dados.last()).vr_nrctremp := 65975;
  v_dados(v_dados.last()).vr_vllanmto := 1078.75;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 85482986;
  v_dados(v_dados.last()).vr_nrctremp := 71862;
  v_dados(v_dados.last()).vr_vllanmto := 1080.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 84845414;
  v_dados(v_dados.last()).vr_nrctremp := 92379;
  v_dados(v_dados.last()).vr_vllanmto := 2924.89;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99322498;
  v_dados(v_dados.last()).vr_nrctremp := 382071;
  v_dados(v_dados.last()).vr_vllanmto := 1252.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99263173;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 8744.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99242575;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 5162.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99228424;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 978.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99190370;
  v_dados(v_dados.last()).vr_nrctremp := 381601;
  v_dados(v_dados.last()).vr_vllanmto := 2221;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99133393;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 1746.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99068621;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := 2699.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 99010704;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 1870.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84119136;
  v_dados(v_dados.last()).vr_nrctremp := 426071;
  v_dados(v_dados.last()).vr_vllanmto := 997.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98985000;
  v_dados(v_dados.last()).vr_nrctremp := 348292;
  v_dados(v_dados.last()).vr_vllanmto := 1681.65;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98985000;
  v_dados(v_dados.last()).vr_nrctremp := 374317;
  v_dados(v_dados.last()).vr_vllanmto := 1275.83;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 98909339;
  v_dados(v_dados.last()).vr_nrctremp := 339567;
  v_dados(v_dados.last()).vr_vllanmto := 7510.49;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 85710857;
  v_dados(v_dados.last()).vr_nrctremp := 409576;
  v_dados(v_dados.last()).vr_vllanmto := 4117.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84826290;
  v_dados(v_dados.last()).vr_nrctremp := 396124;
  v_dados(v_dados.last()).vr_vllanmto := 2251.23;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84300019;
  v_dados(v_dados.last()).vr_nrctremp := 427146;
  v_dados(v_dados.last()).vr_vllanmto := 993.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84223871;
  v_dados(v_dados.last()).vr_nrctremp := 421630;
  v_dados(v_dados.last()).vr_vllanmto := 1475.3;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 84214031;
  v_dados(v_dados.last()).vr_nrctremp := 421960;
  v_dados(v_dados.last()).vr_vllanmto := 1606.85;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 83734651;
  v_dados(v_dados.last()).vr_nrctremp := 440729;
  v_dados(v_dados.last()).vr_vllanmto := 1677.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99909405;
  v_dados(v_dados.last()).vr_nrctremp := 494717;
  v_dados(v_dados.last()).vr_vllanmto := 2620.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99744260;
  v_dados(v_dados.last()).vr_nrctremp := 379562;
  v_dados(v_dados.last()).vr_vllanmto := 9142.6;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99695995;
  v_dados(v_dados.last()).vr_nrctremp := 566300;
  v_dados(v_dados.last()).vr_vllanmto := 177.99;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99683849;
  v_dados(v_dados.last()).vr_nrctremp := 520270;
  v_dados(v_dados.last()).vr_vllanmto := 275.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99152622;
  v_dados(v_dados.last()).vr_nrctremp := 709728;
  v_dados(v_dados.last()).vr_vllanmto := 3004.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99106060;
  v_dados(v_dados.last()).vr_nrctremp := 291404;
  v_dados(v_dados.last()).vr_vllanmto := 28695.97;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99106060;
  v_dados(v_dados.last()).vr_nrctremp := 296165;
  v_dados(v_dados.last()).vr_vllanmto := 10383.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99106060;
  v_dados(v_dados.last()).vr_nrctremp := 353154;
  v_dados(v_dados.last()).vr_vllanmto := 183.34;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99106060;
  v_dados(v_dados.last()).vr_nrctremp := 430933;
  v_dados(v_dados.last()).vr_vllanmto := 5620.83;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99056615;
  v_dados(v_dados.last()).vr_nrctremp := 330956;
  v_dados(v_dados.last()).vr_vllanmto := 1709.43;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99037866;
  v_dados(v_dados.last()).vr_nrctremp := 360299;
  v_dados(v_dados.last()).vr_vllanmto := 7272.13;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99021790;
  v_dados(v_dados.last()).vr_nrctremp := 425132;
  v_dados(v_dados.last()).vr_vllanmto := 2507.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 99012987;
  v_dados(v_dados.last()).vr_nrctremp := 373726;
  v_dados(v_dados.last()).vr_vllanmto := 11137.65;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 83581936;
  v_dados(v_dados.last()).vr_nrctremp := 715792;
  v_dados(v_dados.last()).vr_vllanmto := 173.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 98999478;
  v_dados(v_dados.last()).vr_nrctremp := 594282;
  v_dados(v_dados.last()).vr_vllanmto := 220.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 98919687;
  v_dados(v_dados.last()).vr_nrctremp := 617809;
  v_dados(v_dados.last()).vr_vllanmto := 14664.32;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 98018175;
  v_dados(v_dados.last()).vr_nrctremp := 384467;
  v_dados(v_dados.last()).vr_vllanmto := 229.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 97077089;
  v_dados(v_dados.last()).vr_nrctremp := 555897;
  v_dados(v_dados.last()).vr_vllanmto := 407.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 85697257;
  v_dados(v_dados.last()).vr_nrctremp := 426361;
  v_dados(v_dados.last()).vr_vllanmto := 151.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 84519096;
  v_dados(v_dados.last()).vr_nrctremp := 644155;
  v_dados(v_dados.last()).vr_vllanmto := 360.88;
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