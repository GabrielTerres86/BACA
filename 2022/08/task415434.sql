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
    v_dados(v_dados.last()).vr_nrdconta := 10827200;
    v_dados(v_dados.last()).vr_nrctremp := 3008250;
    v_dados(v_dados.last()).vr_vllanmto := 91.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13011600;
    v_dados(v_dados.last()).vr_nrctremp := 5349520;
    v_dados(v_dados.last()).vr_vllanmto := 33.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1705660;
    v_dados(v_dados.last()).vr_nrctremp := 4310541;
    v_dados(v_dados.last()).vr_vllanmto := 87.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2099195;
    v_dados(v_dados.last()).vr_nrctremp := 2883655;
    v_dados(v_dados.last()).vr_vllanmto := 242.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 45.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2909421;
    v_dados(v_dados.last()).vr_nrctremp := 4055454;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 181.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3026450;
    v_dados(v_dados.last()).vr_nrctremp := 4642781;
    v_dados(v_dados.last()).vr_vllanmto := 36.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 131.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 69.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3521109;
    v_dados(v_dados.last()).vr_nrctremp := 5592146;
    v_dados(v_dados.last()).vr_vllanmto := 21.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3791670;
    v_dados(v_dados.last()).vr_nrctremp := 2955168;
    v_dados(v_dados.last()).vr_vllanmto := 151.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4038142;
    v_dados(v_dados.last()).vr_nrctremp := 5108831;
    v_dados(v_dados.last()).vr_vllanmto := 67.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037550;
    v_dados(v_dados.last()).vr_nrctremp := 2158838;
    v_dados(v_dados.last()).vr_vllanmto := 187.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6587216;
    v_dados(v_dados.last()).vr_nrctremp := 5309033;
    v_dados(v_dados.last()).vr_vllanmto := 23.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6683045;
    v_dados(v_dados.last()).vr_nrctremp := 3919366;
    v_dados(v_dados.last()).vr_vllanmto := 179.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6928110;
    v_dados(v_dados.last()).vr_nrctremp := 3158672;
    v_dados(v_dados.last()).vr_vllanmto := 94.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7178565;
    v_dados(v_dados.last()).vr_nrctremp := 4556663;
    v_dados(v_dados.last()).vr_vllanmto := 226.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7187068;
    v_dados(v_dados.last()).vr_nrctremp := 4810669;
    v_dados(v_dados.last()).vr_vllanmto := 116.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 2855130;
    v_dados(v_dados.last()).vr_vllanmto := 27.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7310595;
    v_dados(v_dados.last()).vr_nrctremp := 5146936;
    v_dados(v_dados.last()).vr_vllanmto := 47.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7374763;
    v_dados(v_dados.last()).vr_nrctremp := 4178604;
    v_dados(v_dados.last()).vr_vllanmto := 33.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7434928;
    v_dados(v_dados.last()).vr_nrctremp := 2955176;
    v_dados(v_dados.last()).vr_vllanmto := 66.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7519796;
    v_dados(v_dados.last()).vr_nrctremp := 2955918;
    v_dados(v_dados.last()).vr_vllanmto := 22.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7521537;
    v_dados(v_dados.last()).vr_nrctremp := 2955842;
    v_dados(v_dados.last()).vr_vllanmto := 99.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7882564;
    v_dados(v_dados.last()).vr_nrctremp := 2955931;
    v_dados(v_dados.last()).vr_vllanmto := 116.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8033498;
    v_dados(v_dados.last()).vr_nrctremp := 4606131;
    v_dados(v_dados.last()).vr_vllanmto := 513.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8043124;
    v_dados(v_dados.last()).vr_nrctremp := 3024875;
    v_dados(v_dados.last()).vr_vllanmto := 1745.6;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8060266;
    v_dados(v_dados.last()).vr_nrctremp := 4800878;
    v_dados(v_dados.last()).vr_vllanmto := 46.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8171645;
    v_dados(v_dados.last()).vr_nrctremp := 4644755;
    v_dados(v_dados.last()).vr_vllanmto := 61.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8177589;
    v_dados(v_dados.last()).vr_nrctremp := 3837514;
    v_dados(v_dados.last()).vr_vllanmto := 89.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8276412;
    v_dados(v_dados.last()).vr_nrctremp := 2956155;
    v_dados(v_dados.last()).vr_vllanmto := 55.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8311170;
    v_dados(v_dados.last()).vr_nrctremp := 5356236;
    v_dados(v_dados.last()).vr_vllanmto := 34.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 63.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8496293;
    v_dados(v_dados.last()).vr_nrctremp := 4694140;
    v_dados(v_dados.last()).vr_vllanmto := 97.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 372.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8713529;
    v_dados(v_dados.last()).vr_nrctremp := 2661058;
    v_dados(v_dados.last()).vr_vllanmto := 57.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8810079;
    v_dados(v_dados.last()).vr_nrctremp := 2955393;
    v_dados(v_dados.last()).vr_vllanmto := 324.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8837813;
    v_dados(v_dados.last()).vr_nrctremp := 2955566;
    v_dados(v_dados.last()).vr_vllanmto := 224.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8907315;
    v_dados(v_dados.last()).vr_nrctremp := 3627786;
    v_dados(v_dados.last()).vr_vllanmto := 52.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9158790;
    v_dados(v_dados.last()).vr_nrctremp := 3072259;
    v_dados(v_dados.last()).vr_vllanmto := 63.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9199420;
    v_dados(v_dados.last()).vr_nrctremp := 4699390;
    v_dados(v_dados.last()).vr_vllanmto := 26.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9210750;
    v_dados(v_dados.last()).vr_nrctremp := 4338371;
    v_dados(v_dados.last()).vr_vllanmto := 100.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9563571;
    v_dados(v_dados.last()).vr_nrctremp := 2956027;
    v_dados(v_dados.last()).vr_vllanmto := 1008.13;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9659293;
    v_dados(v_dados.last()).vr_nrctremp := 2955761;
    v_dados(v_dados.last()).vr_vllanmto := 70.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9683097;
    v_dados(v_dados.last()).vr_nrctremp := 2955793;
    v_dados(v_dados.last()).vr_vllanmto := 54.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 27.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 61.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := 32.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065903;
    v_dados(v_dados.last()).vr_nrctremp := 4529120;
    v_dados(v_dados.last()).vr_vllanmto := 32.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10077928;
    v_dados(v_dados.last()).vr_nrctremp := 5159124;
    v_dados(v_dados.last()).vr_vllanmto := 48.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10092366;
    v_dados(v_dados.last()).vr_nrctremp := 4521572;
    v_dados(v_dados.last()).vr_vllanmto := 20.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10140425;
    v_dados(v_dados.last()).vr_nrctremp := 3852530;
    v_dados(v_dados.last()).vr_vllanmto := 71.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10179569;
    v_dados(v_dados.last()).vr_nrctremp := 2967816;
    v_dados(v_dados.last()).vr_vllanmto := 161.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10206345;
    v_dados(v_dados.last()).vr_nrctremp := 4035306;
    v_dados(v_dados.last()).vr_vllanmto := 33.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10226745;
    v_dados(v_dados.last()).vr_nrctremp := 4440559;
    v_dados(v_dados.last()).vr_vllanmto := 42.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 33.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10400354;
    v_dados(v_dados.last()).vr_nrctremp := 5541382;
    v_dados(v_dados.last()).vr_vllanmto := 5330.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10424393;
    v_dados(v_dados.last()).vr_nrctremp := 5501295;
    v_dados(v_dados.last()).vr_vllanmto := 22.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 154.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10534083;
    v_dados(v_dados.last()).vr_nrctremp := 4745410;
    v_dados(v_dados.last()).vr_vllanmto := 39.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 84.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10640622;
    v_dados(v_dados.last()).vr_nrctremp := 4784340;
    v_dados(v_dados.last()).vr_vllanmto := 29.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10654445;
    v_dados(v_dados.last()).vr_nrctremp := 3046625;
    v_dados(v_dados.last()).vr_vllanmto := 152.14;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10663452;
    v_dados(v_dados.last()).vr_nrctremp := 5158755;
    v_dados(v_dados.last()).vr_vllanmto := 91.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3088171;
    v_dados(v_dados.last()).vr_vllanmto := 40.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10745319;
    v_dados(v_dados.last()).vr_nrctremp := 2955382;
    v_dados(v_dados.last()).vr_vllanmto := 2222.6;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5216299;
    v_dados(v_dados.last()).vr_vllanmto := 32.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10885471;
    v_dados(v_dados.last()).vr_nrctremp := 4712416;
    v_dados(v_dados.last()).vr_vllanmto := 83.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10940650;
    v_dados(v_dados.last()).vr_nrctremp := 4639145;
    v_dados(v_dados.last()).vr_vllanmto := 68.96;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10961887;
    v_dados(v_dados.last()).vr_nrctremp := 5622318;
    v_dados(v_dados.last()).vr_vllanmto := 20.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11044039;
    v_dados(v_dados.last()).vr_nrctremp := 4344288;
    v_dados(v_dados.last()).vr_vllanmto := 75.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11093293;
    v_dados(v_dados.last()).vr_nrctremp := 3646338;
    v_dados(v_dados.last()).vr_vllanmto := 38.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11191945;
    v_dados(v_dados.last()).vr_nrctremp := 4887457;
    v_dados(v_dados.last()).vr_vllanmto := 54.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 2732832;
    v_dados(v_dados.last()).vr_vllanmto := 52.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11207574;
    v_dados(v_dados.last()).vr_nrctremp := 2639416;
    v_dados(v_dados.last()).vr_vllanmto := 74.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11218142;
    v_dados(v_dados.last()).vr_nrctremp := 3732464;
    v_dados(v_dados.last()).vr_vllanmto := 29.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 149.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11369248;
    v_dados(v_dados.last()).vr_nrctremp := 3542693;
    v_dados(v_dados.last()).vr_vllanmto := 45.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11505184;
    v_dados(v_dados.last()).vr_nrctremp := 4486388;
    v_dados(v_dados.last()).vr_vllanmto := 291.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 93.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 127.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712643;
    v_dados(v_dados.last()).vr_nrctremp := 3098270;
    v_dados(v_dados.last()).vr_vllanmto := 114.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11766522;
    v_dados(v_dados.last()).vr_nrctremp := 2988271;
    v_dados(v_dados.last()).vr_vllanmto := 222.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11779608;
    v_dados(v_dados.last()).vr_nrctremp := 2979926;
    v_dados(v_dados.last()).vr_vllanmto := 70.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11785837;
    v_dados(v_dados.last()).vr_nrctremp := 4974493;
    v_dados(v_dados.last()).vr_vllanmto := 28.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11807113;
    v_dados(v_dados.last()).vr_nrctremp := 3252824;
    v_dados(v_dados.last()).vr_vllanmto := 108.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11921005;
    v_dados(v_dados.last()).vr_nrctremp := 4170514;
    v_dados(v_dados.last()).vr_vllanmto := 33.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573117;
    v_dados(v_dados.last()).vr_vllanmto := 31.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3430704;
    v_dados(v_dados.last()).vr_vllanmto := 59.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421230;
    v_dados(v_dados.last()).vr_vllanmto := 64.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3231886;
    v_dados(v_dados.last()).vr_vllanmto := 94.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12103721;
    v_dados(v_dados.last()).vr_nrctremp := 3289323;
    v_dados(v_dados.last()).vr_vllanmto := 47.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12113743;
    v_dados(v_dados.last()).vr_nrctremp := 4221205;
    v_dados(v_dados.last()).vr_vllanmto := 44.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 125.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 3504420;
    v_dados(v_dados.last()).vr_vllanmto := 20.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12305804;
    v_dados(v_dados.last()).vr_nrctremp := 3656154;
    v_dados(v_dados.last()).vr_vllanmto := 34.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12316628;
    v_dados(v_dados.last()).vr_nrctremp := 3510982;
    v_dados(v_dados.last()).vr_vllanmto := 33.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12364690;
    v_dados(v_dados.last()).vr_nrctremp := 3572209;
    v_dados(v_dados.last()).vr_vllanmto := 57.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389080;
    v_dados(v_dados.last()).vr_nrctremp := 3584084;
    v_dados(v_dados.last()).vr_vllanmto := 37.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12422320;
    v_dados(v_dados.last()).vr_nrctremp := 3615395;
    v_dados(v_dados.last()).vr_vllanmto := 40.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425737;
    v_dados(v_dados.last()).vr_nrctremp := 3860454;
    v_dados(v_dados.last()).vr_vllanmto := 117.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12462888;
    v_dados(v_dados.last()).vr_nrctremp := 4022402;
    v_dados(v_dados.last()).vr_vllanmto := 41.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12474444;
    v_dados(v_dados.last()).vr_nrctremp := 4592182;
    v_dados(v_dados.last()).vr_vllanmto := 34.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475165;
    v_dados(v_dados.last()).vr_nrctremp := 3675184;
    v_dados(v_dados.last()).vr_vllanmto := 25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695197;
    v_dados(v_dados.last()).vr_vllanmto := 34.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 37.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 3726006;
    v_dados(v_dados.last()).vr_vllanmto := 47.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 102.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12543004;
    v_dados(v_dados.last()).vr_nrctremp := 4182794;
    v_dados(v_dados.last()).vr_vllanmto := 28.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12548650;
    v_dados(v_dados.last()).vr_nrctremp := 3753649;
    v_dados(v_dados.last()).vr_vllanmto := 70.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 3795640;
    v_dados(v_dados.last()).vr_vllanmto := 47.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12582565;
    v_dados(v_dados.last()).vr_nrctremp := 3986201;
    v_dados(v_dados.last()).vr_vllanmto := 79.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 3808261;
    v_dados(v_dados.last()).vr_vllanmto := 32.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12594750;
    v_dados(v_dados.last()).vr_nrctremp := 3807129;
    v_dados(v_dados.last()).vr_vllanmto := 84.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595373;
    v_dados(v_dados.last()).vr_nrctremp := 4753507;
    v_dados(v_dados.last()).vr_vllanmto := 27.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617008;
    v_dados(v_dados.last()).vr_nrctremp := 3827456;
    v_dados(v_dados.last()).vr_vllanmto := 48.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12620491;
    v_dados(v_dados.last()).vr_nrctremp := 3830907;
    v_dados(v_dados.last()).vr_vllanmto := 43.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637106;
    v_dados(v_dados.last()).vr_nrctremp := 3868680;
    v_dados(v_dados.last()).vr_vllanmto := 32.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12651443;
    v_dados(v_dados.last()).vr_nrctremp := 4950509;
    v_dados(v_dados.last()).vr_vllanmto := 24.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877832;
    v_dados(v_dados.last()).vr_vllanmto := 29.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 3897149;
    v_dados(v_dados.last()).vr_vllanmto := 60.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939478;
    v_dados(v_dados.last()).vr_vllanmto := 32.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4038250;
    v_dados(v_dados.last()).vr_vllanmto := 98.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739090;
    v_dados(v_dados.last()).vr_nrctremp := 4102671;
    v_dados(v_dados.last()).vr_vllanmto := 91.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4024341;
    v_dados(v_dados.last()).vr_vllanmto := 31.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760102;
    v_dados(v_dados.last()).vr_nrctremp := 3965764;
    v_dados(v_dados.last()).vr_vllanmto := 38.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 43.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817678;
    v_dados(v_dados.last()).vr_nrctremp := 4256682;
    v_dados(v_dados.last()).vr_vllanmto := 44.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12949353;
    v_dados(v_dados.last()).vr_nrctremp := 4148318;
    v_dados(v_dados.last()).vr_vllanmto := 29.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12950750;
    v_dados(v_dados.last()).vr_nrctremp := 4224701;
    v_dados(v_dados.last()).vr_vllanmto := 23.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 35.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12964077;
    v_dados(v_dados.last()).vr_nrctremp := 5318470;
    v_dados(v_dados.last()).vr_vllanmto := 350.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13006703;
    v_dados(v_dados.last()).vr_nrctremp := 4696585;
    v_dados(v_dados.last()).vr_vllanmto := 48.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028847;
    v_dados(v_dados.last()).vr_nrctremp := 4256265;
    v_dados(v_dados.last()).vr_vllanmto := 29.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4201717;
    v_dados(v_dados.last()).vr_vllanmto := 24.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4267714;
    v_dados(v_dados.last()).vr_vllanmto := 22.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124684;
    v_dados(v_dados.last()).vr_nrctremp := 4695113;
    v_dados(v_dados.last()).vr_vllanmto := 4590.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124684;
    v_dados(v_dados.last()).vr_nrctremp := 5319672;
    v_dados(v_dados.last()).vr_vllanmto := 698.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13132504;
    v_dados(v_dados.last()).vr_nrctremp := 4346910;
    v_dados(v_dados.last()).vr_vllanmto := 24.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 29.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13145088;
    v_dados(v_dados.last()).vr_nrctremp := 4430603;
    v_dados(v_dados.last()).vr_vllanmto := 22.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13155997;
    v_dados(v_dados.last()).vr_nrctremp := 4701450;
    v_dados(v_dados.last()).vr_vllanmto := 84.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13177630;
    v_dados(v_dados.last()).vr_nrctremp := 4428083;
    v_dados(v_dados.last()).vr_vllanmto := 21.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13197967;
    v_dados(v_dados.last()).vr_nrctremp := 4536802;
    v_dados(v_dados.last()).vr_vllanmto := 21.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13202502;
    v_dados(v_dados.last()).vr_nrctremp := 4330143;
    v_dados(v_dados.last()).vr_vllanmto := 24.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209248;
    v_dados(v_dados.last()).vr_nrctremp := 4499591;
    v_dados(v_dados.last()).vr_vllanmto := 31.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4378452;
    v_dados(v_dados.last()).vr_vllanmto := 27.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 29.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13344048;
    v_dados(v_dados.last()).vr_nrctremp := 4462768;
    v_dados(v_dados.last()).vr_vllanmto := 51.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13681192;
    v_dados(v_dados.last()).vr_nrctremp := 5436358;
    v_dados(v_dados.last()).vr_vllanmto := 23.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13763890;
    v_dados(v_dados.last()).vr_nrctremp := 4739175;
    v_dados(v_dados.last()).vr_vllanmto := 22.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80012248;
    v_dados(v_dados.last()).vr_nrctremp := 4068844;
    v_dados(v_dados.last()).vr_vllanmto := 23.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101089;
    v_dados(v_dados.last()).vr_nrctremp := 3549323;
    v_dados(v_dados.last()).vr_vllanmto := 62.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80277829;
    v_dados(v_dados.last()).vr_nrctremp := 3087767;
    v_dados(v_dados.last()).vr_vllanmto := 70.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80337074;
    v_dados(v_dados.last()).vr_nrctremp := 2955519;
    v_dados(v_dados.last()).vr_vllanmto := 57.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80340873;
    v_dados(v_dados.last()).vr_nrctremp := 2955797;
    v_dados(v_dados.last()).vr_vllanmto := 344.76;
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
