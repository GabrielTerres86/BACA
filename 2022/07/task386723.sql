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
    v_dados(v_dados.last()).vr_nrdconta := 678856;
    v_dados(v_dados.last()).vr_nrctremp := 171515;
    v_dados(v_dados.last()).vr_vllanmto := 1786.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161349;
    v_dados(v_dados.last()).vr_nrctremp := 59104;
    v_dados(v_dados.last()).vr_vllanmto := 1057.85;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275050;
    v_dados(v_dados.last()).vr_nrctremp := 75298;
    v_dados(v_dados.last()).vr_vllanmto := 701.29;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143480;
    v_dados(v_dados.last()).vr_nrctremp := 161123;
    v_dados(v_dados.last()).vr_vllanmto := 549.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 96390;
    v_dados(v_dados.last()).vr_vllanmto := 545.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 96389;
    v_dados(v_dados.last()).vr_vllanmto := 434.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141976;
    v_dados(v_dados.last()).vr_nrctremp := 109459;
    v_dados(v_dados.last()).vr_vllanmto := 411.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 2123.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 685739;
    v_dados(v_dados.last()).vr_nrctremp := 176567;
    v_dados(v_dados.last()).vr_vllanmto := 390.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 701564;
    v_dados(v_dados.last()).vr_nrctremp := 159245;
    v_dados(v_dados.last()).vr_vllanmto := 387.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 143813;
    v_dados(v_dados.last()).vr_vllanmto := 4394.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 677132;
    v_dados(v_dados.last()).vr_nrctremp := 170004;
    v_dados(v_dados.last()).vr_vllanmto := 370.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13897;
    v_dados(v_dados.last()).vr_nrctremp := 110414;
    v_dados(v_dados.last()).vr_vllanmto := 368.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 572314;
    v_dados(v_dados.last()).vr_nrctremp := 179477;
    v_dados(v_dados.last()).vr_vllanmto := 357.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120219;
    v_dados(v_dados.last()).vr_nrctremp := 137617;
    v_dados(v_dados.last()).vr_vllanmto := 15260.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 52277;
    v_dados(v_dados.last()).vr_vllanmto := 346.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189693;
    v_dados(v_dados.last()).vr_nrctremp := 116388;
    v_dados(v_dados.last()).vr_vllanmto := 301.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31275;
    v_dados(v_dados.last()).vr_nrctremp := 162267;
    v_dados(v_dados.last()).vr_vllanmto := 296.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 573027;
    v_dados(v_dados.last()).vr_nrctremp := 121298;
    v_dados(v_dados.last()).vr_vllanmto := 295.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 289.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167495;
    v_dados(v_dados.last()).vr_nrctremp := 179272;
    v_dados(v_dados.last()).vr_vllanmto := 289.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 86096;
    v_dados(v_dados.last()).vr_vllanmto := 284.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150550;
    v_dados(v_dados.last()).vr_nrctremp := 146498;
    v_dados(v_dados.last()).vr_vllanmto := 280.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92410;
    v_dados(v_dados.last()).vr_nrctremp := 170991;
    v_dados(v_dados.last()).vr_vllanmto := 278.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 276.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 178763;
    v_dados(v_dados.last()).vr_vllanmto := 275.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154547;
    v_dados(v_dados.last()).vr_nrctremp := 104777;
    v_dados(v_dados.last()).vr_vllanmto := 273.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92428;
    v_dados(v_dados.last()).vr_nrctremp := 94314;
    v_dados(v_dados.last()).vr_vllanmto := 269.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662380;
    v_dados(v_dados.last()).vr_nrctremp := 163482;
    v_dados(v_dados.last()).vr_vllanmto := 268;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148221;
    v_dados(v_dados.last()).vr_vllanmto := 262.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 260.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441376;
    v_dados(v_dados.last()).vr_nrctremp := 62504;
    v_dados(v_dados.last()).vr_vllanmto := 259.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 111511;
    v_dados(v_dados.last()).vr_vllanmto := 250.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524123;
    v_dados(v_dados.last()).vr_nrctremp := 94749;
    v_dados(v_dados.last()).vr_vllanmto := 249.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215864;
    v_dados(v_dados.last()).vr_nrctremp := 57728;
    v_dados(v_dados.last()).vr_vllanmto := 249.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319880;
    v_dados(v_dados.last()).vr_nrctremp := 171064;
    v_dados(v_dados.last()).vr_vllanmto := 246.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 211524;
    v_dados(v_dados.last()).vr_nrctremp := 107457;
    v_dados(v_dados.last()).vr_vllanmto := 242.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 136699;
    v_dados(v_dados.last()).vr_vllanmto := 241.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 582042;
    v_dados(v_dados.last()).vr_nrctremp := 166819;
    v_dados(v_dados.last()).vr_vllanmto := 238.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68616;
    v_dados(v_dados.last()).vr_nrctremp := 178194;
    v_dados(v_dados.last()).vr_vllanmto := 237.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107394;
    v_dados(v_dados.last()).vr_vllanmto := 237.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 257214;
    v_dados(v_dados.last()).vr_nrctremp := 145047;
    v_dados(v_dados.last()).vr_vllanmto := 236.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 177881;
    v_dados(v_dados.last()).vr_nrctremp := 177822;
    v_dados(v_dados.last()).vr_vllanmto := 236.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 101588;
    v_dados(v_dados.last()).vr_vllanmto := 236.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192520;
    v_dados(v_dados.last()).vr_nrctremp := 165359;
    v_dados(v_dados.last()).vr_vllanmto := 234.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 115984;
    v_dados(v_dados.last()).vr_vllanmto := 234.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91189;
    v_dados(v_dados.last()).vr_nrctremp := 84902;
    v_dados(v_dados.last()).vr_vllanmto := 232.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 232.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 123203;
    v_dados(v_dados.last()).vr_vllanmto := 231.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172022;
    v_dados(v_dados.last()).vr_nrctremp := 109017;
    v_dados(v_dados.last()).vr_vllanmto := 230.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135768;
    v_dados(v_dados.last()).vr_vllanmto := 229.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 112081;
    v_dados(v_dados.last()).vr_vllanmto := 226.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 151738;
    v_dados(v_dados.last()).vr_vllanmto := 224.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192350;
    v_dados(v_dados.last()).vr_nrctremp := 112063;
    v_dados(v_dados.last()).vr_vllanmto := 219.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160644;
    v_dados(v_dados.last()).vr_nrctremp := 65833;
    v_dados(v_dados.last()).vr_vllanmto := 211.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 33294;
    v_dados(v_dados.last()).vr_nrctremp := 116931;
    v_dados(v_dados.last()).vr_vllanmto := 207.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120073;
    v_dados(v_dados.last()).vr_nrctremp := 157080;
    v_dados(v_dados.last()).vr_vllanmto := 203.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284874;
    v_dados(v_dados.last()).vr_nrctremp := 157311;
    v_dados(v_dados.last()).vr_vllanmto := 440.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 285072;
    v_dados(v_dados.last()).vr_nrctremp := 83786;
    v_dados(v_dados.last()).vr_vllanmto := 196.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115869;
    v_dados(v_dados.last()).vr_vllanmto := 195.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 72476;
    v_dados(v_dados.last()).vr_vllanmto := 182.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289086;
    v_dados(v_dados.last()).vr_nrctremp := 179357;
    v_dados(v_dados.last()).vr_vllanmto := 195.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185477;
    v_dados(v_dados.last()).vr_nrctremp := 168703;
    v_dados(v_dados.last()).vr_vllanmto := 194.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 291854;
    v_dados(v_dados.last()).vr_nrctremp := 162601;
    v_dados(v_dados.last()).vr_vllanmto := 192.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 32123;
    v_dados(v_dados.last()).vr_nrctremp := 105763;
    v_dados(v_dados.last()).vr_vllanmto := 192.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 97211;
    v_dados(v_dados.last()).vr_vllanmto := 189.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539791;
    v_dados(v_dados.last()).vr_nrctremp := 102357;
    v_dados(v_dados.last()).vr_vllanmto := 186.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 185.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136050;
    v_dados(v_dados.last()).vr_nrctremp := 168147;
    v_dados(v_dados.last()).vr_vllanmto := 184.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143367;
    v_dados(v_dados.last()).vr_nrctremp := 91148;
    v_dados(v_dados.last()).vr_vllanmto := 184.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541303;
    v_dados(v_dados.last()).vr_nrctremp := 103125;
    v_dados(v_dados.last()).vr_vllanmto := 182.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 134611;
    v_dados(v_dados.last()).vr_vllanmto := 182.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142565;
    v_dados(v_dados.last()).vr_nrctremp := 157479;
    v_dados(v_dados.last()).vr_vllanmto := 182.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544167;
    v_dados(v_dados.last()).vr_nrctremp := 104635;
    v_dados(v_dados.last()).vr_vllanmto := 179.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44423;
    v_dados(v_dados.last()).vr_nrctremp := 117780;
    v_dados(v_dados.last()).vr_vllanmto := 179.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 176802;
    v_dados(v_dados.last()).vr_vllanmto := 178.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 629090;
    v_dados(v_dados.last()).vr_nrctremp := 171164;
    v_dados(v_dados.last()).vr_vllanmto := 178.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 547620;
    v_dados(v_dados.last()).vr_nrctremp := 106526;
    v_dados(v_dados.last()).vr_vllanmto := 177.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66800;
    v_dados(v_dados.last()).vr_nrctremp := 138302;
    v_dados(v_dados.last()).vr_vllanmto := 176.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276286;
    v_dados(v_dados.last()).vr_nrctremp := 176821;
    v_dados(v_dados.last()).vr_vllanmto := 176.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 407003;
    v_dados(v_dados.last()).vr_nrctremp := 180030;
    v_dados(v_dados.last()).vr_vllanmto := 176.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541567;
    v_dados(v_dados.last()).vr_nrctremp := 162515;
    v_dados(v_dados.last()).vr_vllanmto := 176.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187402;
    v_dados(v_dados.last()).vr_nrctremp := 118241;
    v_dados(v_dados.last()).vr_vllanmto := 175.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175455;
    v_dados(v_dados.last()).vr_nrctremp := 167766;
    v_dados(v_dados.last()).vr_vllanmto := 174.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143294;
    v_dados(v_dados.last()).vr_nrctremp := 106135;
    v_dados(v_dados.last()).vr_vllanmto := 174.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295159;
    v_dados(v_dados.last()).vr_nrctremp := 72190;
    v_dados(v_dados.last()).vr_vllanmto := 174.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132847;
    v_dados(v_dados.last()).vr_vllanmto := 173.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 616346;
    v_dados(v_dados.last()).vr_nrctremp := 137941;
    v_dados(v_dados.last()).vr_vllanmto := 173.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 172.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110555;
    v_dados(v_dados.last()).vr_vllanmto := 171.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 255300;
    v_dados(v_dados.last()).vr_nrctremp := 57141;
    v_dados(v_dados.last()).vr_vllanmto := 170.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145319;
    v_dados(v_dados.last()).vr_nrctremp := 113718;
    v_dados(v_dados.last()).vr_vllanmto := 170.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 78266;
    v_dados(v_dados.last()).vr_vllanmto := 168.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129898;
    v_dados(v_dados.last()).vr_vllanmto := 156.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116491;
    v_dados(v_dados.last()).vr_nrctremp := 114060;
    v_dados(v_dados.last()).vr_vllanmto := 167.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274321;
    v_dados(v_dados.last()).vr_nrctremp := 166688;
    v_dados(v_dados.last()).vr_vllanmto := 166.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87939;
    v_dados(v_dados.last()).vr_nrctremp := 107291;
    v_dados(v_dados.last()).vr_vllanmto := 165.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379093;
    v_dados(v_dados.last()).vr_nrctremp := 102367;
    v_dados(v_dados.last()).vr_vllanmto := 164.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 163.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219550;
    v_dados(v_dados.last()).vr_nrctremp := 74936;
    v_dados(v_dados.last()).vr_vllanmto := 159.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484067;
    v_dados(v_dados.last()).vr_nrctremp := 100800;
    v_dados(v_dados.last()).vr_vllanmto := 394.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140763;
    v_dados(v_dados.last()).vr_vllanmto := 159.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 99991;
    v_dados(v_dados.last()).vr_vllanmto := 158.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207195;
    v_dados(v_dados.last()).vr_nrctremp := 129934;
    v_dados(v_dados.last()).vr_vllanmto := 157.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298980;
    v_dados(v_dados.last()).vr_nrctremp := 137319;
    v_dados(v_dados.last()).vr_vllanmto := 157.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114640;
    v_dados(v_dados.last()).vr_vllanmto := 157.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 487090;
    v_dados(v_dados.last()).vr_nrctremp := 135302;
    v_dados(v_dados.last()).vr_vllanmto := 156.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290785;
    v_dados(v_dados.last()).vr_nrctremp := 50930;
    v_dados(v_dados.last()).vr_vllanmto := 155.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 154.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66605;
    v_dados(v_dados.last()).vr_nrctremp := 150339;
    v_dados(v_dados.last()).vr_vllanmto := 154.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189499;
    v_dados(v_dados.last()).vr_nrctremp := 121998;
    v_dados(v_dados.last()).vr_vllanmto := 152.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 165756;
    v_dados(v_dados.last()).vr_vllanmto := 152.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25887;
    v_dados(v_dados.last()).vr_nrctremp := 148839;
    v_dados(v_dados.last()).vr_vllanmto := 152.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184586;
    v_dados(v_dados.last()).vr_nrctremp := 136806;
    v_dados(v_dados.last()).vr_vllanmto := 152.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287113;
    v_dados(v_dados.last()).vr_nrctremp := 56588;
    v_dados(v_dados.last()).vr_vllanmto := 152.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 128858;
    v_dados(v_dados.last()).vr_vllanmto := 151.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145742;
    v_dados(v_dados.last()).vr_nrctremp := 162707;
    v_dados(v_dados.last()).vr_vllanmto := 150.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329169;
    v_dados(v_dados.last()).vr_nrctremp := 51801;
    v_dados(v_dados.last()).vr_vllanmto := 150.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 150.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435007;
    v_dados(v_dados.last()).vr_nrctremp := 162711;
    v_dados(v_dados.last()).vr_vllanmto := 148.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 130923;
    v_dados(v_dados.last()).vr_nrctremp := 150081;
    v_dados(v_dados.last()).vr_vllanmto := 148.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103861;
    v_dados(v_dados.last()).vr_nrctremp := 134554;
    v_dados(v_dados.last()).vr_vllanmto := 148.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120170;
    v_dados(v_dados.last()).vr_nrctremp := 78341;
    v_dados(v_dados.last()).vr_vllanmto := 148.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 343196;
    v_dados(v_dados.last()).vr_nrctremp := 132150;
    v_dados(v_dados.last()).vr_vllanmto := 148.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292206;
    v_dados(v_dados.last()).vr_nrctremp := 170286;
    v_dados(v_dados.last()).vr_vllanmto := 147.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 147.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133556;
    v_dados(v_dados.last()).vr_vllanmto := 146.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67245;
    v_dados(v_dados.last()).vr_nrctremp := 164725;
    v_dados(v_dados.last()).vr_vllanmto := 145.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 21539;
    v_dados(v_dados.last()).vr_nrctremp := 95890;
    v_dados(v_dados.last()).vr_vllanmto := 144.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288730;
    v_dados(v_dados.last()).vr_nrctremp := 80332;
    v_dados(v_dados.last()).vr_vllanmto := 144.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66869;
    v_dados(v_dados.last()).vr_nrctremp := 165825;
    v_dados(v_dados.last()).vr_vllanmto := 143.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 85157;
    v_dados(v_dados.last()).vr_vllanmto := 143.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143367;
    v_dados(v_dados.last()).vr_nrctremp := 66735;
    v_dados(v_dados.last()).vr_vllanmto := 142.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 133373;
    v_dados(v_dados.last()).vr_vllanmto := 141.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141207;
    v_dados(v_dados.last()).vr_vllanmto := 141.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := 141.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288535;
    v_dados(v_dados.last()).vr_nrctremp := 98543;
    v_dados(v_dados.last()).vr_vllanmto := 140.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 140.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673854;
    v_dados(v_dados.last()).vr_nrctremp := 167201;
    v_dados(v_dados.last()).vr_vllanmto := 140.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 117009;
    v_dados(v_dados.last()).vr_vllanmto := 139.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183202;
    v_dados(v_dados.last()).vr_nrctremp := 134827;
    v_dados(v_dados.last()).vr_vllanmto := 137.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 134546;
    v_dados(v_dados.last()).vr_nrctremp := 133160;
    v_dados(v_dados.last()).vr_vllanmto := 136.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 431133;
    v_dados(v_dados.last()).vr_nrctremp := 135052;
    v_dados(v_dados.last()).vr_vllanmto := 135.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144045;
    v_dados(v_dados.last()).vr_nrctremp := 158389;
    v_dados(v_dados.last()).vr_vllanmto := 134.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 96352;
    v_dados(v_dados.last()).vr_vllanmto := 134.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142242;
    v_dados(v_dados.last()).vr_vllanmto := 133.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289485;
    v_dados(v_dados.last()).vr_nrctremp := 134062;
    v_dados(v_dados.last()).vr_vllanmto := 133.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149204;
    v_dados(v_dados.last()).vr_vllanmto := 132.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143897;
    v_dados(v_dados.last()).vr_vllanmto := 132.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 56744;
    v_dados(v_dados.last()).vr_vllanmto := 131.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 152069;
    v_dados(v_dados.last()).vr_vllanmto := 131.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272116;
    v_dados(v_dados.last()).vr_nrctremp := 146978;
    v_dados(v_dados.last()).vr_vllanmto := 131.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252760;
    v_dados(v_dados.last()).vr_nrctremp := 89649;
    v_dados(v_dados.last()).vr_vllanmto := 4672.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266906;
    v_dados(v_dados.last()).vr_nrctremp := 60166;
    v_dados(v_dados.last()).vr_vllanmto := 131.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445550;
    v_dados(v_dados.last()).vr_nrctremp := 113391;
    v_dados(v_dados.last()).vr_vllanmto := 131.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349798;
    v_dados(v_dados.last()).vr_nrctremp := 127767;
    v_dados(v_dados.last()).vr_vllanmto := 130.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368920;
    v_dados(v_dados.last()).vr_nrctremp := 66349;
    v_dados(v_dados.last()).vr_vllanmto := 130.44;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368920;
    v_dados(v_dados.last()).vr_nrctremp := 66349;
    v_dados(v_dados.last()).vr_vllanmto := 19651.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149927;
    v_dados(v_dados.last()).vr_vllanmto := 130.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 672130;
    v_dados(v_dados.last()).vr_nrctremp := 166378;
    v_dados(v_dados.last()).vr_vllanmto := 130.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 108368;
    v_dados(v_dados.last()).vr_vllanmto := 129.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247618;
    v_dados(v_dados.last()).vr_nrctremp := 98518;
    v_dados(v_dados.last()).vr_vllanmto := 128.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189499;
    v_dados(v_dados.last()).vr_nrctremp := 122002;
    v_dados(v_dados.last()).vr_vllanmto := 128.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323004;
    v_dados(v_dados.last()).vr_nrctremp := 148733;
    v_dados(v_dados.last()).vr_vllanmto := 127.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9377;
    v_dados(v_dados.last()).vr_nrctremp := 170013;
    v_dados(v_dados.last()).vr_vllanmto := 126.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350745;
    v_dados(v_dados.last()).vr_nrctremp := 157549;
    v_dados(v_dados.last()).vr_vllanmto := 125.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503584;
    v_dados(v_dados.last()).vr_nrctremp := 102245;
    v_dados(v_dados.last()).vr_vllanmto := 125.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66826;
    v_dados(v_dados.last()).vr_nrctremp := 162870;
    v_dados(v_dados.last()).vr_vllanmto := 123.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 50075;
    v_dados(v_dados.last()).vr_nrctremp := 177866;
    v_dados(v_dados.last()).vr_vllanmto := 123.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 145982;
    v_dados(v_dados.last()).vr_vllanmto := 123.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 617482;
    v_dados(v_dados.last()).vr_nrctremp := 137775;
    v_dados(v_dados.last()).vr_vllanmto := 123.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 177890;
    v_dados(v_dados.last()).vr_nrctremp := 52933;
    v_dados(v_dados.last()).vr_vllanmto := 122.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214990;
    v_dados(v_dados.last()).vr_nrctremp := 133412;
    v_dados(v_dados.last()).vr_vllanmto := 121.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 112773;
    v_dados(v_dados.last()).vr_vllanmto := 121.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180661;
    v_dados(v_dados.last()).vr_nrctremp := 51500;
    v_dados(v_dados.last()).vr_vllanmto := 121.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 164001;
    v_dados(v_dados.last()).vr_vllanmto := 121.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 689947;
    v_dados(v_dados.last()).vr_nrctremp := 179402;
    v_dados(v_dados.last()).vr_vllanmto := 120.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462020;
    v_dados(v_dados.last()).vr_nrctremp := 144951;
    v_dados(v_dados.last()).vr_vllanmto := 120.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 383007;
    v_dados(v_dados.last()).vr_nrctremp := 104758;
    v_dados(v_dados.last()).vr_vllanmto := 120.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 132885;
    v_dados(v_dados.last()).vr_vllanmto := 1332.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464511;
    v_dados(v_dados.last()).vr_nrctremp := 70772;
    v_dados(v_dados.last()).vr_vllanmto := 118.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 257214;
    v_dados(v_dados.last()).vr_nrctremp := 146417;
    v_dados(v_dados.last()).vr_vllanmto := 118.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361194;
    v_dados(v_dados.last()).vr_nrctremp := 85779;
    v_dados(v_dados.last()).vr_vllanmto := 118.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135224;
    v_dados(v_dados.last()).vr_nrctremp := 165806;
    v_dados(v_dados.last()).vr_vllanmto := 118.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 101292;
    v_dados(v_dados.last()).vr_vllanmto := 117.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545775;
    v_dados(v_dados.last()).vr_nrctremp := 105332;
    v_dados(v_dados.last()).vr_vllanmto := 117.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132187;
    v_dados(v_dados.last()).vr_nrctremp := 113349;
    v_dados(v_dados.last()).vr_vllanmto := 116.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 79857;
    v_dados(v_dados.last()).vr_vllanmto := 115.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367885;
    v_dados(v_dados.last()).vr_nrctremp := 135319;
    v_dados(v_dados.last()).vr_vllanmto := 114.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124332;
    v_dados(v_dados.last()).vr_vllanmto := 114.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187615;
    v_dados(v_dados.last()).vr_nrctremp := 172942;
    v_dados(v_dados.last()).vr_vllanmto := 113.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 56753;
    v_dados(v_dados.last()).vr_vllanmto := 113.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 113.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 410047;
    v_dados(v_dados.last()).vr_nrctremp := 157762;
    v_dados(v_dados.last()).vr_vllanmto := 113.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62068;
    v_dados(v_dados.last()).vr_vllanmto := 113.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133792;
    v_dados(v_dados.last()).vr_vllanmto := 113.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144576;
    v_dados(v_dados.last()).vr_nrctremp := 110582;
    v_dados(v_dados.last()).vr_vllanmto := 112.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181218;
    v_dados(v_dados.last()).vr_nrctremp := 131509;
    v_dados(v_dados.last()).vr_vllanmto := 112.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129860;
    v_dados(v_dados.last()).vr_nrctremp := 167295;
    v_dados(v_dados.last()).vr_vllanmto := 112.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 173754;
    v_dados(v_dados.last()).vr_nrctremp := 94320;
    v_dados(v_dados.last()).vr_vllanmto := 111.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 661074;
    v_dados(v_dados.last()).vr_nrctremp := 160149;
    v_dados(v_dados.last()).vr_vllanmto := 110.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131873;
    v_dados(v_dados.last()).vr_nrctremp := 80177;
    v_dados(v_dados.last()).vr_vllanmto := 110.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450200;
    v_dados(v_dados.last()).vr_nrctremp := 65949;
    v_dados(v_dados.last()).vr_vllanmto := 110.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353817;
    v_dados(v_dados.last()).vr_nrctremp := 178467;
    v_dados(v_dados.last()).vr_vllanmto := 109.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 134597;
    v_dados(v_dados.last()).vr_vllanmto := 108.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344192;
    v_dados(v_dados.last()).vr_nrctremp := 106118;
    v_dados(v_dados.last()).vr_vllanmto := 108.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524905;
    v_dados(v_dados.last()).vr_nrctremp := 95213;
    v_dados(v_dados.last()).vr_vllanmto := 108.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 45152;
    v_dados(v_dados.last()).vr_nrctremp := 163726;
    v_dados(v_dados.last()).vr_vllanmto := 107.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421200;
    v_dados(v_dados.last()).vr_nrctremp := 56187;
    v_dados(v_dados.last()).vr_vllanmto := 106.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541036;
    v_dados(v_dados.last()).vr_nrctremp := 103157;
    v_dados(v_dados.last()).vr_vllanmto := 106.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256544;
    v_dados(v_dados.last()).vr_nrctremp := 58944;
    v_dados(v_dados.last()).vr_vllanmto := 106.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371696;
    v_dados(v_dados.last()).vr_nrctremp := 94932;
    v_dados(v_dados.last()).vr_vllanmto := 105.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14613;
    v_dados(v_dados.last()).vr_nrctremp := 153842;
    v_dados(v_dados.last()).vr_vllanmto := 104.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419869;
    v_dados(v_dados.last()).vr_nrctremp := 55947;
    v_dados(v_dados.last()).vr_vllanmto := 103.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184381;
    v_dados(v_dados.last()).vr_nrctremp := 55326;
    v_dados(v_dados.last()).vr_vllanmto := 2562.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215937;
    v_dados(v_dados.last()).vr_nrctremp := 112915;
    v_dados(v_dados.last()).vr_vllanmto := 103.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382833;
    v_dados(v_dados.last()).vr_nrctremp := 163160;
    v_dados(v_dados.last()).vr_vllanmto := 102.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188620;
    v_dados(v_dados.last()).vr_nrctremp := 90707;
    v_dados(v_dados.last()).vr_vllanmto := 102.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 200123;
    v_dados(v_dados.last()).vr_nrctremp := 66254;
    v_dados(v_dados.last()).vr_vllanmto := 102.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 84199;
    v_dados(v_dados.last()).vr_vllanmto := 102.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479080;
    v_dados(v_dados.last()).vr_nrctremp := 112509;
    v_dados(v_dados.last()).vr_vllanmto := 102.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 50956;
    v_dados(v_dados.last()).vr_vllanmto := 102.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124281;
    v_dados(v_dados.last()).vr_vllanmto := 101.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 65692;
    v_dados(v_dados.last()).vr_nrctremp := 87320;
    v_dados(v_dados.last()).vr_vllanmto := 101.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155954;
    v_dados(v_dados.last()).vr_vllanmto := 101.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 125901;
    v_dados(v_dados.last()).vr_vllanmto := 101.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91715;
    v_dados(v_dados.last()).vr_nrctremp := 151598;
    v_dados(v_dados.last()).vr_vllanmto := 101.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 153995;
    v_dados(v_dados.last()).vr_vllanmto := 100.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349445;
    v_dados(v_dados.last()).vr_nrctremp := 103359;
    v_dados(v_dados.last()).vr_vllanmto := 100.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161284;
    v_dados(v_dados.last()).vr_nrctremp := 64423;
    v_dados(v_dados.last()).vr_vllanmto := 99.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215104;
    v_dados(v_dados.last()).vr_nrctremp := 112556;
    v_dados(v_dados.last()).vr_vllanmto := 99.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 121365;
    v_dados(v_dados.last()).vr_vllanmto := 99.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187801;
    v_dados(v_dados.last()).vr_nrctremp := 51898;
    v_dados(v_dados.last()).vr_vllanmto := 99.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 573957;
    v_dados(v_dados.last()).vr_nrctremp := 119378;
    v_dados(v_dados.last()).vr_vllanmto := 99.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145708;
    v_dados(v_dados.last()).vr_vllanmto := 98.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 73133;
    v_dados(v_dados.last()).vr_vllanmto := 98.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445118;
    v_dados(v_dados.last()).vr_nrctremp := 63763;
    v_dados(v_dados.last()).vr_vllanmto := 98.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 84854;
    v_dados(v_dados.last()).vr_vllanmto := 98.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 472611;
    v_dados(v_dados.last()).vr_nrctremp := 74229;
    v_dados(v_dados.last()).vr_vllanmto := 98.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71757;
    v_dados(v_dados.last()).vr_nrctremp := 136891;
    v_dados(v_dados.last()).vr_vllanmto := 98.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137031;
    v_dados(v_dados.last()).vr_vllanmto := 97.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521140;
    v_dados(v_dados.last()).vr_nrctremp := 92843;
    v_dados(v_dados.last()).vr_vllanmto := 97.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394033;
    v_dados(v_dados.last()).vr_nrctremp := 90907;
    v_dados(v_dados.last()).vr_vllanmto := 97.35;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9482;
    v_dados(v_dados.last()).vr_nrctremp := 166510;
    v_dados(v_dados.last()).vr_vllanmto := 97.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96229;
    v_dados(v_dados.last()).vr_nrctremp := 150075;
    v_dados(v_dados.last()).vr_vllanmto := 97.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435783;
    v_dados(v_dados.last()).vr_nrctremp := 59124;
    v_dados(v_dados.last()).vr_vllanmto := 97.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561886;
    v_dados(v_dados.last()).vr_nrctremp := 113419;
    v_dados(v_dados.last()).vr_vllanmto := 96.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156396;
    v_dados(v_dados.last()).vr_nrctremp := 160564;
    v_dados(v_dados.last()).vr_vllanmto := 96.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66877;
    v_dados(v_dados.last()).vr_nrctremp := 139636;
    v_dados(v_dados.last()).vr_vllanmto := 126.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240273;
    v_dados(v_dados.last()).vr_nrctremp := 105139;
    v_dados(v_dados.last()).vr_vllanmto := 95.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166480;
    v_dados(v_dados.last()).vr_nrctremp := 73952;
    v_dados(v_dados.last()).vr_vllanmto := 95.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367389;
    v_dados(v_dados.last()).vr_nrctremp := 59342;
    v_dados(v_dados.last()).vr_vllanmto := 94.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163066;
    v_dados(v_dados.last()).vr_nrctremp := 61364;
    v_dados(v_dados.last()).vr_vllanmto := 94.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175609;
    v_dados(v_dados.last()).vr_nrctremp := 51504;
    v_dados(v_dados.last()).vr_vllanmto := 93.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 176806;
    v_dados(v_dados.last()).vr_vllanmto := 93.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 664030;
    v_dados(v_dados.last()).vr_nrctremp := 161218;
    v_dados(v_dados.last()).vr_vllanmto := 93.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140600;
    v_dados(v_dados.last()).vr_nrctremp := 113744;
    v_dados(v_dados.last()).vr_vllanmto := 93.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175099;
    v_dados(v_dados.last()).vr_nrctremp := 54426;
    v_dados(v_dados.last()).vr_vllanmto := 91.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142670;
    v_dados(v_dados.last()).vr_nrctremp := 161255;
    v_dados(v_dados.last()).vr_vllanmto := 91.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 308030;
    v_dados(v_dados.last()).vr_nrctremp := 136035;
    v_dados(v_dados.last()).vr_vllanmto := 91.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425680;
    v_dados(v_dados.last()).vr_nrctremp := 164917;
    v_dados(v_dados.last()).vr_vllanmto := 91.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286745;
    v_dados(v_dados.last()).vr_nrctremp := 60515;
    v_dados(v_dados.last()).vr_vllanmto := 91.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462110;
    v_dados(v_dados.last()).vr_nrctremp := 69670;
    v_dados(v_dados.last()).vr_vllanmto := 91.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42404;
    v_dados(v_dados.last()).vr_nrctremp := 53091;
    v_dados(v_dados.last()).vr_vllanmto := 91.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91480;
    v_dados(v_dados.last()).vr_nrctremp := 143020;
    v_dados(v_dados.last()).vr_vllanmto := 91.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292303;
    v_dados(v_dados.last()).vr_nrctremp := 150969;
    v_dados(v_dados.last()).vr_vllanmto := 90.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 261580;
    v_dados(v_dados.last()).vr_nrctremp := 50935;
    v_dados(v_dados.last()).vr_vllanmto := 89.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534633;
    v_dados(v_dados.last()).vr_nrctremp := 99621;
    v_dados(v_dados.last()).vr_vllanmto := 89.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156025;
    v_dados(v_dados.last()).vr_vllanmto := 89.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 81657;
    v_dados(v_dados.last()).vr_vllanmto := 88.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180777;
    v_dados(v_dados.last()).vr_nrctremp := 153272;
    v_dados(v_dados.last()).vr_vllanmto := 88.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90360;
    v_dados(v_dados.last()).vr_nrctremp := 71345;
    v_dados(v_dados.last()).vr_vllanmto := 88.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396770;
    v_dados(v_dados.last()).vr_nrctremp := 53402;
    v_dados(v_dados.last()).vr_vllanmto := 6486.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132810;
    v_dados(v_dados.last()).vr_nrctremp := 129063;
    v_dados(v_dados.last()).vr_vllanmto := 87.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215414;
    v_dados(v_dados.last()).vr_nrctremp := 61817;
    v_dados(v_dados.last()).vr_vllanmto := 87.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252514;
    v_dados(v_dados.last()).vr_nrctremp := 172328;
    v_dados(v_dados.last()).vr_vllanmto := 87.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 121973;
    v_dados(v_dados.last()).vr_vllanmto := 87.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647527;
    v_dados(v_dados.last()).vr_nrctremp := 152360;
    v_dados(v_dados.last()).vr_vllanmto := 87.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445100;
    v_dados(v_dados.last()).vr_nrctremp := 63764;
    v_dados(v_dados.last()).vr_vllanmto := 86.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150304;
    v_dados(v_dados.last()).vr_nrctremp := 59164;
    v_dados(v_dados.last()).vr_vllanmto := 86.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 454419;
    v_dados(v_dados.last()).vr_nrctremp := 67569;
    v_dados(v_dados.last()).vr_vllanmto := 86.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 162602;
    v_dados(v_dados.last()).vr_vllanmto := 86.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137561;
    v_dados(v_dados.last()).vr_vllanmto := 86.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267414;
    v_dados(v_dados.last()).vr_nrctremp := 76193;
    v_dados(v_dados.last()).vr_vllanmto := 86.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 151743;
    v_dados(v_dados.last()).vr_vllanmto := 86.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78322;
    v_dados(v_dados.last()).vr_vllanmto := 86.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349780;
    v_dados(v_dados.last()).vr_nrctremp := 153608;
    v_dados(v_dados.last()).vr_vllanmto := 86.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 127079;
    v_dados(v_dados.last()).vr_vllanmto := 85.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 85.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92029;
    v_dados(v_dados.last()).vr_nrctremp := 123921;
    v_dados(v_dados.last()).vr_vllanmto := 85.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 175474;
    v_dados(v_dados.last()).vr_vllanmto := 85.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 160897;
    v_dados(v_dados.last()).vr_vllanmto := 85.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 114018;
    v_dados(v_dados.last()).vr_vllanmto := 85.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159972;
    v_dados(v_dados.last()).vr_nrctremp := 147219;
    v_dados(v_dados.last()).vr_vllanmto := 85.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323004;
    v_dados(v_dados.last()).vr_nrctremp := 149276;
    v_dados(v_dados.last()).vr_vllanmto := 85.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90891;
    v_dados(v_dados.last()).vr_nrctremp := 179280;
    v_dados(v_dados.last()).vr_vllanmto := 85.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319236;
    v_dados(v_dados.last()).vr_nrctremp := 153326;
    v_dados(v_dados.last()).vr_vllanmto := 85.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 69400;
    v_dados(v_dados.last()).vr_nrctremp := 143506;
    v_dados(v_dados.last()).vr_vllanmto := 85.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 245437;
    v_dados(v_dados.last()).vr_nrctremp := 92577;
    v_dados(v_dados.last()).vr_vllanmto := 85.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155955;
    v_dados(v_dados.last()).vr_vllanmto := 84.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 64834;
    v_dados(v_dados.last()).vr_vllanmto := 84.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78166;
    v_dados(v_dados.last()).vr_nrctremp := 107659;
    v_dados(v_dados.last()).vr_vllanmto := 84.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 41599;
    v_dados(v_dados.last()).vr_nrctremp := 178620;
    v_dados(v_dados.last()).vr_vllanmto := 3177.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 434183;
    v_dados(v_dados.last()).vr_nrctremp := 58723;
    v_dados(v_dados.last()).vr_vllanmto := 84.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154547;
    v_dados(v_dados.last()).vr_nrctremp := 103971;
    v_dados(v_dados.last()).vr_vllanmto := 84.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 23388;
    v_dados(v_dados.last()).vr_nrctremp := 59749;
    v_dados(v_dados.last()).vr_vllanmto := 83.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 178449;
    v_dados(v_dados.last()).vr_vllanmto := 83.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267627;
    v_dados(v_dados.last()).vr_nrctremp := 52677;
    v_dados(v_dados.last()).vr_vllanmto := 83.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 102651;
    v_dados(v_dados.last()).vr_vllanmto := 83.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 58367;
    v_dados(v_dados.last()).vr_vllanmto := 83.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 179306;
    v_dados(v_dados.last()).vr_vllanmto := 82.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 106976;
    v_dados(v_dados.last()).vr_vllanmto := 82.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13226;
    v_dados(v_dados.last()).vr_nrctremp := 115394;
    v_dados(v_dados.last()).vr_vllanmto := 82.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673552;
    v_dados(v_dados.last()).vr_nrctremp := 166691;
    v_dados(v_dados.last()).vr_vllanmto := 81.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155419;
    v_dados(v_dados.last()).vr_vllanmto := 81.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295515;
    v_dados(v_dados.last()).vr_nrctremp := 57927;
    v_dados(v_dados.last()).vr_vllanmto := 81.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 134129;
    v_dados(v_dados.last()).vr_vllanmto := 80.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 164345;
    v_dados(v_dados.last()).vr_vllanmto := 80.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163473;
    v_dados(v_dados.last()).vr_nrctremp := 180227;
    v_dados(v_dados.last()).vr_vllanmto := 80.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 125887;
    v_dados(v_dados.last()).vr_vllanmto := 80.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 626368;
    v_dados(v_dados.last()).vr_nrctremp := 150466;
    v_dados(v_dados.last()).vr_vllanmto := 80.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294691;
    v_dados(v_dados.last()).vr_nrctremp := 181157;
    v_dados(v_dados.last()).vr_vllanmto := 80.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 105884;
    v_dados(v_dados.last()).vr_vllanmto := 80.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 60470;
    v_dados(v_dados.last()).vr_vllanmto := 80.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350664;
    v_dados(v_dados.last()).vr_nrctremp := 125552;
    v_dados(v_dados.last()).vr_vllanmto := 80.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91227;
    v_dados(v_dados.last()).vr_nrctremp := 66497;
    v_dados(v_dados.last()).vr_vllanmto := 80.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193810;
    v_dados(v_dados.last()).vr_nrctremp := 147432;
    v_dados(v_dados.last()).vr_vllanmto := 79.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 151150;
    v_dados(v_dados.last()).vr_vllanmto := 79.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 162545;
    v_dados(v_dados.last()).vr_vllanmto := 74.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124311;
    v_dados(v_dados.last()).vr_nrctremp := 142173;
    v_dados(v_dados.last()).vr_vllanmto := 79.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106404;
    v_dados(v_dados.last()).vr_vllanmto := 79.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214450;
    v_dados(v_dados.last()).vr_nrctremp := 100349;
    v_dados(v_dados.last()).vr_vllanmto := 79.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193518;
    v_dados(v_dados.last()).vr_nrctremp := 91698;
    v_dados(v_dados.last()).vr_vllanmto := 79.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62072;
    v_dados(v_dados.last()).vr_vllanmto := 79.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 149849;
    v_dados(v_dados.last()).vr_vllanmto := 74.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 78.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353507;
    v_dados(v_dados.last()).vr_nrctremp := 155363;
    v_dados(v_dados.last()).vr_vllanmto := 78.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202576;
    v_dados(v_dados.last()).vr_nrctremp := 104041;
    v_dados(v_dados.last()).vr_vllanmto := 78.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 501786;
    v_dados(v_dados.last()).vr_nrctremp := 86925;
    v_dados(v_dados.last()).vr_vllanmto := 77.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 80312;
    v_dados(v_dados.last()).vr_vllanmto := 77.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 324400;
    v_dados(v_dados.last()).vr_nrctremp := 124236;
    v_dados(v_dados.last()).vr_vllanmto := 77.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91782;
    v_dados(v_dados.last()).vr_nrctremp := 178838;
    v_dados(v_dados.last()).vr_vllanmto := 77.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151453;
    v_dados(v_dados.last()).vr_vllanmto := 77.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59382;
    v_dados(v_dados.last()).vr_nrctremp := 86032;
    v_dados(v_dados.last()).vr_vllanmto := 77.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206504;
    v_dados(v_dados.last()).vr_nrctremp := 92512;
    v_dados(v_dados.last()).vr_vllanmto := 77.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 522457;
    v_dados(v_dados.last()).vr_nrctremp := 107491;
    v_dados(v_dados.last()).vr_vllanmto := 77.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187143;
    v_dados(v_dados.last()).vr_nrctremp := 132407;
    v_dados(v_dados.last()).vr_vllanmto := 76.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256013;
    v_dados(v_dados.last()).vr_nrctremp := 96840;
    v_dados(v_dados.last()).vr_vllanmto := 76.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91251;
    v_dados(v_dados.last()).vr_nrctremp := 51354;
    v_dados(v_dados.last()).vr_vllanmto := 76.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219428;
    v_dados(v_dados.last()).vr_nrctremp := 108994;
    v_dados(v_dados.last()).vr_vllanmto := 76.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 76.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116530;
    v_dados(v_dados.last()).vr_nrctremp := 67611;
    v_dados(v_dados.last()).vr_vllanmto := 76.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146013;
    v_dados(v_dados.last()).vr_nrctremp := 154533;
    v_dados(v_dados.last()).vr_vllanmto := 76.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424145;
    v_dados(v_dados.last()).vr_nrctremp := 56667;
    v_dados(v_dados.last()).vr_vllanmto := 76.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 135118;
    v_dados(v_dados.last()).vr_vllanmto := 76.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293822;
    v_dados(v_dados.last()).vr_nrctremp := 57792;
    v_dados(v_dados.last()).vr_vllanmto := 75.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 297194;
    v_dados(v_dados.last()).vr_nrctremp := 74771;
    v_dados(v_dados.last()).vr_vllanmto := 75.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 46531;
    v_dados(v_dados.last()).vr_nrctremp := 116188;
    v_dados(v_dados.last()).vr_vllanmto := 75.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382302;
    v_dados(v_dados.last()).vr_nrctremp := 101411;
    v_dados(v_dados.last()).vr_vllanmto := 75.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 261122;
    v_dados(v_dados.last()).vr_nrctremp := 146561;
    v_dados(v_dados.last()).vr_vllanmto := 75.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107662;
    v_dados(v_dados.last()).vr_nrctremp := 59838;
    v_dados(v_dados.last()).vr_vllanmto := 75.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168491;
    v_dados(v_dados.last()).vr_nrctremp := 92472;
    v_dados(v_dados.last()).vr_vllanmto := 75.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 92189;
    v_dados(v_dados.last()).vr_vllanmto := 75.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 253057;
    v_dados(v_dados.last()).vr_nrctremp := 94143;
    v_dados(v_dados.last()).vr_vllanmto := 75.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 372021;
    v_dados(v_dados.last()).vr_nrctremp := 108178;
    v_dados(v_dados.last()).vr_vllanmto := 75.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184349;
    v_dados(v_dados.last()).vr_nrctremp := 146087;
    v_dados(v_dados.last()).vr_vllanmto := 75.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614610;
    v_dados(v_dados.last()).vr_nrctremp := 157203;
    v_dados(v_dados.last()).vr_vllanmto := 74.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 104829;
    v_dados(v_dados.last()).vr_vllanmto := 74.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 135380;
    v_dados(v_dados.last()).vr_vllanmto := 73.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350893;
    v_dados(v_dados.last()).vr_nrctremp := 146914;
    v_dados(v_dados.last()).vr_vllanmto := 73.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168564;
    v_dados(v_dados.last()).vr_nrctremp := 96542;
    v_dados(v_dados.last()).vr_vllanmto := 73.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78140;
    v_dados(v_dados.last()).vr_nrctremp := 159388;
    v_dados(v_dados.last()).vr_vllanmto := 73.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 132284;
    v_dados(v_dados.last()).vr_vllanmto := 73.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 67514;
    v_dados(v_dados.last()).vr_vllanmto := 73.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 443972;
    v_dados(v_dados.last()).vr_nrctremp := 73022;
    v_dados(v_dados.last()).vr_vllanmto := 73.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138231;
    v_dados(v_dados.last()).vr_nrctremp := 63482;
    v_dados(v_dados.last()).vr_vllanmto := 73.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268712;
    v_dados(v_dados.last()).vr_nrctremp := 68804;
    v_dados(v_dados.last()).vr_vllanmto := 73.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107625;
    v_dados(v_dados.last()).vr_vllanmto := 73.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170097;
    v_dados(v_dados.last()).vr_nrctremp := 55565;
    v_dados(v_dados.last()).vr_vllanmto := 72.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 608203;
    v_dados(v_dados.last()).vr_nrctremp := 172851;
    v_dados(v_dados.last()).vr_vllanmto := 72.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145319;
    v_dados(v_dados.last()).vr_nrctremp := 114005;
    v_dados(v_dados.last()).vr_vllanmto := 72.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280836;
    v_dados(v_dados.last()).vr_nrctremp := 144048;
    v_dados(v_dados.last()).vr_vllanmto := 72.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188204;
    v_dados(v_dados.last()).vr_nrctremp := 65655;
    v_dados(v_dados.last()).vr_vllanmto := 72.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154466;
    v_dados(v_dados.last()).vr_nrctremp := 99993;
    v_dados(v_dados.last()).vr_vllanmto := 41.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142921;
    v_dados(v_dados.last()).vr_nrctremp := 75052;
    v_dados(v_dados.last()).vr_vllanmto := 71.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107397;
    v_dados(v_dados.last()).vr_vllanmto := 71.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91995;
    v_dados(v_dados.last()).vr_nrctremp := 126548;
    v_dados(v_dados.last()).vr_vllanmto := 71.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 380032;
    v_dados(v_dados.last()).vr_nrctremp := 171257;
    v_dados(v_dados.last()).vr_vllanmto := 71.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93122;
    v_dados(v_dados.last()).vr_nrctremp := 136111;
    v_dados(v_dados.last()).vr_vllanmto := 1101.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351881;
    v_dados(v_dados.last()).vr_nrctremp := 158736;
    v_dados(v_dados.last()).vr_vllanmto := 71.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 412481;
    v_dados(v_dados.last()).vr_nrctremp := 97843;
    v_dados(v_dados.last()).vr_vllanmto := 71.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 147680;
    v_dados(v_dados.last()).vr_vllanmto := 70.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185485;
    v_dados(v_dados.last()).vr_nrctremp := 58844;
    v_dados(v_dados.last()).vr_vllanmto := 70.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94951;
    v_dados(v_dados.last()).vr_nrctremp := 140766;
    v_dados(v_dados.last()).vr_vllanmto := 70.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 162673;
    v_dados(v_dados.last()).vr_vllanmto := 69.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 224162;
    v_dados(v_dados.last()).vr_nrctremp := 116604;
    v_dados(v_dados.last()).vr_vllanmto := 68.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155420;
    v_dados(v_dados.last()).vr_vllanmto := 68.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182702;
    v_dados(v_dados.last()).vr_nrctremp := 53514;
    v_dados(v_dados.last()).vr_vllanmto := 68.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91391;
    v_dados(v_dados.last()).vr_nrctremp := 80583;
    v_dados(v_dados.last()).vr_vllanmto := 68.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71512;
    v_dados(v_dados.last()).vr_vllanmto := 68.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26700;
    v_dados(v_dados.last()).vr_nrctremp := 52820;
    v_dados(v_dados.last()).vr_vllanmto := 67.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294144;
    v_dados(v_dados.last()).vr_nrctremp := 177413;
    v_dados(v_dados.last()).vr_vllanmto := 67.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 123277;
    v_dados(v_dados.last()).vr_nrctremp := 172864;
    v_dados(v_dados.last()).vr_vllanmto := 67.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240419;
    v_dados(v_dados.last()).vr_nrctremp := 114886;
    v_dados(v_dados.last()).vr_vllanmto := 67.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 511870;
    v_dados(v_dados.last()).vr_nrctremp := 162284;
    v_dados(v_dados.last()).vr_vllanmto := 66.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190985;
    v_dados(v_dados.last()).vr_nrctremp := 144153;
    v_dados(v_dados.last()).vr_vllanmto := 66.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135769;
    v_dados(v_dados.last()).vr_vllanmto := 66.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 104597;
    v_dados(v_dados.last()).vr_vllanmto := 5166.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 51281;
    v_dados(v_dados.last()).vr_vllanmto := 65.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284220;
    v_dados(v_dados.last()).vr_nrctremp := 102835;
    v_dados(v_dados.last()).vr_vllanmto := 65.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425230;
    v_dados(v_dados.last()).vr_nrctremp := 56888;
    v_dados(v_dados.last()).vr_vllanmto := 64.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146395;
    v_dados(v_dados.last()).vr_vllanmto := 64.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 150785;
    v_dados(v_dados.last()).vr_vllanmto := 64.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103608;
    v_dados(v_dados.last()).vr_nrctremp := 150645;
    v_dados(v_dados.last()).vr_vllanmto := 64.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139402;
    v_dados(v_dados.last()).vr_vllanmto := 64.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 112211;
    v_dados(v_dados.last()).vr_vllanmto := 64.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183202;
    v_dados(v_dados.last()).vr_nrctremp := 134829;
    v_dados(v_dados.last()).vr_vllanmto := 64.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 118810;
    v_dados(v_dados.last()).vr_vllanmto := 64.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129693;
    v_dados(v_dados.last()).vr_vllanmto := 64.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 110909;
    v_dados(v_dados.last()).vr_vllanmto := 64.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137559;
    v_dados(v_dados.last()).vr_vllanmto := 64.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 113422;
    v_dados(v_dados.last()).vr_vllanmto := 64.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 141142;
    v_dados(v_dados.last()).vr_vllanmto := 64.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 96326;
    v_dados(v_dados.last()).vr_vllanmto := 64.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133557;
    v_dados(v_dados.last()).vr_vllanmto := 64.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109428;
    v_dados(v_dados.last()).vr_nrctremp := 154257;
    v_dados(v_dados.last()).vr_vllanmto := 63.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 116408;
    v_dados(v_dados.last()).vr_vllanmto := 63.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95044;
    v_dados(v_dados.last()).vr_nrctremp := 70093;
    v_dados(v_dados.last()).vr_vllanmto := 63.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185760;
    v_dados(v_dados.last()).vr_nrctremp := 134538;
    v_dados(v_dados.last()).vr_vllanmto := 63.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 376744;
    v_dados(v_dados.last()).vr_nrctremp := 78331;
    v_dados(v_dados.last()).vr_vllanmto := 63.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256757;
    v_dados(v_dados.last()).vr_nrctremp := 137189;
    v_dados(v_dados.last()).vr_vllanmto := 63.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 418285;
    v_dados(v_dados.last()).vr_nrctremp := 55603;
    v_dados(v_dados.last()).vr_vllanmto := 62.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153605;
    v_dados(v_dados.last()).vr_nrctremp := 85830;
    v_dados(v_dados.last()).vr_vllanmto := 62.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 108116;
    v_dados(v_dados.last()).vr_vllanmto := 62.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 101770;
    v_dados(v_dados.last()).vr_nrctremp := 56372;
    v_dados(v_dados.last()).vr_vllanmto := 62.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186740;
    v_dados(v_dados.last()).vr_nrctremp := 119858;
    v_dados(v_dados.last()).vr_vllanmto := 58.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 364037;
    v_dados(v_dados.last()).vr_nrctremp := 148552;
    v_dados(v_dados.last()).vr_vllanmto := 62.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149896;
    v_dados(v_dados.last()).vr_nrctremp := 118072;
    v_dados(v_dados.last()).vr_vllanmto := 11225.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 79379;
    v_dados(v_dados.last()).vr_vllanmto := 62.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322890;
    v_dados(v_dados.last()).vr_nrctremp := 147538;
    v_dados(v_dados.last()).vr_vllanmto := 62.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 105022;
    v_dados(v_dados.last()).vr_vllanmto := 61.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 649899;
    v_dados(v_dados.last()).vr_nrctremp := 153142;
    v_dados(v_dados.last()).vr_vllanmto := 61.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78319;
    v_dados(v_dados.last()).vr_vllanmto := 61.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288942;
    v_dados(v_dados.last()).vr_nrctremp := 165100;
    v_dados(v_dados.last()).vr_vllanmto := 61.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 53664;
    v_dados(v_dados.last()).vr_vllanmto := 61.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 486230;
    v_dados(v_dados.last()).vr_nrctremp := 81443;
    v_dados(v_dados.last()).vr_vllanmto := 61.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 487090;
    v_dados(v_dados.last()).vr_nrctremp := 135114;
    v_dados(v_dados.last()).vr_vllanmto := 61.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190217;
    v_dados(v_dados.last()).vr_nrctremp := 105065;
    v_dados(v_dados.last()).vr_vllanmto := 61.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420883;
    v_dados(v_dados.last()).vr_nrctremp := 147127;
    v_dados(v_dados.last()).vr_vllanmto := 61.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 113777;
    v_dados(v_dados.last()).vr_vllanmto := 60.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146021;
    v_dados(v_dados.last()).vr_nrctremp := 90524;
    v_dados(v_dados.last()).vr_vllanmto := 60.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188336;
    v_dados(v_dados.last()).vr_nrctremp := 153815;
    v_dados(v_dados.last()).vr_vllanmto := 60.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 137990;
    v_dados(v_dados.last()).vr_vllanmto := 60.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 416606;
    v_dados(v_dados.last()).vr_nrctremp := 179261;
    v_dados(v_dados.last()).vr_vllanmto := 60.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265381;
    v_dados(v_dados.last()).vr_nrctremp := 162693;
    v_dados(v_dados.last()).vr_vllanmto := 60.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498815;
    v_dados(v_dados.last()).vr_nrctremp := 84901;
    v_dados(v_dados.last()).vr_vllanmto := 60.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 125819;
    v_dados(v_dados.last()).vr_vllanmto := 59.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 65227;
    v_dados(v_dados.last()).vr_vllanmto := 1621.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269913;
    v_dados(v_dados.last()).vr_nrctremp := 68956;
    v_dados(v_dados.last()).vr_vllanmto := 59.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 87965;
    v_dados(v_dados.last()).vr_vllanmto := 59.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 164615;
    v_dados(v_dados.last()).vr_nrctremp := 92827;
    v_dados(v_dados.last()).vr_vllanmto := 59.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 87898;
    v_dados(v_dados.last()).vr_vllanmto := 59.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107620;
    v_dados(v_dados.last()).vr_nrctremp := 132064;
    v_dados(v_dados.last()).vr_vllanmto := 58.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 150930;
    v_dados(v_dados.last()).vr_vllanmto := 58.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163171;
    v_dados(v_dados.last()).vr_nrctremp := 106698;
    v_dados(v_dados.last()).vr_vllanmto := 58.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 160898;
    v_dados(v_dados.last()).vr_vllanmto := 58.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133795;
    v_dados(v_dados.last()).vr_vllanmto := 58.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191833;
    v_dados(v_dados.last()).vr_nrctremp := 111115;
    v_dados(v_dados.last()).vr_vllanmto := 58.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268240;
    v_dados(v_dados.last()).vr_nrctremp := 139411;
    v_dados(v_dados.last()).vr_vllanmto := 58.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185574;
    v_dados(v_dados.last()).vr_nrctremp := 105662;
    v_dados(v_dados.last()).vr_vllanmto := 57.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 138460;
    v_dados(v_dados.last()).vr_vllanmto := 57.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 57.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328227;
    v_dados(v_dados.last()).vr_nrctremp := 136480;
    v_dados(v_dados.last()).vr_vllanmto := 57.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 354996;
    v_dados(v_dados.last()).vr_nrctremp := 81005;
    v_dados(v_dados.last()).vr_vllanmto := 57.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 516384;
    v_dados(v_dados.last()).vr_nrctremp := 94406;
    v_dados(v_dados.last()).vr_vllanmto := 57.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322865;
    v_dados(v_dados.last()).vr_nrctremp := 133461;
    v_dados(v_dados.last()).vr_vllanmto := 57.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141976;
    v_dados(v_dados.last()).vr_nrctremp := 109534;
    v_dados(v_dados.last()).vr_vllanmto := 57.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524310;
    v_dados(v_dados.last()).vr_nrctremp := 94882;
    v_dados(v_dados.last()).vr_vllanmto := 57.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 89779;
    v_dados(v_dados.last()).vr_vllanmto := 57.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 474649;
    v_dados(v_dados.last()).vr_nrctremp := 74805;
    v_dados(v_dados.last()).vr_vllanmto := 57.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142387;
    v_dados(v_dados.last()).vr_nrctremp := 182021;
    v_dados(v_dados.last()).vr_vllanmto := 57.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 111312;
    v_dados(v_dados.last()).vr_vllanmto := 57.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95257;
    v_dados(v_dados.last()).vr_nrctremp := 114045;
    v_dados(v_dados.last()).vr_vllanmto := 57.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 70313;
    v_dados(v_dados.last()).vr_vllanmto := 57.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 285072;
    v_dados(v_dados.last()).vr_nrctremp := 98107;
    v_dados(v_dados.last()).vr_vllanmto := 56.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104701;
    v_dados(v_dados.last()).vr_vllanmto := 56.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 162609;
    v_dados(v_dados.last()).vr_vllanmto := 56.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90824;
    v_dados(v_dados.last()).vr_nrctremp := 73327;
    v_dados(v_dados.last()).vr_vllanmto := 56.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 461610;
    v_dados(v_dados.last()).vr_nrctremp := 145393;
    v_dados(v_dados.last()).vr_vllanmto := 56.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269921;
    v_dados(v_dados.last()).vr_nrctremp := 53607;
    v_dados(v_dados.last()).vr_vllanmto := 56.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 86810;
    v_dados(v_dados.last()).vr_vllanmto := 56.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 482510;
    v_dados(v_dados.last()).vr_nrctremp := 180159;
    v_dados(v_dados.last()).vr_vllanmto := 56.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148504;
    v_dados(v_dados.last()).vr_nrctremp := 54228;
    v_dados(v_dados.last()).vr_vllanmto := 56.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 340561;
    v_dados(v_dados.last()).vr_nrctremp := 69746;
    v_dados(v_dados.last()).vr_vllanmto := 55.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 130951;
    v_dados(v_dados.last()).vr_vllanmto := 55.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59688;
    v_dados(v_dados.last()).vr_vllanmto := 55.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114636;
    v_dados(v_dados.last()).vr_vllanmto := 55.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670324;
    v_dados(v_dados.last()).vr_nrctremp := 167935;
    v_dados(v_dados.last()).vr_vllanmto := 55.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242136;
    v_dados(v_dados.last()).vr_nrctremp := 58349;
    v_dados(v_dados.last()).vr_vllanmto := 55.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66672;
    v_dados(v_dados.last()).vr_nrctremp := 179795;
    v_dados(v_dados.last()).vr_vllanmto := 55.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 422339;
    v_dados(v_dados.last()).vr_nrctremp := 110088;
    v_dados(v_dados.last()).vr_vllanmto := 55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 119046;
    v_dados(v_dados.last()).vr_vllanmto := 54.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132187;
    v_dados(v_dados.last()).vr_nrctremp := 91180;
    v_dados(v_dados.last()).vr_vllanmto := 54.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96121;
    v_dados(v_dados.last()).vr_nrctremp := 66693;
    v_dados(v_dados.last()).vr_vllanmto := 54.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80250;
    v_dados(v_dados.last()).vr_nrctremp := 139169;
    v_dados(v_dados.last()).vr_vllanmto := 54.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214981;
    v_dados(v_dados.last()).vr_nrctremp := 71663;
    v_dados(v_dados.last()).vr_vllanmto := 54.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 78967;
    v_dados(v_dados.last()).vr_vllanmto := 2059.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124334;
    v_dados(v_dados.last()).vr_vllanmto := 54.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318639;
    v_dados(v_dados.last()).vr_nrctremp := 58849;
    v_dados(v_dados.last()).vr_vllanmto := 54.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190136;
    v_dados(v_dados.last()).vr_nrctremp := 117890;
    v_dados(v_dados.last()).vr_vllanmto := 54.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641790;
    v_dados(v_dados.last()).vr_nrctremp := 148852;
    v_dados(v_dados.last()).vr_vllanmto := 54.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170119;
    v_dados(v_dados.last()).vr_nrctremp := 72763;
    v_dados(v_dados.last()).vr_vllanmto := 54.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 465836;
    v_dados(v_dados.last()).vr_nrctremp := 72026;
    v_dados(v_dados.last()).vr_vllanmto := 54.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94999;
    v_dados(v_dados.last()).vr_vllanmto := 53.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 153499;
    v_dados(v_dados.last()).vr_vllanmto := 53.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148101;
    v_dados(v_dados.last()).vr_vllanmto := 53.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521256;
    v_dados(v_dados.last()).vr_nrctremp := 92946;
    v_dados(v_dados.last()).vr_vllanmto := 53.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14224259;
    v_dados(v_dados.last()).vr_nrctremp := 176905;
    v_dados(v_dados.last()).vr_vllanmto := 53.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 164160;
    v_dados(v_dados.last()).vr_nrctremp := 164893;
    v_dados(v_dados.last()).vr_vllanmto := 53.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9490;
    v_dados(v_dados.last()).vr_nrctremp := 144368;
    v_dados(v_dados.last()).vr_vllanmto := 53.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 103395;
    v_dados(v_dados.last()).vr_vllanmto := 53.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 112505;
    v_dados(v_dados.last()).vr_vllanmto := 53.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292060;
    v_dados(v_dados.last()).vr_nrctremp := 133165;
    v_dados(v_dados.last()).vr_vllanmto := 52.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 165521;
    v_dados(v_dados.last()).vr_vllanmto := 52.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185272;
    v_dados(v_dados.last()).vr_nrctremp := 139153;
    v_dados(v_dados.last()).vr_vllanmto := 52.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129410;
    v_dados(v_dados.last()).vr_nrctremp := 158870;
    v_dados(v_dados.last()).vr_vllanmto := 52.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 160694;
    v_dados(v_dados.last()).vr_vllanmto := 52.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136956;
    v_dados(v_dados.last()).vr_nrctremp := 115239;
    v_dados(v_dados.last()).vr_vllanmto := 52.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149205;
    v_dados(v_dados.last()).vr_vllanmto := 52.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 144134;
    v_dados(v_dados.last()).vr_vllanmto := 5880.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104586;
    v_dados(v_dados.last()).vr_vllanmto := 51.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44164;
    v_dados(v_dados.last()).vr_nrctremp := 89193;
    v_dados(v_dados.last()).vr_vllanmto := 51.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 51.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 119253;
    v_dados(v_dados.last()).vr_vllanmto := 51.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112758;
    v_dados(v_dados.last()).vr_vllanmto := 51.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 113595;
    v_dados(v_dados.last()).vr_vllanmto := 51.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371580;
    v_dados(v_dados.last()).vr_nrctremp := 120210;
    v_dados(v_dados.last()).vr_vllanmto := 51.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 158922;
    v_dados(v_dados.last()).vr_vllanmto := 51.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172022;
    v_dados(v_dados.last()).vr_nrctremp := 109022;
    v_dados(v_dados.last()).vr_vllanmto := 51.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 177493;
    v_dados(v_dados.last()).vr_vllanmto := 51.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 414433;
    v_dados(v_dados.last()).vr_nrctremp := 54746;
    v_dados(v_dados.last()).vr_vllanmto := 51.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131369;
    v_dados(v_dados.last()).vr_vllanmto := 51.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 134812;
    v_dados(v_dados.last()).vr_vllanmto := 50.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 53636;
    v_dados(v_dados.last()).vr_vllanmto := 50.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96245;
    v_dados(v_dados.last()).vr_nrctremp := 171345;
    v_dados(v_dados.last()).vr_vllanmto := 50.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 241172;
    v_dados(v_dados.last()).vr_nrctremp := 53833;
    v_dados(v_dados.last()).vr_vllanmto := 1414.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44164;
    v_dados(v_dados.last()).vr_nrctremp := 55210;
    v_dados(v_dados.last()).vr_vllanmto := 50.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 474649;
    v_dados(v_dados.last()).vr_nrctremp := 116129;
    v_dados(v_dados.last()).vr_vllanmto := 50.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185370;
    v_dados(v_dados.last()).vr_nrctremp := 143454;
    v_dados(v_dados.last()).vr_vllanmto := 50.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287113;
    v_dados(v_dados.last()).vr_nrctremp := 56588;
    v_dados(v_dados.last()).vr_vllanmto := 49.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264768;
    v_dados(v_dados.last()).vr_nrctremp := 102540;
    v_dados(v_dados.last()).vr_vllanmto := 49.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180777;
    v_dados(v_dados.last()).vr_nrctremp := 153278;
    v_dados(v_dados.last()).vr_vllanmto := 49.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181617;
    v_dados(v_dados.last()).vr_nrctremp := 178592;
    v_dados(v_dados.last()).vr_vllanmto := 49.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201146;
    v_dados(v_dados.last()).vr_nrctremp := 137625;
    v_dados(v_dados.last()).vr_vllanmto := 49.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 609447;
    v_dados(v_dados.last()).vr_nrctremp := 139009;
    v_dados(v_dados.last()).vr_vllanmto := 49.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 444499;
    v_dados(v_dados.last()).vr_nrctremp := 90846;
    v_dados(v_dados.last()).vr_vllanmto := 49.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182826;
    v_dados(v_dados.last()).vr_nrctremp := 96500;
    v_dados(v_dados.last()).vr_vllanmto := 49.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303771;
    v_dados(v_dados.last()).vr_nrctremp := 128054;
    v_dados(v_dados.last()).vr_vllanmto := 48.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 162345;
    v_dados(v_dados.last()).vr_nrctremp := 106041;
    v_dados(v_dados.last()).vr_vllanmto := 48.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78778;
    v_dados(v_dados.last()).vr_nrctremp := 106214;
    v_dados(v_dados.last()).vr_vllanmto := 48.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293695;
    v_dados(v_dados.last()).vr_nrctremp := 165346;
    v_dados(v_dados.last()).vr_vllanmto := 48.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 71878;
    v_dados(v_dados.last()).vr_vllanmto := 24.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95141;
    v_dados(v_dados.last()).vr_nrctremp := 128642;
    v_dados(v_dados.last()).vr_vllanmto := 48.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167495;
    v_dados(v_dados.last()).vr_nrctremp := 179350;
    v_dados(v_dados.last()).vr_vllanmto := 47.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355771;
    v_dados(v_dados.last()).vr_nrctremp := 144078;
    v_dados(v_dados.last()).vr_vllanmto := 47.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141372;
    v_dados(v_dados.last()).vr_nrctremp := 143883;
    v_dados(v_dados.last()).vr_vllanmto := 47.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 133043;
    v_dados(v_dados.last()).vr_nrctremp := 178154;
    v_dados(v_dados.last()).vr_vllanmto := 47.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 146804;
    v_dados(v_dados.last()).vr_vllanmto := 46.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 59646;
    v_dados(v_dados.last()).vr_vllanmto := 46.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 90393;
    v_dados(v_dados.last()).vr_vllanmto := 46.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188310;
    v_dados(v_dados.last()).vr_nrctremp := 59272;
    v_dados(v_dados.last()).vr_vllanmto := 46.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 492639;
    v_dados(v_dados.last()).vr_nrctremp := 161075;
    v_dados(v_dados.last()).vr_vllanmto := 46.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298875;
    v_dados(v_dados.last()).vr_nrctremp := 58507;
    v_dados(v_dados.last()).vr_vllanmto := 46.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116050;
    v_dados(v_dados.last()).vr_nrctremp := 79995;
    v_dados(v_dados.last()).vr_vllanmto := 46.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 76694;
    v_dados(v_dados.last()).vr_vllanmto := 46.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316237;
    v_dados(v_dados.last()).vr_nrctremp := 76421;
    v_dados(v_dados.last()).vr_vllanmto := 46.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278157;
    v_dados(v_dados.last()).vr_nrctremp := 168697;
    v_dados(v_dados.last()).vr_vllanmto := 46.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94900;
    v_dados(v_dados.last()).vr_vllanmto := 46.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287296;
    v_dados(v_dados.last()).vr_nrctremp := 161269;
    v_dados(v_dados.last()).vr_vllanmto := 46.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 142634;
    v_dados(v_dados.last()).vr_vllanmto := 45.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 169989;
    v_dados(v_dados.last()).vr_vllanmto := 45.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 439827;
    v_dados(v_dados.last()).vr_nrctremp := 161852;
    v_dados(v_dados.last()).vr_vllanmto := 47.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267716;
    v_dados(v_dados.last()).vr_nrctremp := 180089;
    v_dados(v_dados.last()).vr_vllanmto := 45.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140765;
    v_dados(v_dados.last()).vr_vllanmto := 45.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 543144;
    v_dados(v_dados.last()).vr_nrctremp := 128653;
    v_dados(v_dados.last()).vr_vllanmto := 45.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 490695;
    v_dados(v_dados.last()).vr_nrctremp := 179989;
    v_dados(v_dados.last()).vr_vllanmto := 45.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321907;
    v_dados(v_dados.last()).vr_nrctremp := 162583;
    v_dados(v_dados.last()).vr_vllanmto := 45.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 45.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96423;
    v_dados(v_dados.last()).vr_nrctremp := 63486;
    v_dados(v_dados.last()).vr_vllanmto := 45.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83766;
    v_dados(v_dados.last()).vr_vllanmto := 44.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252212;
    v_dados(v_dados.last()).vr_nrctremp := 140398;
    v_dados(v_dados.last()).vr_vllanmto := 44.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 73958;
    v_dados(v_dados.last()).vr_vllanmto := 44.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 63814;
    v_dados(v_dados.last()).vr_vllanmto := 44.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141054;
    v_dados(v_dados.last()).vr_nrctremp := 114747;
    v_dados(v_dados.last()).vr_vllanmto := 44.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240540;
    v_dados(v_dados.last()).vr_nrctremp := 95357;
    v_dados(v_dados.last()).vr_vllanmto := 44.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 137039;
    v_dados(v_dados.last()).vr_vllanmto := 44.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13498;
    v_dados(v_dados.last()).vr_nrctremp := 64928;
    v_dados(v_dados.last()).vr_vllanmto := 44.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 312550;
    v_dados(v_dados.last()).vr_nrctremp := 105658;
    v_dados(v_dados.last()).vr_vllanmto := 44.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 135746;
    v_dados(v_dados.last()).vr_vllanmto := 44.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132850;
    v_dados(v_dados.last()).vr_vllanmto := 44.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156540;
    v_dados(v_dados.last()).vr_nrctremp := 120079;
    v_dados(v_dados.last()).vr_vllanmto := 44.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189154;
    v_dados(v_dados.last()).vr_nrctremp := 92177;
    v_dados(v_dados.last()).vr_vllanmto := 44.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 492817;
    v_dados(v_dados.last()).vr_nrctremp := 82433;
    v_dados(v_dados.last()).vr_vllanmto := 43.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149465;
    v_dados(v_dados.last()).vr_vllanmto := 43.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148318;
    v_dados(v_dados.last()).vr_nrctremp := 67246;
    v_dados(v_dados.last()).vr_vllanmto := 43.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 92218;
    v_dados(v_dados.last()).vr_vllanmto := 43.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80608;
    v_dados(v_dados.last()).vr_nrctremp := 61297;
    v_dados(v_dados.last()).vr_vllanmto := 43.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387657;
    v_dados(v_dados.last()).vr_nrctremp := 119327;
    v_dados(v_dados.last()).vr_vllanmto := 43.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445347;
    v_dados(v_dados.last()).vr_nrctremp := 63834;
    v_dados(v_dados.last()).vr_vllanmto := 43.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 138828;
    v_dados(v_dados.last()).vr_vllanmto := 43.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298123;
    v_dados(v_dados.last()).vr_nrctremp := 158837;
    v_dados(v_dados.last()).vr_vllanmto := 43.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179752;
    v_dados(v_dados.last()).vr_nrctremp := 151796;
    v_dados(v_dados.last()).vr_vllanmto := 43.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 115337;
    v_dados(v_dados.last()).vr_vllanmto := 42.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395528;
    v_dados(v_dados.last()).vr_nrctremp := 53113;
    v_dados(v_dados.last()).vr_vllanmto := 928.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112689;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156540;
    v_dados(v_dados.last()).vr_nrctremp := 120078;
    v_dados(v_dados.last()).vr_vllanmto := 42.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 570001;
    v_dados(v_dados.last()).vr_nrctremp := 136709;
    v_dados(v_dados.last()).vr_vllanmto := 42.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 416665;
    v_dados(v_dados.last()).vr_nrctremp := 55346;
    v_dados(v_dados.last()).vr_vllanmto := 42.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 85063;
    v_dados(v_dados.last()).vr_vllanmto := 42.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 144508;
    v_dados(v_dados.last()).vr_vllanmto := 42.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110590;
    v_dados(v_dados.last()).vr_vllanmto := 42.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371700;
    v_dados(v_dados.last()).vr_nrctremp := 94933;
    v_dados(v_dados.last()).vr_vllanmto := 42.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 123120;
    v_dados(v_dados.last()).vr_vllanmto := 41.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 88226;
    v_dados(v_dados.last()).vr_vllanmto := 41.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199788;
    v_dados(v_dados.last()).vr_nrctremp := 164878;
    v_dados(v_dados.last()).vr_vllanmto := 41.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 70386;
    v_dados(v_dados.last()).vr_nrctremp := 138212;
    v_dados(v_dados.last()).vr_vllanmto := 41.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367885;
    v_dados(v_dados.last()).vr_nrctremp := 101325;
    v_dados(v_dados.last()).vr_vllanmto := 41.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 82142;
    v_dados(v_dados.last()).vr_vllanmto := 41.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 145861;
    v_dados(v_dados.last()).vr_vllanmto := 41.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135810;
    v_dados(v_dados.last()).vr_nrctremp := 133666;
    v_dados(v_dados.last()).vr_vllanmto := 41.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156029;
    v_dados(v_dados.last()).vr_vllanmto := 40.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150550;
    v_dados(v_dados.last()).vr_nrctremp := 113707;
    v_dados(v_dados.last()).vr_vllanmto := 40.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 174874;
    v_dados(v_dados.last()).vr_nrctremp := 51025;
    v_dados(v_dados.last()).vr_vllanmto := 40.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237396;
    v_dados(v_dados.last()).vr_nrctremp := 147484;
    v_dados(v_dados.last()).vr_vllanmto := 40.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 282936;
    v_dados(v_dados.last()).vr_nrctremp := 109758;
    v_dados(v_dados.last()).vr_vllanmto := 53.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179752;
    v_dados(v_dados.last()).vr_nrctremp := 157779;
    v_dados(v_dados.last()).vr_vllanmto := 40.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92240;
    v_dados(v_dados.last()).vr_nrctremp := 131646;
    v_dados(v_dados.last()).vr_vllanmto := 39.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146013;
    v_dados(v_dados.last()).vr_nrctremp := 88685;
    v_dados(v_dados.last()).vr_vllanmto := 39.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159212;
    v_dados(v_dados.last()).vr_nrctremp := 99937;
    v_dados(v_dados.last()).vr_vllanmto := 39.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 96421;
    v_dados(v_dados.last()).vr_vllanmto := 39.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 182764;
    v_dados(v_dados.last()).vr_vllanmto := 39.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199770;
    v_dados(v_dados.last()).vr_nrctremp := 176779;
    v_dados(v_dados.last()).vr_vllanmto := 39.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 117044;
    v_dados(v_dados.last()).vr_vllanmto := 39.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 413607;
    v_dados(v_dados.last()).vr_nrctremp := 163237;
    v_dados(v_dados.last()).vr_vllanmto := 39.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323519;
    v_dados(v_dados.last()).vr_nrctremp := 73280;
    v_dados(v_dados.last()).vr_vllanmto := 39.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467367;
    v_dados(v_dados.last()).vr_nrctremp := 149121;
    v_dados(v_dados.last()).vr_vllanmto := 39.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 151838;
    v_dados(v_dados.last()).vr_vllanmto := 36.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129089;
    v_dados(v_dados.last()).vr_vllanmto := 38.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 118012;
    v_dados(v_dados.last()).vr_vllanmto := 38.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145190;
    v_dados(v_dados.last()).vr_nrctremp := 138246;
    v_dados(v_dados.last()).vr_vllanmto := 38.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215570;
    v_dados(v_dados.last()).vr_nrctremp := 142885;
    v_dados(v_dados.last()).vr_vllanmto := 1307.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190047;
    v_dados(v_dados.last()).vr_nrctremp := 158762;
    v_dados(v_dados.last()).vr_vllanmto := 38.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 301469;
    v_dados(v_dados.last()).vr_nrctremp := 123630;
    v_dados(v_dados.last()).vr_vllanmto := 38.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78107;
    v_dados(v_dados.last()).vr_nrctremp := 87139;
    v_dados(v_dados.last()).vr_vllanmto := 38.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170305;
    v_dados(v_dados.last()).vr_nrctremp := 122762;
    v_dados(v_dados.last()).vr_vllanmto := 38.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142353;
    v_dados(v_dados.last()).vr_vllanmto := 38.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68039;
    v_dados(v_dados.last()).vr_nrctremp := 51124;
    v_dados(v_dados.last()).vr_vllanmto := 38.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144118;
    v_dados(v_dados.last()).vr_nrctremp := 131588;
    v_dados(v_dados.last()).vr_vllanmto := 38.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360961;
    v_dados(v_dados.last()).vr_nrctremp := 151569;
    v_dados(v_dados.last()).vr_vllanmto := 38.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624470;
    v_dados(v_dados.last()).vr_nrctremp := 140410;
    v_dados(v_dados.last()).vr_vllanmto := 38.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 164635;
    v_dados(v_dados.last()).vr_vllanmto := 37.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115868;
    v_dados(v_dados.last()).vr_vllanmto := 37.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 104221;
    v_dados(v_dados.last()).vr_nrctremp := 133190;
    v_dados(v_dados.last()).vr_vllanmto := 37.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150657;
    v_dados(v_dados.last()).vr_nrctremp := 99264;
    v_dados(v_dados.last()).vr_vllanmto := 37.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144045;
    v_dados(v_dados.last()).vr_nrctremp := 158391;
    v_dados(v_dados.last()).vr_vllanmto := 37.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 95562;
    v_dados(v_dados.last()).vr_vllanmto := 36.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247170;
    v_dados(v_dados.last()).vr_nrctremp := 136469;
    v_dados(v_dados.last()).vr_vllanmto := 36.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 36.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 79380;
    v_dados(v_dados.last()).vr_vllanmto := 36.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218294;
    v_dados(v_dados.last()).vr_nrctremp := 64242;
    v_dados(v_dados.last()).vr_vllanmto := 36.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 78237;
    v_dados(v_dados.last()).vr_vllanmto := 36.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 149104;
    v_dados(v_dados.last()).vr_vllanmto := 36.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483923;
    v_dados(v_dados.last()).vr_nrctremp := 92602;
    v_dados(v_dados.last()).vr_vllanmto := 36.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112687;
    v_dados(v_dados.last()).vr_vllanmto := 36.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42056;
    v_dados(v_dados.last()).vr_nrctremp := 129501;
    v_dados(v_dados.last()).vr_vllanmto := 36.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 165854;
    v_dados(v_dados.last()).vr_vllanmto := 44.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 111086;
    v_dados(v_dados.last()).vr_vllanmto := 36.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 95094;
    v_dados(v_dados.last()).vr_vllanmto := 35.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328014;
    v_dados(v_dados.last()).vr_nrctremp := 100186;
    v_dados(v_dados.last()).vr_vllanmto := 35.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139845;
    v_dados(v_dados.last()).vr_vllanmto := 35.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 129804;
    v_dados(v_dados.last()).vr_vllanmto := 35.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 134311;
    v_dados(v_dados.last()).vr_vllanmto := 35.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263125;
    v_dados(v_dados.last()).vr_nrctremp := 181387;
    v_dados(v_dados.last()).vr_vllanmto := 35.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351830;
    v_dados(v_dados.last()).vr_nrctremp := 56500;
    v_dados(v_dados.last()).vr_vllanmto := 355.15;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264768;
    v_dados(v_dados.last()).vr_nrctremp := 72541;
    v_dados(v_dados.last()).vr_vllanmto := 35.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 57983;
    v_dados(v_dados.last()).vr_vllanmto := 480.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 469661;
    v_dados(v_dados.last()).vr_nrctremp := 135698;
    v_dados(v_dados.last()).vr_vllanmto := 35.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 108981;
    v_dados(v_dados.last()).vr_vllanmto := 34.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149469;
    v_dados(v_dados.last()).vr_vllanmto := 34.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 112938;
    v_dados(v_dados.last()).vr_vllanmto := 34.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 34.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 81658;
    v_dados(v_dados.last()).vr_vllanmto := 34.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298980;
    v_dados(v_dados.last()).vr_nrctremp := 155781;
    v_dados(v_dados.last()).vr_vllanmto := 34.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219428;
    v_dados(v_dados.last()).vr_nrctremp := 108998;
    v_dados(v_dados.last()).vr_vllanmto := 34.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 76848;
    v_dados(v_dados.last()).vr_vllanmto := 34.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 155016;
    v_dados(v_dados.last()).vr_vllanmto := 33.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 399922;
    v_dados(v_dados.last()).vr_nrctremp := 55401;
    v_dados(v_dados.last()).vr_vllanmto := 33.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22560;
    v_dados(v_dados.last()).vr_nrctremp := 84128;
    v_dados(v_dados.last()).vr_vllanmto := 33.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 128698;
    v_dados(v_dados.last()).vr_vllanmto := 33.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 607533;
    v_dados(v_dados.last()).vr_nrctremp := 133553;
    v_dados(v_dados.last()).vr_vllanmto := 33.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286540;
    v_dados(v_dados.last()).vr_nrctremp := 181564;
    v_dados(v_dados.last()).vr_vllanmto := 33.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145980;
    v_dados(v_dados.last()).vr_vllanmto := 32.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199974;
    v_dados(v_dados.last()).vr_nrctremp := 180108;
    v_dados(v_dados.last()).vr_vllanmto := 5138.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166480;
    v_dados(v_dados.last()).vr_nrctremp := 63527;
    v_dados(v_dados.last()).vr_vllanmto := 32.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 505587;
    v_dados(v_dados.last()).vr_nrctremp := 179776;
    v_dados(v_dados.last()).vr_vllanmto := 32.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 123312;
    v_dados(v_dados.last()).vr_vllanmto := 32.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425770;
    v_dados(v_dados.last()).vr_nrctremp := 57128;
    v_dados(v_dados.last()).vr_vllanmto := 32.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 138280;
    v_dados(v_dados.last()).vr_vllanmto := 32.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 84202;
    v_dados(v_dados.last()).vr_vllanmto := 32.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 70375;
    v_dados(v_dados.last()).vr_vllanmto := 524.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 32.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 135397;
    v_dados(v_dados.last()).vr_vllanmto := 32.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 177334;
    v_dados(v_dados.last()).vr_vllanmto := 32.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 32.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 311863;
    v_dados(v_dados.last()).vr_nrctremp := 135708;
    v_dados(v_dados.last()).vr_vllanmto := 32.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128445;
    v_dados(v_dados.last()).vr_vllanmto := 31.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66940;
    v_dados(v_dados.last()).vr_nrctremp := 142854;
    v_dados(v_dados.last()).vr_vllanmto := 31.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464910;
    v_dados(v_dados.last()).vr_nrctremp := 164242;
    v_dados(v_dados.last()).vr_vllanmto := 29.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 400599;
    v_dados(v_dados.last()).vr_nrctremp := 73411;
    v_dados(v_dados.last()).vr_vllanmto := 31.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258598;
    v_dados(v_dados.last()).vr_nrctremp := 98532;
    v_dados(v_dados.last()).vr_vllanmto := 31.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := 31.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140600;
    v_dados(v_dados.last()).vr_nrctremp := 113764;
    v_dados(v_dados.last()).vr_vllanmto := 31.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91480;
    v_dados(v_dados.last()).vr_nrctremp := 143547;
    v_dados(v_dados.last()).vr_vllanmto := 31.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 154805;
    v_dados(v_dados.last()).vr_vllanmto := 31.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 148826;
    v_dados(v_dados.last()).vr_vllanmto := 31.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135810;
    v_dados(v_dados.last()).vr_nrctremp := 114621;
    v_dados(v_dados.last()).vr_vllanmto := 31.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145742;
    v_dados(v_dados.last()).vr_nrctremp := 162708;
    v_dados(v_dados.last()).vr_vllanmto := 31.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 31.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149764;
    v_dados(v_dados.last()).vr_nrctremp := 73063;
    v_dados(v_dados.last()).vr_vllanmto := 30.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 182237;
    v_dados(v_dados.last()).vr_vllanmto := 30.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166987;
    v_dados(v_dados.last()).vr_nrctremp := 63352;
    v_dados(v_dados.last()).vr_vllanmto := 30.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 130201;
    v_dados(v_dados.last()).vr_vllanmto := 30.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 112397;
    v_dados(v_dados.last()).vr_vllanmto := 30.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66699;
    v_dados(v_dados.last()).vr_nrctremp := 158790;
    v_dados(v_dados.last()).vr_vllanmto := 30.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 157608;
    v_dados(v_dados.last()).vr_vllanmto := 30.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 87679;
    v_dados(v_dados.last()).vr_vllanmto := 30.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90000;
    v_dados(v_dados.last()).vr_nrctremp := 129809;
    v_dados(v_dados.last()).vr_vllanmto := 30.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242985;
    v_dados(v_dados.last()).vr_nrctremp := 132628;
    v_dados(v_dados.last()).vr_vllanmto := 30.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107626;
    v_dados(v_dados.last()).vr_vllanmto := 30.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124282;
    v_dados(v_dados.last()).vr_vllanmto := 30.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131172;
    v_dados(v_dados.last()).vr_nrctremp := 115379;
    v_dados(v_dados.last()).vr_vllanmto := 29.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187194;
    v_dados(v_dados.last()).vr_nrctremp := 56891;
    v_dados(v_dados.last()).vr_vllanmto := 29.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 103276;
    v_dados(v_dados.last()).vr_vllanmto := 29.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214256;
    v_dados(v_dados.last()).vr_nrctremp := 180558;
    v_dados(v_dados.last()).vr_vllanmto := 29.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 117422;
    v_dados(v_dados.last()).vr_vllanmto := 29.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129899;
    v_dados(v_dados.last()).vr_vllanmto := 27.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54514;
    v_dados(v_dados.last()).vr_vllanmto := 29.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188158;
    v_dados(v_dados.last()).vr_nrctremp := 79186;
    v_dados(v_dados.last()).vr_vllanmto := 29.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316237;
    v_dados(v_dados.last()).vr_nrctremp := 77074;
    v_dados(v_dados.last()).vr_vllanmto := 29.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 70190;
    v_dados(v_dados.last()).vr_vllanmto := 920.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292060;
    v_dados(v_dados.last()).vr_nrctremp := 133164;
    v_dados(v_dados.last()).vr_vllanmto := 29.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 84402;
    v_dados(v_dados.last()).vr_vllanmto := 29.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 69400;
    v_dados(v_dados.last()).vr_nrctremp := 61857;
    v_dados(v_dados.last()).vr_vllanmto := 29.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91531;
    v_dados(v_dados.last()).vr_vllanmto := 29.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 163884;
    v_dados(v_dados.last()).vr_vllanmto := 29.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 105708;
    v_dados(v_dados.last()).vr_vllanmto := 29.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144053;
    v_dados(v_dados.last()).vr_nrctremp := 102361;
    v_dados(v_dados.last()).vr_vllanmto := 28.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 607916;
    v_dados(v_dados.last()).vr_nrctremp := 134133;
    v_dados(v_dados.last()).vr_vllanmto := 26.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163830;
    v_dados(v_dados.last()).vr_nrctremp := 181382;
    v_dados(v_dados.last()).vr_vllanmto := 28.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137855;
    v_dados(v_dados.last()).vr_nrctremp := 51945;
    v_dados(v_dados.last()).vr_vllanmto := 28.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 87115;
    v_dados(v_dados.last()).vr_vllanmto := 28.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92487;
    v_dados(v_dados.last()).vr_nrctremp := 140770;
    v_dados(v_dados.last()).vr_vllanmto := 28.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 161178;
    v_dados(v_dados.last()).vr_vllanmto := 28.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184470;
    v_dados(v_dados.last()).vr_nrctremp := 81390;
    v_dados(v_dados.last()).vr_vllanmto := 28.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315788;
    v_dados(v_dados.last()).vr_nrctremp := 79006;
    v_dados(v_dados.last()).vr_vllanmto := 28.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 122251;
    v_dados(v_dados.last()).vr_vllanmto := 28.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268240;
    v_dados(v_dados.last()).vr_nrctremp := 139413;
    v_dados(v_dados.last()).vr_vllanmto := 27.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141760;
    v_dados(v_dados.last()).vr_vllanmto := 27.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106405;
    v_dados(v_dados.last()).vr_vllanmto := 27.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 119334;
    v_dados(v_dados.last()).vr_vllanmto := 27.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 112049;
    v_dados(v_dados.last()).vr_vllanmto := 27.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144843;
    v_dados(v_dados.last()).vr_nrctremp := 56356;
    v_dados(v_dados.last()).vr_vllanmto := 27.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149039;
    v_dados(v_dados.last()).vr_nrctremp := 88625;
    v_dados(v_dados.last()).vr_vllanmto := 27.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192546;
    v_dados(v_dados.last()).vr_nrctremp := 169910;
    v_dados(v_dados.last()).vr_vllanmto := 27.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131371;
    v_dados(v_dados.last()).vr_vllanmto := 27.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 55907;
    v_dados(v_dados.last()).vr_vllanmto := 26.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137032;
    v_dados(v_dados.last()).vr_vllanmto := 26.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 55878;
    v_dados(v_dados.last()).vr_vllanmto := 26.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 128092;
    v_dados(v_dados.last()).vr_vllanmto := 26.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 101565;
    v_dados(v_dados.last()).vr_vllanmto := 26.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 103963;
    v_dados(v_dados.last()).vr_vllanmto := 26.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 83082;
    v_dados(v_dados.last()).vr_vllanmto := 26.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 153126;
    v_dados(v_dados.last()).vr_vllanmto := 26.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175455;
    v_dados(v_dados.last()).vr_nrctremp := 121287;
    v_dados(v_dados.last()).vr_vllanmto := 26.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247618;
    v_dados(v_dados.last()).vr_nrctremp := 98519;
    v_dados(v_dados.last()).vr_vllanmto := 26.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279714;
    v_dados(v_dados.last()).vr_nrctremp := 118764;
    v_dados(v_dados.last()).vr_vllanmto := 26.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150657;
    v_dados(v_dados.last()).vr_nrctremp := 99262;
    v_dados(v_dados.last()).vr_vllanmto := 26.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 147396;
    v_dados(v_dados.last()).vr_vllanmto := 26.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146397;
    v_dados(v_dados.last()).vr_vllanmto := 26.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368857;
    v_dados(v_dados.last()).vr_nrctremp := 58093;
    v_dados(v_dados.last()).vr_vllanmto := 26.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258636;
    v_dados(v_dados.last()).vr_nrctremp := 165420;
    v_dados(v_dados.last()).vr_vllanmto := 26.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107743;
    v_dados(v_dados.last()).vr_vllanmto := 25.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 630080;
    v_dados(v_dados.last()).vr_nrctremp := 157110;
    v_dados(v_dados.last()).vr_vllanmto := 25.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188123;
    v_dados(v_dados.last()).vr_nrctremp := 102857;
    v_dados(v_dados.last()).vr_vllanmto := 25.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 62996;
    v_dados(v_dados.last()).vr_vllanmto := 25.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172855;
    v_dados(v_dados.last()).vr_nrctremp := 76273;
    v_dados(v_dados.last()).vr_vllanmto := 25.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187020;
    v_dados(v_dados.last()).vr_nrctremp := 137318;
    v_dados(v_dados.last()).vr_vllanmto := 25.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191434;
    v_dados(v_dados.last()).vr_nrctremp := 164271;
    v_dados(v_dados.last()).vr_vllanmto := 25.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275298;
    v_dados(v_dados.last()).vr_nrctremp := 135529;
    v_dados(v_dados.last()).vr_vllanmto := 25.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110736;
    v_dados(v_dados.last()).vr_vllanmto := 25.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 181735;
    v_dados(v_dados.last()).vr_vllanmto := 25.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 106036;
    v_dados(v_dados.last()).vr_vllanmto := 25.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 636673;
    v_dados(v_dados.last()).vr_nrctremp := 146471;
    v_dados(v_dados.last()).vr_vllanmto := 484.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647616;
    v_dados(v_dados.last()).vr_nrctremp := 159935;
    v_dados(v_dados.last()).vr_vllanmto := 25.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112749;
    v_dados(v_dados.last()).vr_vllanmto := 25.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144843;
    v_dados(v_dados.last()).vr_nrctremp := 179507;
    v_dados(v_dados.last()).vr_vllanmto := 25.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 122595;
    v_dados(v_dados.last()).vr_vllanmto := 25.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279714;
    v_dados(v_dados.last()).vr_nrctremp := 60093;
    v_dados(v_dados.last()).vr_vllanmto := 24.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 66273;
    v_dados(v_dados.last()).vr_vllanmto := 482.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274321;
    v_dados(v_dados.last()).vr_nrctremp := 167857;
    v_dados(v_dados.last()).vr_vllanmto := 24.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186244;
    v_dados(v_dados.last()).vr_nrctremp := 136437;
    v_dados(v_dados.last()).vr_vllanmto := 24.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83095;
    v_dados(v_dados.last()).vr_vllanmto := 24.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 568350;
    v_dados(v_dados.last()).vr_nrctremp := 153429;
    v_dados(v_dados.last()).vr_vllanmto := 24.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 343196;
    v_dados(v_dados.last()).vr_nrctremp := 132444;
    v_dados(v_dados.last()).vr_vllanmto := 24.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216909;
    v_dados(v_dados.last()).vr_nrctremp := 133869;
    v_dados(v_dados.last()).vr_vllanmto := 24.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 151553;
    v_dados(v_dados.last()).vr_vllanmto := 23.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 181051;
    v_dados(v_dados.last()).vr_vllanmto := 23.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280836;
    v_dados(v_dados.last()).vr_nrctremp := 144049;
    v_dados(v_dados.last()).vr_vllanmto := 23.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329932;
    v_dados(v_dados.last()).vr_nrctremp := 74940;
    v_dados(v_dados.last()).vr_vllanmto := 23.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 121304;
    v_dados(v_dados.last()).vr_nrctremp := 99096;
    v_dados(v_dados.last()).vr_vllanmto := 23.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315788;
    v_dados(v_dados.last()).vr_nrctremp := 170807;
    v_dados(v_dados.last()).vr_vllanmto := 23.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 178572;
    v_dados(v_dados.last()).vr_vllanmto := 22.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 62992;
    v_dados(v_dados.last()).vr_vllanmto := 23.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 437832;
    v_dados(v_dados.last()).vr_nrctremp := 177937;
    v_dados(v_dados.last()).vr_vllanmto := 23.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 80719;
    v_dados(v_dados.last()).vr_vllanmto := 23.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 128007;
    v_dados(v_dados.last()).vr_vllanmto := 23.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149931;
    v_dados(v_dados.last()).vr_vllanmto := 23.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 151600;
    v_dados(v_dados.last()).vr_vllanmto := 21.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92428;
    v_dados(v_dados.last()).vr_nrctremp := 94314;
    v_dados(v_dados.last()).vr_vllanmto := 22.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 369845;
    v_dados(v_dados.last()).vr_nrctremp := 179448;
    v_dados(v_dados.last()).vr_vllanmto := 22.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541311;
    v_dados(v_dados.last()).vr_nrctremp := 179454;
    v_dados(v_dados.last()).vr_vllanmto := 22.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190047;
    v_dados(v_dados.last()).vr_nrctremp := 158758;
    v_dados(v_dados.last()).vr_vllanmto := 22.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 472611;
    v_dados(v_dados.last()).vr_nrctremp := 74772;
    v_dados(v_dados.last()).vr_vllanmto := 22.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193577;
    v_dados(v_dados.last()).vr_nrctremp := 70791;
    v_dados(v_dados.last()).vr_vllanmto := 22.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 75381;
    v_dados(v_dados.last()).vr_vllanmto := 22.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66532;
    v_dados(v_dados.last()).vr_nrctremp := 103293;
    v_dados(v_dados.last()).vr_vllanmto := 22.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 150316;
    v_dados(v_dados.last()).vr_vllanmto := 22.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149896;
    v_dados(v_dados.last()).vr_nrctremp := 118073;
    v_dados(v_dados.last()).vr_vllanmto := 525.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484067;
    v_dados(v_dados.last()).vr_nrctremp := 181993;
    v_dados(v_dados.last()).vr_vllanmto := 22.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 74878;
    v_dados(v_dados.last()).vr_vllanmto := 22.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328014;
    v_dados(v_dados.last()).vr_nrctremp := 111588;
    v_dados(v_dados.last()).vr_vllanmto := 22.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185876;
    v_dados(v_dados.last()).vr_nrctremp := 147388;
    v_dados(v_dados.last()).vr_vllanmto := 22.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 590126;
    v_dados(v_dados.last()).vr_nrctremp := 179585;
    v_dados(v_dados.last()).vr_vllanmto := 22.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169277;
    v_dados(v_dados.last()).vr_nrctremp := 82388;
    v_dados(v_dados.last()).vr_vllanmto := 22.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187372;
    v_dados(v_dados.last()).vr_nrctremp := 102721;
    v_dados(v_dados.last()).vr_vllanmto := 21.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 117419;
    v_dados(v_dados.last()).vr_vllanmto := 21.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 154072;
    v_dados(v_dados.last()).vr_vllanmto := 21.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128314;
    v_dados(v_dados.last()).vr_vllanmto := 21.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 157416;
    v_dados(v_dados.last()).vr_vllanmto := 21.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91359;
    v_dados(v_dados.last()).vr_nrctremp := 97584;
    v_dados(v_dados.last()).vr_vllanmto := 21.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186511;
    v_dados(v_dados.last()).vr_nrctremp := 90119;
    v_dados(v_dados.last()).vr_vllanmto := 21.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424218;
    v_dados(v_dados.last()).vr_nrctremp := 103005;
    v_dados(v_dados.last()).vr_vllanmto := 21.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 132748;
    v_dados(v_dados.last()).vr_vllanmto := 21.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142387;
    v_dados(v_dados.last()).vr_nrctremp := 180576;
    v_dados(v_dados.last()).vr_vllanmto := 21.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71105;
    v_dados(v_dados.last()).vr_vllanmto := 21.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 683655;
    v_dados(v_dados.last()).vr_nrctremp := 177942;
    v_dados(v_dados.last()).vr_vllanmto := 21.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614610;
    v_dados(v_dados.last()).vr_nrctremp := 136420;
    v_dados(v_dados.last()).vr_vllanmto := 20.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219312;
    v_dados(v_dados.last()).vr_nrctremp := 90673;
    v_dados(v_dados.last()).vr_vllanmto := 20.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 132287;
    v_dados(v_dados.last()).vr_vllanmto := 20.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 58256;
    v_dados(v_dados.last()).vr_vllanmto := 20.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 124814;
    v_dados(v_dados.last()).vr_vllanmto := 20.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143898;
    v_dados(v_dados.last()).vr_vllanmto := 20.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549991;
    v_dados(v_dados.last()).vr_nrctremp := 108446;
    v_dados(v_dados.last()).vr_vllanmto := 20.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 101693;
    v_dados(v_dados.last()).vr_vllanmto := 20.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148318;
    v_dados(v_dados.last()).vr_nrctremp := 107844;
    v_dados(v_dados.last()).vr_vllanmto := 20.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287296;
    v_dados(v_dados.last()).vr_nrctremp := 180065;
    v_dados(v_dados.last()).vr_vllanmto := 20.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188336;
    v_dados(v_dados.last()).vr_nrctremp := 90899;
    v_dados(v_dados.last()).vr_vllanmto := 700.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156022;
    v_dados(v_dados.last()).vr_vllanmto := 20.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 176605;
    v_dados(v_dados.last()).vr_nrctremp := 54432;
    v_dados(v_dados.last()).vr_vllanmto := 20.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188344;
    v_dados(v_dados.last()).vr_nrctremp := 82654;
    v_dados(v_dados.last()).vr_vllanmto := 20.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553905;
    v_dados(v_dados.last()).vr_nrctremp := 110020;
    v_dados(v_dados.last()).vr_vllanmto := 20.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 133375;
    v_dados(v_dados.last()).vr_vllanmto := 20.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129574;
    v_dados(v_dados.last()).vr_vllanmto := 20.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62065;
    v_dados(v_dados.last()).vr_vllanmto := 20.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163767;
    v_dados(v_dados.last()).vr_nrctremp := 87851;
    v_dados(v_dados.last()).vr_vllanmto := 20.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 167789;
    v_dados(v_dados.last()).vr_vllanmto := 20.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 166641;
    v_dados(v_dados.last()).vr_vllanmto := 20.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215937;
    v_dados(v_dados.last()).vr_nrctremp := 116906;
    v_dados(v_dados.last()).vr_vllanmto := 20.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170879;
    v_dados(v_dados.last()).vr_nrctremp := 51225;
    v_dados(v_dados.last()).vr_vllanmto := 20.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146021;
    v_dados(v_dados.last()).vr_nrctremp := 90526;
    v_dados(v_dados.last()).vr_vllanmto := 20.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 117048;
    v_dados(v_dados.last()).vr_nrctremp := 164922;
    v_dados(v_dados.last()).vr_vllanmto := 20.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 113015;
    v_dados(v_dados.last()).vr_vllanmto := 19.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 138713;
    v_dados(v_dados.last()).vr_vllanmto := 19.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100161;
    v_dados(v_dados.last()).vr_nrctremp := 56312;
    v_dados(v_dados.last()).vr_vllanmto := 19.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 124874;
    v_dados(v_dados.last()).vr_vllanmto := 19.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 167151;
    v_dados(v_dados.last()).vr_vllanmto := 19.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 168225;
    v_dados(v_dados.last()).vr_vllanmto := 19.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 142392;
    v_dados(v_dados.last()).vr_vllanmto := 19.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18180;
    v_dados(v_dados.last()).vr_nrctremp := 140475;
    v_dados(v_dados.last()).vr_vllanmto := 26.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 546780;
    v_dados(v_dados.last()).vr_nrctremp := 105989;
    v_dados(v_dados.last()).vr_vllanmto := 19.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483320;
    v_dados(v_dados.last()).vr_nrctremp := 78389;
    v_dados(v_dados.last()).vr_vllanmto := 19.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66427;
    v_dados(v_dados.last()).vr_nrctremp := 153753;
    v_dados(v_dados.last()).vr_vllanmto := 19.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42056;
    v_dados(v_dados.last()).vr_nrctremp := 129502;
    v_dados(v_dados.last()).vr_vllanmto := 19.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267414;
    v_dados(v_dados.last()).vr_nrctremp := 76198;
    v_dados(v_dados.last()).vr_vllanmto := 19.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 139562;
    v_dados(v_dados.last()).vr_vllanmto := 555.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 244953;
    v_dados(v_dados.last()).vr_nrctremp := 163634;
    v_dados(v_dados.last()).vr_vllanmto := 19.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319260;
    v_dados(v_dados.last()).vr_nrctremp := 82744;
    v_dados(v_dados.last()).vr_vllanmto := 19.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83098;
    v_dados(v_dados.last()).vr_vllanmto := 19.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105295;
    v_dados(v_dados.last()).vr_nrctremp := 109809;
    v_dados(v_dados.last()).vr_vllanmto := 19.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 304778;
    v_dados(v_dados.last()).vr_nrctremp := 106301;
    v_dados(v_dados.last()).vr_vllanmto := 19.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445347;
    v_dados(v_dados.last()).vr_nrctremp := 68188;
    v_dados(v_dados.last()).vr_vllanmto := 19.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318728;
    v_dados(v_dados.last()).vr_nrctremp := 52932;
    v_dados(v_dados.last()).vr_vllanmto := 19.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 64955;
    v_dados(v_dados.last()).vr_nrctremp := 98020;
    v_dados(v_dados.last()).vr_vllanmto := 19.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 112834;
    v_dados(v_dados.last()).vr_vllanmto := 18.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92690;
    v_dados(v_dados.last()).vr_nrctremp := 58634;
    v_dados(v_dados.last()).vr_vllanmto := 18.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 236632;
    v_dados(v_dados.last()).vr_nrctremp := 142523;
    v_dados(v_dados.last()).vr_vllanmto := 18.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 390402;
    v_dados(v_dados.last()).vr_nrctremp := 166820;
    v_dados(v_dados.last()).vr_vllanmto := 18.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92665;
    v_dados(v_dados.last()).vr_nrctremp := 59179;
    v_dados(v_dados.last()).vr_vllanmto := 17.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 110402;
    v_dados(v_dados.last()).vr_vllanmto := 18.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 76427;
    v_dados(v_dados.last()).vr_vllanmto := 18.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280585;
    v_dados(v_dados.last()).vr_nrctremp := 132320;
    v_dados(v_dados.last()).vr_vllanmto := 18.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131382;
    v_dados(v_dados.last()).vr_vllanmto := 18.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 224162;
    v_dados(v_dados.last()).vr_nrctremp := 116605;
    v_dados(v_dados.last()).vr_vllanmto := 18.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 84854;
    v_dados(v_dados.last()).vr_vllanmto := 18.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96423;
    v_dados(v_dados.last()).vr_nrctremp := 96511;
    v_dados(v_dados.last()).vr_vllanmto := 18.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 41599;
    v_dados(v_dados.last()).vr_nrctremp := 97126;
    v_dados(v_dados.last()).vr_vllanmto := 17.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207497;
    v_dados(v_dados.last()).vr_nrctremp := 160961;
    v_dados(v_dados.last()).vr_vllanmto := 17.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 116694;
    v_dados(v_dados.last()).vr_vllanmto := 17.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227900;
    v_dados(v_dados.last()).vr_nrctremp := 65953;
    v_dados(v_dados.last()).vr_vllanmto := 17.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 113424;
    v_dados(v_dados.last()).vr_vllanmto := 17.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151455;
    v_dados(v_dados.last()).vr_vllanmto := 17.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 241784;
    v_dados(v_dados.last()).vr_nrctremp := 84479;
    v_dados(v_dados.last()).vr_vllanmto := 17.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240389;
    v_dados(v_dados.last()).vr_nrctremp := 147131;
    v_dados(v_dados.last()).vr_vllanmto := 17.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103691;
    v_dados(v_dados.last()).vr_nrctremp := 96084;
    v_dados(v_dados.last()).vr_vllanmto := 17.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191833;
    v_dados(v_dados.last()).vr_nrctremp := 111117;
    v_dados(v_dados.last()).vr_vllanmto := 17.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239011;
    v_dados(v_dados.last()).vr_nrctremp := 96087;
    v_dados(v_dados.last()).vr_vllanmto := 17.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 77444;
    v_dados(v_dados.last()).vr_vllanmto := 17.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 108448;
    v_dados(v_dados.last()).vr_vllanmto := 17.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549860;
    v_dados(v_dados.last()).vr_nrctremp := 107888;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 147274;
    v_dados(v_dados.last()).vr_vllanmto := 17.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 76570;
    v_dados(v_dados.last()).vr_nrctremp := 85654;
    v_dados(v_dados.last()).vr_vllanmto := 17.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503533;
    v_dados(v_dados.last()).vr_nrctremp := 181189;
    v_dados(v_dados.last()).vr_vllanmto := 17.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108561;
    v_dados(v_dados.last()).vr_nrctremp := 172972;
    v_dados(v_dados.last()).vr_vllanmto := 17.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 105034;
    v_dados(v_dados.last()).vr_vllanmto := 17.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95400;
    v_dados(v_dados.last()).vr_nrctremp := 118820;
    v_dados(v_dados.last()).vr_vllanmto := 17.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 165366;
    v_dados(v_dados.last()).vr_vllanmto := 17.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166200;
    v_dados(v_dados.last()).vr_nrctremp := 126085;
    v_dados(v_dados.last()).vr_vllanmto := 17.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54519;
    v_dados(v_dados.last()).vr_vllanmto := 17.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92630;
    v_dados(v_dados.last()).vr_nrctremp := 182139;
    v_dados(v_dados.last()).vr_vllanmto := 17.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80361;
    v_dados(v_dados.last()).vr_vllanmto := 17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120618;
    v_dados(v_dados.last()).vr_nrctremp := 104378;
    v_dados(v_dados.last()).vr_vllanmto := 16.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368857;
    v_dados(v_dados.last()).vr_nrctremp := 141765;
    v_dados(v_dados.last()).vr_vllanmto := 16.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 109298;
    v_dados(v_dados.last()).vr_vllanmto := 1058.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 181049;
    v_dados(v_dados.last()).vr_vllanmto := 16.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 373567;
    v_dados(v_dados.last()).vr_nrctremp := 135191;
    v_dados(v_dados.last()).vr_vllanmto := 16.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 174998;
    v_dados(v_dados.last()).vr_nrctremp := 113161;
    v_dados(v_dados.last()).vr_vllanmto := 16.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 489824;
    v_dados(v_dados.last()).vr_nrctremp := 159225;
    v_dados(v_dados.last()).vr_vllanmto := 16.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83772;
    v_dados(v_dados.last()).vr_vllanmto := 16.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 96330;
    v_dados(v_dados.last()).vr_vllanmto := 16.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216305;
    v_dados(v_dados.last()).vr_nrctremp := 97595;
    v_dados(v_dados.last()).vr_vllanmto := 16.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141372;
    v_dados(v_dados.last()).vr_nrctremp := 143891;
    v_dados(v_dados.last()).vr_vllanmto := 16.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 160976;
    v_dados(v_dados.last()).vr_vllanmto := 16.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59307;
    v_dados(v_dados.last()).vr_nrctremp := 182948;
    v_dados(v_dados.last()).vr_vllanmto := 16.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549991;
    v_dados(v_dados.last()).vr_nrctremp := 117327;
    v_dados(v_dados.last()).vr_vllanmto := 16.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 126926;
    v_dados(v_dados.last()).vr_nrctremp := 57415;
    v_dados(v_dados.last()).vr_vllanmto := 16.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452360;
    v_dados(v_dados.last()).vr_nrctremp := 115139;
    v_dados(v_dados.last()).vr_vllanmto := 16.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258539;
    v_dados(v_dados.last()).vr_nrctremp := 180651;
    v_dados(v_dados.last()).vr_vllanmto := 16.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80080;
    v_dados(v_dados.last()).vr_nrctremp := 173704;
    v_dados(v_dados.last()).vr_vllanmto := 54.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148103;
    v_dados(v_dados.last()).vr_vllanmto := 16.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 128010;
    v_dados(v_dados.last()).vr_vllanmto := 16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10928;
    v_dados(v_dados.last()).vr_nrctremp := 166219;
    v_dados(v_dados.last()).vr_vllanmto := 15.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544809;
    v_dados(v_dados.last()).vr_nrctremp := 104688;
    v_dados(v_dados.last()).vr_vllanmto := 15.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 320935;
    v_dados(v_dados.last()).vr_nrctremp := 172922;
    v_dados(v_dados.last()).vr_vllanmto := 15.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 116691;
    v_dados(v_dados.last()).vr_vllanmto := 15.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140758;
    v_dados(v_dados.last()).vr_vllanmto := 15.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 111433;
    v_dados(v_dados.last()).vr_vllanmto := 15.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 605190;
    v_dados(v_dados.last()).vr_nrctremp := 132874;
    v_dados(v_dados.last()).vr_vllanmto := 15.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149764;
    v_dados(v_dados.last()).vr_nrctremp := 96325;
    v_dados(v_dados.last()).vr_vllanmto := 15.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361194;
    v_dados(v_dados.last()).vr_nrctremp := 85780;
    v_dados(v_dados.last()).vr_vllanmto := 15.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331317;
    v_dados(v_dados.last()).vr_nrctremp := 178836;
    v_dados(v_dados.last()).vr_vllanmto := 15.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 136637;
    v_dados(v_dados.last()).vr_vllanmto := 15.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 127597;
    v_dados(v_dados.last()).vr_vllanmto := 15.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 143435;
    v_dados(v_dados.last()).vr_vllanmto := 15.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319864;
    v_dados(v_dados.last()).vr_nrctremp := 91954;
    v_dados(v_dados.last()).vr_vllanmto := 15.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 28649;
    v_dados(v_dados.last()).vr_nrctremp := 133663;
    v_dados(v_dados.last()).vr_vllanmto := 15.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277568;
    v_dados(v_dados.last()).vr_nrctremp := 71879;
    v_dados(v_dados.last()).vr_vllanmto := 15.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 126586;
    v_dados(v_dados.last()).vr_nrctremp := 81747;
    v_dados(v_dados.last()).vr_vllanmto := 15.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 14.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 104920;
    v_dados(v_dados.last()).vr_vllanmto := 14.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159182;
    v_dados(v_dados.last()).vr_nrctremp := 112574;
    v_dados(v_dados.last()).vr_vllanmto := 14.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66540;
    v_dados(v_dados.last()).vr_nrctremp := 106736;
    v_dados(v_dados.last()).vr_vllanmto := 14.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 558052;
    v_dados(v_dados.last()).vr_nrctremp := 112094;
    v_dados(v_dados.last()).vr_vllanmto := 14.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135085;
    v_dados(v_dados.last()).vr_vllanmto := 14.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278157;
    v_dados(v_dados.last()).vr_nrctremp := 61458;
    v_dados(v_dados.last()).vr_vllanmto := 14.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59382;
    v_dados(v_dados.last()).vr_nrctremp := 86033;
    v_dados(v_dados.last()).vr_vllanmto := 14.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191930;
    v_dados(v_dados.last()).vr_nrctremp := 42594;
    v_dados(v_dados.last()).vr_vllanmto := 14.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215902;
    v_dados(v_dados.last()).vr_nrctremp := 98010;
    v_dados(v_dados.last()).vr_vllanmto := 14.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 70325;
    v_dados(v_dados.last()).vr_vllanmto := 14.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 635669;
    v_dados(v_dados.last()).vr_nrctremp := 146059;
    v_dados(v_dados.last()).vr_vllanmto := 14.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138711;
    v_dados(v_dados.last()).vr_nrctremp := 158857;
    v_dados(v_dados.last()).vr_vllanmto := 14.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166472;
    v_dados(v_dados.last()).vr_nrctremp := 169114;
    v_dados(v_dados.last()).vr_vllanmto := 13.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148215;
    v_dados(v_dados.last()).vr_vllanmto := 13.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161640;
    v_dados(v_dados.last()).vr_nrctremp := 136155;
    v_dados(v_dados.last()).vr_vllanmto := 13.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141054;
    v_dados(v_dados.last()).vr_nrctremp := 114755;
    v_dados(v_dados.last()).vr_vllanmto := 13.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 109603;
    v_dados(v_dados.last()).vr_vllanmto := 13.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91572;
    v_dados(v_dados.last()).vr_vllanmto := 13.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 164930;
    v_dados(v_dados.last()).vr_vllanmto := 13.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100080;
    v_dados(v_dados.last()).vr_nrctremp := 182022;
    v_dados(v_dados.last()).vr_vllanmto := 13.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 108200;
    v_dados(v_dados.last()).vr_vllanmto := 13.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360961;
    v_dados(v_dados.last()).vr_nrctremp := 84145;
    v_dados(v_dados.last()).vr_vllanmto := 13.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395773;
    v_dados(v_dados.last()).vr_nrctremp := 53179;
    v_dados(v_dados.last()).vr_vllanmto := 13.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186902;
    v_dados(v_dados.last()).vr_nrctremp := 92977;
    v_dados(v_dados.last()).vr_vllanmto := 13.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 658057;
    v_dados(v_dados.last()).vr_nrctremp := 168054;
    v_dados(v_dados.last()).vr_vllanmto := 13.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 133611;
    v_dados(v_dados.last()).vr_vllanmto := 13.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 97404;
    v_dados(v_dados.last()).vr_vllanmto := 13.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 80612;
    v_dados(v_dados.last()).vr_vllanmto := 12.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135399;
    v_dados(v_dados.last()).vr_nrctremp := 182849;
    v_dados(v_dados.last()).vr_vllanmto := 12.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 117990;
    v_dados(v_dados.last()).vr_vllanmto := 12.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 81229;
    v_dados(v_dados.last()).vr_vllanmto := 75.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107629;
    v_dados(v_dados.last()).vr_vllanmto := 12.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 132009;
    v_dados(v_dados.last()).vr_vllanmto := 1650.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382302;
    v_dados(v_dados.last()).vr_nrctremp := 68878;
    v_dados(v_dados.last()).vr_vllanmto := 12.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116166;
    v_dados(v_dados.last()).vr_vllanmto := 12.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 138689;
    v_dados(v_dados.last()).vr_vllanmto := 12.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 75913;
    v_dados(v_dados.last()).vr_vllanmto := 12.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 88480;
    v_dados(v_dados.last()).vr_nrctremp := 97562;
    v_dados(v_dados.last()).vr_vllanmto := 12.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116432;
    v_dados(v_dados.last()).vr_nrctremp := 168836;
    v_dados(v_dados.last()).vr_vllanmto := 12.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263664;
    v_dados(v_dados.last()).vr_nrctremp := 84416;
    v_dados(v_dados.last()).vr_vllanmto := 4431.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 79897;
    v_dados(v_dados.last()).vr_vllanmto := 12.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102822;
    v_dados(v_dados.last()).vr_nrctremp := 163575;
    v_dados(v_dados.last()).vr_vllanmto := 12.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135081;
    v_dados(v_dados.last()).vr_vllanmto := 12.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 50957;
    v_dados(v_dados.last()).vr_vllanmto := 11.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 96071;
    v_dados(v_dados.last()).vr_vllanmto := 11.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290246;
    v_dados(v_dados.last()).vr_nrctremp := 96871;
    v_dados(v_dados.last()).vr_vllanmto := 821.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 148322;
    v_dados(v_dados.last()).vr_vllanmto := 11.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14224259;
    v_dados(v_dados.last()).vr_nrctremp := 176904;
    v_dados(v_dados.last()).vr_vllanmto := 11.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 177469;
    v_dados(v_dados.last()).vr_vllanmto := 11.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 330248;
    v_dados(v_dados.last()).vr_nrctremp := 172256;
    v_dados(v_dados.last()).vr_vllanmto := 11.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185957;
    v_dados(v_dados.last()).vr_nrctremp := 74163;
    v_dados(v_dados.last()).vr_vllanmto := 11.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 568350;
    v_dados(v_dados.last()).vr_nrctremp := 116414;
    v_dados(v_dados.last()).vr_vllanmto := 11.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524808;
    v_dados(v_dados.last()).vr_nrctremp := 95190;
    v_dados(v_dados.last()).vr_vllanmto := 11.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184390;
    v_dados(v_dados.last()).vr_nrctremp := 59839;
    v_dados(v_dados.last()).vr_vllanmto := 11.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248355;
    v_dados(v_dados.last()).vr_nrctremp := 75999;
    v_dados(v_dados.last()).vr_vllanmto := 11.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 67072;
    v_dados(v_dados.last()).vr_vllanmto := 11.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83094;
    v_dados(v_dados.last()).vr_vllanmto := 11.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268151;
    v_dados(v_dados.last()).vr_nrctremp := 118237;
    v_dados(v_dados.last()).vr_vllanmto := 11.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288624;
    v_dados(v_dados.last()).vr_nrctremp := 155423;
    v_dados(v_dados.last()).vr_vllanmto := 11.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 109238;
    v_dados(v_dados.last()).vr_vllanmto := 11.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276464;
    v_dados(v_dados.last()).vr_nrctremp := 134609;
    v_dados(v_dados.last()).vr_vllanmto := 11.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 135957;
    v_dados(v_dados.last()).vr_vllanmto := 11.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 137047;
    v_dados(v_dados.last()).vr_vllanmto := 11.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263125;
    v_dados(v_dados.last()).vr_nrctremp := 81091;
    v_dados(v_dados.last()).vr_vllanmto := 11.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 444057;
    v_dados(v_dados.last()).vr_nrctremp := 156882;
    v_dados(v_dados.last()).vr_vllanmto := 10.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192902;
    v_dados(v_dados.last()).vr_nrctremp := 87507;
    v_dados(v_dados.last()).vr_vllanmto := 10.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 557153;
    v_dados(v_dados.last()).vr_nrctremp := 111077;
    v_dados(v_dados.last()).vr_vllanmto := 10.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185426;
    v_dados(v_dados.last()).vr_nrctremp := 86080;
    v_dados(v_dados.last()).vr_vllanmto := 10.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 106412;
    v_dados(v_dados.last()).vr_vllanmto := 10.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484326;
    v_dados(v_dados.last()).vr_nrctremp := 79098;
    v_dados(v_dados.last()).vr_vllanmto := 10.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288322;
    v_dados(v_dados.last()).vr_nrctremp := 106632;
    v_dados(v_dados.last()).vr_vllanmto := 10.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670464;
    v_dados(v_dados.last()).vr_nrctremp := 182028;
    v_dados(v_dados.last()).vr_vllanmto := 644.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183334;
    v_dados(v_dados.last()).vr_nrctremp := 64957;
    v_dados(v_dados.last()).vr_vllanmto := 10.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80740;
    v_dados(v_dados.last()).vr_vllanmto := 10.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 617482;
    v_dados(v_dados.last()).vr_nrctremp := 137775;
    v_dados(v_dados.last()).vr_vllanmto := 10.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219720;
    v_dados(v_dados.last()).vr_nrctremp := 107165;
    v_dados(v_dados.last()).vr_vllanmto := 10.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180815;
    v_dados(v_dados.last()).vr_nrctremp := 118016;
    v_dados(v_dados.last()).vr_vllanmto := 10.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 149896;
    v_dados(v_dados.last()).vr_vllanmto := 10.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 173754;
    v_dados(v_dados.last()).vr_nrctremp := 94321;
    v_dados(v_dados.last()).vr_vllanmto := 10.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22187;
    v_dados(v_dados.last()).vr_nrctremp := 149937;
    v_dados(v_dados.last()).vr_vllanmto := 10.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144096;
    v_dados(v_dados.last()).vr_nrctremp := 111301;
    v_dados(v_dados.last()).vr_vllanmto := 10.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 106756;
    v_dados(v_dados.last()).vr_vllanmto := 10.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 517399;
    v_dados(v_dados.last()).vr_nrctremp := 181024;
    v_dados(v_dados.last()).vr_vllanmto := 10.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 169358;
    v_dados(v_dados.last()).vr_vllanmto := 10;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92681;
    v_dados(v_dados.last()).vr_nrctremp := 52581;
    v_dados(v_dados.last()).vr_vllanmto := 9.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264105;
    v_dados(v_dados.last()).vr_nrctremp := 89948;
    v_dados(v_dados.last()).vr_vllanmto := 9.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185426;
    v_dados(v_dados.last()).vr_nrctremp := 112115;
    v_dados(v_dados.last()).vr_vllanmto := 9.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273821;
    v_dados(v_dados.last()).vr_nrctremp := 81164;
    v_dados(v_dados.last()).vr_vllanmto := 9.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 330345;
    v_dados(v_dados.last()).vr_nrctremp := 51729;
    v_dados(v_dados.last()).vr_vllanmto := 9.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 661686;
    v_dados(v_dados.last()).vr_nrctremp := 165541;
    v_dados(v_dados.last()).vr_vllanmto := 43.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 255661;
    v_dados(v_dados.last()).vr_nrctremp := 134250;
    v_dados(v_dados.last()).vr_vllanmto := 9.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158313;
    v_dados(v_dados.last()).vr_nrctremp := 118506;
    v_dados(v_dados.last()).vr_vllanmto := 9.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151980;
    v_dados(v_dados.last()).vr_nrctremp := 89620;
    v_dados(v_dados.last()).vr_vllanmto := 9.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528056;
    v_dados(v_dados.last()).vr_nrctremp := 96844;
    v_dados(v_dados.last()).vr_vllanmto := 9.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419834;
    v_dados(v_dados.last()).vr_nrctremp := 79091;
    v_dados(v_dados.last()).vr_vllanmto := 9.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 108966;
    v_dados(v_dados.last()).vr_vllanmto := 9.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206504;
    v_dados(v_dados.last()).vr_nrctremp := 92513;
    v_dados(v_dados.last()).vr_vllanmto := 9.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 181994;
    v_dados(v_dados.last()).vr_vllanmto := 9.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 182379;
    v_dados(v_dados.last()).vr_vllanmto := 9.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240389;
    v_dados(v_dados.last()).vr_nrctremp := 147135;
    v_dados(v_dados.last()).vr_vllanmto := 9.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 504220;
    v_dados(v_dados.last()).vr_nrctremp := 118177;
    v_dados(v_dados.last()).vr_vllanmto := 9.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169544;
    v_dados(v_dados.last()).vr_nrctremp := 107453;
    v_dados(v_dados.last()).vr_vllanmto := 9.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 147569;
    v_dados(v_dados.last()).vr_vllanmto := 9.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170119;
    v_dados(v_dados.last()).vr_nrctremp := 119673;
    v_dados(v_dados.last()).vr_vllanmto := 9.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189693;
    v_dados(v_dados.last()).vr_nrctremp := 116390;
    v_dados(v_dados.last()).vr_vllanmto := 9.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 129560;
    v_dados(v_dados.last()).vr_vllanmto := 9.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169544;
    v_dados(v_dados.last()).vr_nrctremp := 107451;
    v_dados(v_dados.last()).vr_vllanmto := 9.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172979;
    v_dados(v_dados.last()).vr_nrctremp := 70406;
    v_dados(v_dados.last()).vr_vllanmto := 8.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 271276;
    v_dados(v_dados.last()).vr_nrctremp := 53665;
    v_dados(v_dados.last()).vr_vllanmto := 8.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 110103;
    v_dados(v_dados.last()).vr_vllanmto := 576.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 241164;
    v_dados(v_dados.last()).vr_nrctremp := 86674;
    v_dados(v_dados.last()).vr_vllanmto := 8.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131375;
    v_dados(v_dados.last()).vr_vllanmto := 8.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325791;
    v_dados(v_dados.last()).vr_nrctremp := 134294;
    v_dados(v_dados.last()).vr_vllanmto := 8.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246662;
    v_dados(v_dados.last()).vr_nrctremp := 149547;
    v_dados(v_dados.last()).vr_vllanmto := 8.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31682;
    v_dados(v_dados.last()).vr_nrctremp := 91212;
    v_dados(v_dados.last()).vr_vllanmto := 8.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 123170;
    v_dados(v_dados.last()).vr_nrctremp := 53817;
    v_dados(v_dados.last()).vr_vllanmto := 8.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 70702;
    v_dados(v_dados.last()).vr_vllanmto := 8.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163767;
    v_dados(v_dados.last()).vr_nrctremp := 72294;
    v_dados(v_dados.last()).vr_vllanmto := 8.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 223859;
    v_dados(v_dados.last()).vr_nrctremp := 135640;
    v_dados(v_dados.last()).vr_vllanmto := 8.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206679;
    v_dados(v_dados.last()).vr_nrctremp := 111871;
    v_dados(v_dados.last()).vr_vllanmto := 8.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524808;
    v_dados(v_dados.last()).vr_nrctremp := 130581;
    v_dados(v_dados.last()).vr_vllanmto := 8.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100161;
    v_dados(v_dados.last()).vr_nrctremp := 56319;
    v_dados(v_dados.last()).vr_vllanmto := 8.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163171;
    v_dados(v_dados.last()).vr_nrctremp := 179517;
    v_dados(v_dados.last()).vr_vllanmto := 8.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 125024;
    v_dados(v_dados.last()).vr_nrctremp := 135648;
    v_dados(v_dados.last()).vr_vllanmto := 8.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67040;
    v_dados(v_dados.last()).vr_nrctremp := 58621;
    v_dados(v_dados.last()).vr_vllanmto := 8.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 174998;
    v_dados(v_dados.last()).vr_nrctremp := 113163;
    v_dados(v_dados.last()).vr_vllanmto := 8.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 499072;
    v_dados(v_dados.last()).vr_nrctremp := 124981;
    v_dados(v_dados.last()).vr_vllanmto := 30.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 61407;
    v_dados(v_dados.last()).vr_vllanmto := .54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419206;
    v_dados(v_dados.last()).vr_nrctremp := 85355;
    v_dados(v_dados.last()).vr_vllanmto := 7.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 515566;
    v_dados(v_dados.last()).vr_nrctremp := 165443;
    v_dados(v_dados.last()).vr_vllanmto := 7.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 76961;
    v_dados(v_dados.last()).vr_nrctremp := 93710;
    v_dados(v_dados.last()).vr_vllanmto := 7.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 225282;
    v_dados(v_dados.last()).vr_nrctremp := 182349;
    v_dados(v_dados.last()).vr_vllanmto := 7.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334936;
    v_dados(v_dados.last()).vr_nrctremp := 139875;
    v_dados(v_dados.last()).vr_vllanmto := 7.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 111158;
    v_dados(v_dados.last()).vr_vllanmto := 7.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 113484;
    v_dados(v_dados.last()).vr_nrctremp := 152624;
    v_dados(v_dados.last()).vr_vllanmto := 7.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156680;
    v_dados(v_dados.last()).vr_nrctremp := 179391;
    v_dados(v_dados.last()).vr_vllanmto := 7.65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 111600;
    v_dados(v_dados.last()).vr_nrctremp := 155688;
    v_dados(v_dados.last()).vr_vllanmto := 7.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 95564;
    v_dados(v_dados.last()).vr_vllanmto := 7.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 96427;
    v_dados(v_dados.last()).vr_vllanmto := 7.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 77509;
    v_dados(v_dados.last()).vr_vllanmto := 7.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 150826;
    v_dados(v_dados.last()).vr_vllanmto := 7.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 408042;
    v_dados(v_dados.last()).vr_nrctremp := 74837;
    v_dados(v_dados.last()).vr_vllanmto := 7.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 335959;
    v_dados(v_dados.last()).vr_nrctremp := 131060;
    v_dados(v_dados.last()).vr_vllanmto := 7.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293822;
    v_dados(v_dados.last()).vr_nrctremp := 148091;
    v_dados(v_dados.last()).vr_vllanmto := 7.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 211036;
    v_dados(v_dados.last()).vr_nrctremp := 156753;
    v_dados(v_dados.last()).vr_vllanmto := 60.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 226327;
    v_dados(v_dados.last()).vr_nrctremp := 151939;
    v_dados(v_dados.last()).vr_vllanmto := 7.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 173312;
    v_dados(v_dados.last()).vr_nrctremp := 131007;
    v_dados(v_dados.last()).vr_vllanmto := 7.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 122276;
    v_dados(v_dados.last()).vr_vllanmto := 7.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 130202;
    v_dados(v_dados.last()).vr_vllanmto := 6.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 320528;
    v_dados(v_dados.last()).vr_nrctremp := 58210;
    v_dados(v_dados.last()).vr_vllanmto := 6.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 428515;
    v_dados(v_dados.last()).vr_nrctremp := 57696;
    v_dados(v_dados.last()).vr_vllanmto := 6.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328790;
    v_dados(v_dados.last()).vr_nrctremp := 142203;
    v_dados(v_dados.last()).vr_vllanmto := 6.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153141;
    v_dados(v_dados.last()).vr_nrctremp := 57245;
    v_dados(v_dados.last()).vr_vllanmto := 6.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110737;
    v_dados(v_dados.last()).vr_vllanmto := 6.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450294;
    v_dados(v_dados.last()).vr_nrctremp := 135394;
    v_dados(v_dados.last()).vr_vllanmto := 6.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180815;
    v_dados(v_dados.last()).vr_nrctremp := 118018;
    v_dados(v_dados.last()).vr_vllanmto := 6.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138711;
    v_dados(v_dados.last()).vr_nrctremp := 84334;
    v_dados(v_dados.last()).vr_vllanmto := 278.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 110594;
    v_dados(v_dados.last()).vr_vllanmto := 6.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142611;
    v_dados(v_dados.last()).vr_nrctremp := 111563;
    v_dados(v_dados.last()).vr_vllanmto := .28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 375160;
    v_dados(v_dados.last()).vr_nrctremp := 85045;
    v_dados(v_dados.last()).vr_vllanmto := 6.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 134641;
    v_dados(v_dados.last()).vr_vllanmto := 6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 61230;
    v_dados(v_dados.last()).vr_vllanmto := 5.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 535125;
    v_dados(v_dados.last()).vr_nrctremp := 105753;
    v_dados(v_dados.last()).vr_vllanmto := 5.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 372714;
    v_dados(v_dados.last()).vr_nrctremp := 156007;
    v_dados(v_dados.last()).vr_vllanmto := .27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131822;
    v_dados(v_dados.last()).vr_nrctremp := 179860;
    v_dados(v_dados.last()).vr_vllanmto := 5.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189154;
    v_dados(v_dados.last()).vr_nrctremp := 91914;
    v_dados(v_dados.last()).vr_vllanmto := 5.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284564;
    v_dados(v_dados.last()).vr_nrctremp := 181819;
    v_dados(v_dados.last()).vr_vllanmto := 5.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 104600;
    v_dados(v_dados.last()).vr_vllanmto := 5.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62054;
    v_dados(v_dados.last()).vr_vllanmto := 5.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158305;
    v_dados(v_dados.last()).vr_nrctremp := 57412;
    v_dados(v_dados.last()).vr_vllanmto := 5.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 236632;
    v_dados(v_dados.last()).vr_nrctremp := 172605;
    v_dados(v_dados.last()).vr_vllanmto := 15.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614610;
    v_dados(v_dados.last()).vr_nrctremp := 141308;
    v_dados(v_dados.last()).vr_vllanmto := 5.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 181844;
    v_dados(v_dados.last()).vr_vllanmto := 5.54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 64450;
    v_dados(v_dados.last()).vr_vllanmto := 5.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 107679;
    v_dados(v_dados.last()).vr_vllanmto := 5.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202657;
    v_dados(v_dados.last()).vr_nrctremp := 163091;
    v_dados(v_dados.last()).vr_vllanmto := 5.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266450;
    v_dados(v_dados.last()).vr_nrctremp := 87972;
    v_dados(v_dados.last()).vr_vllanmto := 5.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26654;
    v_dados(v_dados.last()).vr_nrctremp := 108177;
    v_dados(v_dados.last()).vr_vllanmto := 5.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187020;
    v_dados(v_dados.last()).vr_nrctremp := 135536;
    v_dados(v_dados.last()).vr_vllanmto := 5.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 200395;
    v_dados(v_dados.last()).vr_nrctremp := 165875;
    v_dados(v_dados.last()).vr_vllanmto := 5.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 147397;
    v_dados(v_dados.last()).vr_vllanmto := 5.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 515566;
    v_dados(v_dados.last()).vr_nrctremp := 165441;
    v_dados(v_dados.last()).vr_vllanmto := 5.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159859;
    v_dados(v_dados.last()).vr_nrctremp := 57494;
    v_dados(v_dados.last()).vr_vllanmto := 5.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154601;
    v_dados(v_dados.last()).vr_nrctremp := 58949;
    v_dados(v_dados.last()).vr_vllanmto := 4.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 78969;
    v_dados(v_dados.last()).vr_vllanmto := 2392.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116163;
    v_dados(v_dados.last()).vr_vllanmto := 4.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 238244;
    v_dados(v_dados.last()).vr_nrctremp := 142675;
    v_dados(v_dados.last()).vr_vllanmto := 4.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213365;
    v_dados(v_dados.last()).vr_nrctremp := 125577;
    v_dados(v_dados.last()).vr_vllanmto := 115.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218847;
    v_dados(v_dados.last()).vr_nrctremp := 182279;
    v_dados(v_dados.last()).vr_vllanmto := 4.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 571628;
    v_dados(v_dados.last()).vr_nrctremp := 118254;
    v_dados(v_dados.last()).vr_vllanmto := 4.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524069;
    v_dados(v_dados.last()).vr_nrctremp := 94728;
    v_dados(v_dados.last()).vr_vllanmto := 4.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 99961;
    v_dados(v_dados.last()).vr_vllanmto := 4.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 112050;
    v_dados(v_dados.last()).vr_vllanmto := 4.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := 10.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 105430;
    v_dados(v_dados.last()).vr_vllanmto := 4.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215902;
    v_dados(v_dados.last()).vr_nrctremp := 72392;
    v_dados(v_dados.last()).vr_vllanmto := 4.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 228079;
    v_dados(v_dados.last()).vr_nrctremp := 54753;
    v_dados(v_dados.last()).vr_vllanmto := 4.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 60113;
    v_dados(v_dados.last()).vr_vllanmto := 4.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 178633;
    v_dados(v_dados.last()).vr_vllanmto := 641.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 119113;
    v_dados(v_dados.last()).vr_vllanmto := 4.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 78313;
    v_dados(v_dados.last()).vr_vllanmto := 4.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 93695;
    v_dados(v_dados.last()).vr_vllanmto := 28529.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 558060;
    v_dados(v_dados.last()).vr_nrctremp := 118081;
    v_dados(v_dados.last()).vr_vllanmto := 42.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 86142;
    v_dados(v_dados.last()).vr_nrctremp := 181677;
    v_dados(v_dados.last()).vr_vllanmto := 4.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316776;
    v_dados(v_dados.last()).vr_nrctremp := 78219;
    v_dados(v_dados.last()).vr_vllanmto := 3.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66532;
    v_dados(v_dados.last()).vr_nrctremp := 149494;
    v_dados(v_dados.last()).vr_vllanmto := 3.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153605;
    v_dados(v_dados.last()).vr_nrctremp := 113811;
    v_dados(v_dados.last()).vr_vllanmto := .16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 3.81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 60113;
    v_dados(v_dados.last()).vr_vllanmto := 3.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160601;
    v_dados(v_dados.last()).vr_nrctremp := 103332;
    v_dados(v_dados.last()).vr_vllanmto := 3.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 135478;
    v_dados(v_dados.last()).vr_vllanmto := 3.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129860;
    v_dados(v_dados.last()).vr_nrctremp := 155283;
    v_dados(v_dados.last()).vr_vllanmto := 3.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641278;
    v_dados(v_dados.last()).vr_nrctremp := 182052;
    v_dados(v_dados.last()).vr_vllanmto := 3.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316776;
    v_dados(v_dados.last()).vr_nrctremp := 78219;
    v_dados(v_dados.last()).vr_vllanmto := 3.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273872;
    v_dados(v_dados.last()).vr_nrctremp := 90163;
    v_dados(v_dados.last()).vr_vllanmto := 3.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 339067;
    v_dados(v_dados.last()).vr_nrctremp := 67555;
    v_dados(v_dados.last()).vr_vllanmto := 3.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 178729;
    v_dados(v_dados.last()).vr_vllanmto := 520;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170470;
    v_dados(v_dados.last()).vr_nrctremp := 182831;
    v_dados(v_dados.last()).vr_vllanmto := 3.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151980;
    v_dados(v_dados.last()).vr_nrctremp := 155930;
    v_dados(v_dados.last()).vr_vllanmto := 3.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 92615;
    v_dados(v_dados.last()).vr_vllanmto := 3.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 96319;
    v_dados(v_dados.last()).vr_vllanmto := 3.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179043;
    v_dados(v_dados.last()).vr_nrctremp := 117292;
    v_dados(v_dados.last()).vr_vllanmto := 3.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 180638;
    v_dados(v_dados.last()).vr_vllanmto := 3.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 217255;
    v_dados(v_dados.last()).vr_nrctremp := 118322;
    v_dados(v_dados.last()).vr_vllanmto := 2.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 409561;
    v_dados(v_dados.last()).vr_nrctremp := 106191;
    v_dados(v_dados.last()).vr_vllanmto := 35.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 204889;
    v_dados(v_dados.last()).vr_nrctremp := 109927;
    v_dados(v_dados.last()).vr_vllanmto := 29.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129011;
    v_dados(v_dados.last()).vr_nrctremp := 143855;
    v_dados(v_dados.last()).vr_vllanmto := 2.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 443948;
    v_dados(v_dados.last()).vr_nrctremp := 62978;
    v_dados(v_dados.last()).vr_vllanmto := 1.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25518;
    v_dados(v_dados.last()).vr_nrctremp := 111541;
    v_dados(v_dados.last()).vr_vllanmto := 26.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170356;
    v_dados(v_dados.last()).vr_nrctremp := 65618;
    v_dados(v_dados.last()).vr_vllanmto := 2.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 212849;
    v_dados(v_dados.last()).vr_nrctremp := 99450;
    v_dados(v_dados.last()).vr_vllanmto := 2.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 16373;
    v_dados(v_dados.last()).vr_nrctremp := 107060;
    v_dados(v_dados.last()).vr_vllanmto := 42.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 88267;
    v_dados(v_dados.last()).vr_vllanmto := 2.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 244937;
    v_dados(v_dados.last()).vr_nrctremp := 106384;
    v_dados(v_dados.last()).vr_vllanmto := 2.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 178839;
    v_dados(v_dados.last()).vr_vllanmto := 102.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 468380;
    v_dados(v_dados.last()).vr_nrctremp := 72484;
    v_dados(v_dados.last()).vr_vllanmto := 1.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 243477;
    v_dados(v_dados.last()).vr_nrctremp := 68277;
    v_dados(v_dados.last()).vr_vllanmto := 1.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 88267;
    v_dados(v_dados.last()).vr_vllanmto := 1.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 468380;
    v_dados(v_dados.last()).vr_nrctremp := 72484;
    v_dados(v_dados.last()).vr_vllanmto := 1.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171107;
    v_dados(v_dados.last()).vr_nrctremp := 183151;
    v_dados(v_dados.last()).vr_vllanmto := 1.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334928;
    v_dados(v_dados.last()).vr_nrctremp := 97293;
    v_dados(v_dados.last()).vr_vllanmto := 1.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284220;
    v_dados(v_dados.last()).vr_nrctremp := 102835;
    v_dados(v_dados.last()).vr_vllanmto := 1.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240990;
    v_dados(v_dados.last()).vr_nrctremp := 125145;
    v_dados(v_dados.last()).vr_vllanmto := 1.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103349;
    v_dados(v_dados.last()).vr_nrctremp := 100759;
    v_dados(v_dados.last()).vr_vllanmto := 1.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181722;
    v_dados(v_dados.last()).vr_nrctremp := 61221;
    v_dados(v_dados.last()).vr_vllanmto := 1.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 1.09;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467995;
    v_dados(v_dados.last()).vr_nrctremp := 140932;
    v_dados(v_dados.last()).vr_vllanmto := 1.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := .92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288640;
    v_dados(v_dados.last()).vr_nrctremp := 55992;
    v_dados(v_dados.last()).vr_vllanmto := .85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 80612;
    v_dados(v_dados.last()).vr_vllanmto := .73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 66402;
    v_dados(v_dados.last()).vr_vllanmto := .68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167894;
    v_dados(v_dados.last()).vr_nrctremp := 104385;
    v_dados(v_dados.last()).vr_vllanmto := 1.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163716;
    v_dados(v_dados.last()).vr_nrctremp := 81143;
    v_dados(v_dados.last()).vr_vllanmto := 435.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179043;
    v_dados(v_dados.last()).vr_nrctremp := 117292;
    v_dados(v_dados.last()).vr_vllanmto := .48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 91932;
    v_dados(v_dados.last()).vr_vllanmto := .27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14958;
    v_dados(v_dados.last()).vr_nrctremp := 118515;
    v_dados(v_dados.last()).vr_vllanmto := 435.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := .01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180130;
    v_dados(v_dados.last()).vr_nrctremp := 82659;
    v_dados(v_dados.last()).vr_vllanmto := .31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146625;
    v_dados(v_dados.last()).vr_nrctremp := 96582;
    v_dados(v_dados.last()).vr_vllanmto := .5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218847;
    v_dados(v_dados.last()).vr_nrctremp := 111374;
    v_dados(v_dados.last()).vr_vllanmto := 36.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207195;
    v_dados(v_dados.last()).vr_nrctremp := 56872;
    v_dados(v_dados.last()).vr_vllanmto := 1.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207195;
    v_dados(v_dados.last()).vr_nrctremp := 58537;
    v_dados(v_dados.last()).vr_vllanmto := 1.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198030;
    v_dados(v_dados.last()).vr_nrctremp := 74436;
    v_dados(v_dados.last()).vr_vllanmto := 1.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153265;
    v_dados(v_dados.last()).vr_nrctremp := 64028;
    v_dados(v_dados.last()).vr_vllanmto := 1.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186139;
    v_dados(v_dados.last()).vr_nrctremp := 79508;
    v_dados(v_dados.last()).vr_vllanmto := 2.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421545;
    v_dados(v_dados.last()).vr_nrctremp := 101019;
    v_dados(v_dados.last()).vr_vllanmto := 2.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 2.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 101150;
    v_dados(v_dados.last()).vr_vllanmto := 3.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419834;
    v_dados(v_dados.last()).vr_nrctremp := 55980;
    v_dados(v_dados.last()).vr_vllanmto := 4.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 74654;
    v_dados(v_dados.last()).vr_vllanmto := 5.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188344;
    v_dados(v_dados.last()).vr_nrctremp := 82650;
    v_dados(v_dados.last()).vr_vllanmto := 6.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 75102;
    v_dados(v_dados.last()).vr_vllanmto := 7.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 122406;
    v_dados(v_dados.last()).vr_vllanmto := 1244.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 709859;
    v_dados(v_dados.last()).vr_nrctremp := 71494;
    v_dados(v_dados.last()).vr_vllanmto := 7.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 486256;
    v_dados(v_dados.last()).vr_nrctremp := 80327;
    v_dados(v_dados.last()).vr_vllanmto := 7.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152960;
    v_dados(v_dados.last()).vr_nrctremp := 75349;
    v_dados(v_dados.last()).vr_vllanmto := 7.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 138297;
    v_dados(v_dados.last()).vr_vllanmto := 84.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 159595;
    v_dados(v_dados.last()).vr_vllanmto := 8.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 105102;
    v_dados(v_dados.last()).vr_vllanmto := 8.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426610;
    v_dados(v_dados.last()).vr_nrctremp := 80116;
    v_dados(v_dados.last()).vr_vllanmto := 9.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91243;
    v_dados(v_dados.last()).vr_nrctremp := 111299;
    v_dados(v_dados.last()).vr_vllanmto := 9.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 388181;
    v_dados(v_dados.last()).vr_nrctremp := 143312;
    v_dados(v_dados.last()).vr_vllanmto := 9.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 491381;
    v_dados(v_dados.last()).vr_nrctremp := 87910;
    v_dados(v_dados.last()).vr_vllanmto := 6827.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140660;
    v_dados(v_dados.last()).vr_nrctremp := 116725;
    v_dados(v_dados.last()).vr_vllanmto := 10.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185981;
    v_dados(v_dados.last()).vr_nrctremp := 61901;
    v_dados(v_dados.last()).vr_vllanmto := 11.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94889;
    v_dados(v_dados.last()).vr_nrctremp := 84839;
    v_dados(v_dados.last()).vr_vllanmto := 11.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315834;
    v_dados(v_dados.last()).vr_nrctremp := 118574;
    v_dados(v_dados.last()).vr_vllanmto := 72.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526118;
    v_dados(v_dados.last()).vr_nrctremp := 96688;
    v_dados(v_dados.last()).vr_vllanmto := 11.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 476668;
    v_dados(v_dados.last()).vr_nrctremp := 131321;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 221546;
    v_dados(v_dados.last()).vr_nrctremp := 135155;
    v_dados(v_dados.last()).vr_vllanmto := 12.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202665;
    v_dados(v_dados.last()).vr_nrctremp := 123568;
    v_dados(v_dados.last()).vr_vllanmto := 13.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186244;
    v_dados(v_dados.last()).vr_nrctremp := 58233;
    v_dados(v_dados.last()).vr_vllanmto := 13.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303348;
    v_dados(v_dados.last()).vr_nrctremp := 75300;
    v_dados(v_dados.last()).vr_vllanmto := 1870.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207497;
    v_dados(v_dados.last()).vr_nrctremp := 51194;
    v_dados(v_dados.last()).vr_vllanmto := 16.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 7722;
    v_dados(v_dados.last()).vr_nrctremp := 134120;
    v_dados(v_dados.last()).vr_vllanmto := 17.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 17.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350672;
    v_dados(v_dados.last()).vr_nrctremp := 80334;
    v_dados(v_dados.last()).vr_vllanmto := 18.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170097;
    v_dados(v_dados.last()).vr_nrctremp := 84009;
    v_dados(v_dados.last()).vr_vllanmto := 20.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94692;
    v_dados(v_dados.last()).vr_nrctremp := 79826;
    v_dados(v_dados.last()).vr_vllanmto := 20.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187917;
    v_dados(v_dados.last()).vr_nrctremp := 87916;
    v_dados(v_dados.last()).vr_vllanmto := 20.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 86810;
    v_dados(v_dados.last()).vr_vllanmto := 21.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 209066;
    v_dados(v_dados.last()).vr_nrctremp := 56508;
    v_dados(v_dados.last()).vr_vllanmto := 21.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 95415;
    v_dados(v_dados.last()).vr_vllanmto := 22.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 223913;
    v_dados(v_dados.last()).vr_nrctremp := 57290;
    v_dados(v_dados.last()).vr_vllanmto := 22.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278742;
    v_dados(v_dados.last()).vr_nrctremp := 83075;
    v_dados(v_dados.last()).vr_vllanmto := 22.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 77895;
    v_dados(v_dados.last()).vr_nrctremp := 75192;
    v_dados(v_dados.last()).vr_vllanmto := 23.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 94244;
    v_dados(v_dados.last()).vr_vllanmto := 23.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 64692;
    v_dados(v_dados.last()).vr_vllanmto := 24.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 112941;
    v_dados(v_dados.last()).vr_nrctremp := 112912;
    v_dados(v_dados.last()).vr_vllanmto := 24.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124982;
    v_dados(v_dados.last()).vr_nrctremp := 71546;
    v_dados(v_dados.last()).vr_vllanmto := 26.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161284;
    v_dados(v_dados.last()).vr_nrctremp := 84769;
    v_dados(v_dados.last()).vr_vllanmto := 27.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545805;
    v_dados(v_dados.last()).vr_nrctremp := 105319;
    v_dados(v_dados.last()).vr_vllanmto := 28.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452211;
    v_dados(v_dados.last()).vr_nrctremp := 66716;
    v_dados(v_dados.last()).vr_vllanmto := 29.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93564;
    v_dados(v_dados.last()).vr_nrctremp := 91623;
    v_dados(v_dados.last()).vr_vllanmto := 30.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185957;
    v_dados(v_dados.last()).vr_nrctremp := 64228;
    v_dados(v_dados.last()).vr_vllanmto := 32.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 104655;
    v_dados(v_dados.last()).vr_vllanmto := 32.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95532;
    v_dados(v_dados.last()).vr_nrctremp := 68569;
    v_dados(v_dados.last()).vr_vllanmto := 33.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 63749;
    v_dados(v_dados.last()).vr_vllanmto := 36.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331317;
    v_dados(v_dados.last()).vr_nrctremp := 123439;
    v_dados(v_dados.last()).vr_vllanmto := 36.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145947;
    v_dados(v_dados.last()).vr_nrctremp := 56091;
    v_dados(v_dados.last()).vr_vllanmto := 37.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 369845;
    v_dados(v_dados.last()).vr_nrctremp := 99051;
    v_dados(v_dados.last()).vr_vllanmto := 38.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 62268;
    v_dados(v_dados.last()).vr_vllanmto := 39.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395838;
    v_dados(v_dados.last()).vr_nrctremp := 53229;
    v_dados(v_dados.last()).vr_vllanmto := 10701.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 46458;
    v_dados(v_dados.last()).vr_vllanmto := 46.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142611;
    v_dados(v_dados.last()).vr_nrctremp := 86099;
    v_dados(v_dados.last()).vr_vllanmto := 46.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218065;
    v_dados(v_dados.last()).vr_nrctremp := 59859;
    v_dados(v_dados.last()).vr_vllanmto := 102.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 222348;
    v_dados(v_dados.last()).vr_nrctremp := 84303;
    v_dados(v_dados.last()).vr_vllanmto := 52.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 98825;
    v_dados(v_dados.last()).vr_vllanmto := 57.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 7145;
    v_dados(v_dados.last()).vr_nrctremp := 54314;
    v_dados(v_dados.last()).vr_vllanmto := 136.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175633;
    v_dados(v_dados.last()).vr_nrctremp := 104048;
    v_dados(v_dados.last()).vr_vllanmto := 61.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278238;
    v_dados(v_dados.last()).vr_nrctremp := 65409;
    v_dados(v_dados.last()).vr_vllanmto := 67.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109380;
    v_dados(v_dados.last()).vr_nrctremp := 54347;
    v_dados(v_dados.last()).vr_vllanmto := 74.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 517399;
    v_dados(v_dados.last()).vr_nrctremp := 149458;
    v_dados(v_dados.last()).vr_vllanmto := 81.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279072;
    v_dados(v_dados.last()).vr_nrctremp := 111148;
    v_dados(v_dados.last()).vr_vllanmto := 1045.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160954;
    v_dados(v_dados.last()).vr_nrctremp := 55722;
    v_dados(v_dados.last()).vr_vllanmto := 83.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 85.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149322;
    v_dados(v_dados.last()).vr_nrctremp := 59821;
    v_dados(v_dados.last()).vr_vllanmto := 88.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344222;
    v_dados(v_dados.last()).vr_nrctremp := 83334;
    v_dados(v_dados.last()).vr_vllanmto := 92.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170453;
    v_dados(v_dados.last()).vr_nrctremp := 59887;
    v_dados(v_dados.last()).vr_vllanmto := 93.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87963;
    v_dados(v_dados.last()).vr_nrctremp := 64353;
    v_dados(v_dados.last()).vr_vllanmto := 120.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161799;
    v_dados(v_dados.last()).vr_nrctremp := 97735;
    v_dados(v_dados.last()).vr_vllanmto := 125.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 99782;
    v_dados(v_dados.last()).vr_vllanmto := 136.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268135;
    v_dados(v_dados.last()).vr_nrctremp := 70210;
    v_dados(v_dados.last()).vr_vllanmto := 142.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186805;
    v_dados(v_dados.last()).vr_nrctremp := 63844;
    v_dados(v_dados.last()).vr_vllanmto := 150.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 151578;
    v_dados(v_dados.last()).vr_vllanmto := 173.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286540;
    v_dados(v_dados.last()).vr_nrctremp := 95381;
    v_dados(v_dados.last()).vr_vllanmto := 174.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 505587;
    v_dados(v_dados.last()).vr_nrctremp := 150021;
    v_dados(v_dados.last()).vr_vllanmto := 202.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116475;
    v_dados(v_dados.last()).vr_nrctremp := 61043;
    v_dados(v_dados.last()).vr_vllanmto := 262.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286540;
    v_dados(v_dados.last()).vr_nrctremp := 94456;
    v_dados(v_dados.last()).vr_vllanmto := 278.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 69880;
    v_dados(v_dados.last()).vr_vllanmto := 308.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 149556;
    v_dados(v_dados.last()).vr_vllanmto := 360.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170470;
    v_dados(v_dados.last()).vr_nrctremp := 51123;
    v_dados(v_dados.last()).vr_vllanmto := 369.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 91363;
    v_dados(v_dados.last()).vr_vllanmto := 408.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287296;
    v_dados(v_dados.last()).vr_nrctremp := 161268;
    v_dados(v_dados.last()).vr_vllanmto := 476.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 165530;
    v_dados(v_dados.last()).vr_vllanmto := 645.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163171;
    v_dados(v_dados.last()).vr_nrctremp := 59718;
    v_dados(v_dados.last()).vr_vllanmto := 657.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 152499;
    v_dados(v_dados.last()).vr_vllanmto := 844.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68616;
    v_dados(v_dados.last()).vr_nrctremp := 154124;
    v_dados(v_dados.last()).vr_vllanmto := 945.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59307;
    v_dados(v_dados.last()).vr_nrctremp := 51158;
    v_dados(v_dados.last()).vr_vllanmto := 1413.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 165522;
    v_dados(v_dados.last()).vr_vllanmto := 1721.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 80878;
    v_dados(v_dados.last()).vr_vllanmto := 1838.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214256;
    v_dados(v_dados.last()).vr_nrctremp := 106138;
    v_dados(v_dados.last()).vr_vllanmto := 1849.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181617;
    v_dados(v_dados.last()).vr_nrctremp := 119678;
    v_dados(v_dados.last()).vr_vllanmto := 1922.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323080;
    v_dados(v_dados.last()).vr_nrctremp := 114134;
    v_dados(v_dados.last()).vr_vllanmto := 2820.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 124495;
    v_dados(v_dados.last()).vr_vllanmto := 3119.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214256;
    v_dados(v_dados.last()).vr_nrctremp := 131040;
    v_dados(v_dados.last()).vr_vllanmto := 3259.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148164;
    v_dados(v_dados.last()).vr_nrctremp := 54351;
    v_dados(v_dados.last()).vr_vllanmto := 2168.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 91362;
    v_dados(v_dados.last()).vr_vllanmto := 3966.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163830;
    v_dados(v_dados.last()).vr_nrctremp := 141332;
    v_dados(v_dados.last()).vr_vllanmto := 3974.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 177881;
    v_dados(v_dados.last()).vr_nrctremp := 87268;
    v_dados(v_dados.last()).vr_vllanmto := 4765.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294691;
    v_dados(v_dados.last()).vr_nrctremp := 133825;
    v_dados(v_dados.last()).vr_vllanmto := 5976;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 79155;
    v_dados(v_dados.last()).vr_vllanmto := 9397.87;
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
