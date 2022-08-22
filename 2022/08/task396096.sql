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
    v_dados(v_dados.last()).vr_nrdconta := 8664528;
    v_dados(v_dados.last()).vr_nrctremp := 1860294;
    v_dados(v_dados.last()).vr_vllanmto := 46.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8664668;
    v_dados(v_dados.last()).vr_nrctremp := 1881934;
    v_dados(v_dados.last()).vr_vllanmto := 70.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8513384;
    v_dados(v_dados.last()).vr_nrctremp := 1882819;
    v_dados(v_dados.last()).vr_vllanmto := 16.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093159;
    v_dados(v_dados.last()).vr_nrctremp := 1886421;
    v_dados(v_dados.last()).vr_vllanmto := 263.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098258;
    v_dados(v_dados.last()).vr_nrctremp := 1892259;
    v_dados(v_dados.last()).vr_vllanmto := 248.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80431135;
    v_dados(v_dados.last()).vr_nrctremp := 1901589;
    v_dados(v_dados.last()).vr_vllanmto := 125.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 65.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8142335;
    v_dados(v_dados.last()).vr_nrctremp := 1951712;
    v_dados(v_dados.last()).vr_vllanmto := 82.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190945;
    v_dados(v_dados.last()).vr_nrctremp := 1956430;
    v_dados(v_dados.last()).vr_vllanmto := 63.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2604116;
    v_dados(v_dados.last()).vr_nrctremp := 1956725;
    v_dados(v_dados.last()).vr_vllanmto := 28.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7613466;
    v_dados(v_dados.last()).vr_nrctremp := 1979043;
    v_dados(v_dados.last()).vr_vllanmto := 78.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10609377;
    v_dados(v_dados.last()).vr_nrctremp := 2005092;
    v_dados(v_dados.last()).vr_vllanmto := 122.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80419461;
    v_dados(v_dados.last()).vr_nrctremp := 2005566;
    v_dados(v_dados.last()).vr_vllanmto := 90.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8290440;
    v_dados(v_dados.last()).vr_nrctremp := 2011067;
    v_dados(v_dados.last()).vr_vllanmto := 74.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2023895;
    v_dados(v_dados.last()).vr_vllanmto := 82.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11109742;
    v_dados(v_dados.last()).vr_nrctremp := 2028302;
    v_dados(v_dados.last()).vr_vllanmto := 111.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80147194;
    v_dados(v_dados.last()).vr_nrctremp := 2040841;
    v_dados(v_dados.last()).vr_vllanmto := 13.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8467595;
    v_dados(v_dados.last()).vr_nrctremp := 2041966;
    v_dados(v_dados.last()).vr_vllanmto := 44.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80241247;
    v_dados(v_dados.last()).vr_nrctremp := 2046910;
    v_dados(v_dados.last()).vr_vllanmto := 33.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8518904;
    v_dados(v_dados.last()).vr_nrctremp := 2057865;
    v_dados(v_dados.last()).vr_vllanmto := 81.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80367780;
    v_dados(v_dados.last()).vr_nrctremp := 2077526;
    v_dados(v_dados.last()).vr_vllanmto := 42.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193081;
    v_dados(v_dados.last()).vr_nrctremp := 2102720;
    v_dados(v_dados.last()).vr_vllanmto := 34.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194460;
    v_dados(v_dados.last()).vr_nrctremp := 2114224;
    v_dados(v_dados.last()).vr_vllanmto := 32.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10349898;
    v_dados(v_dados.last()).vr_nrctremp := 2118569;
    v_dados(v_dados.last()).vr_vllanmto := 59.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10234225;
    v_dados(v_dados.last()).vr_nrctremp := 2123037;
    v_dados(v_dados.last()).vr_vllanmto := 200.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194711;
    v_dados(v_dados.last()).vr_nrctremp := 2142422;
    v_dados(v_dados.last()).vr_vllanmto := 34.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80091288;
    v_dados(v_dados.last()).vr_nrctremp := 2145249;
    v_dados(v_dados.last()).vr_vllanmto := 52.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9547479;
    v_dados(v_dados.last()).vr_nrctremp := 2155460;
    v_dados(v_dados.last()).vr_vllanmto := 15.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037550;
    v_dados(v_dados.last()).vr_nrctremp := 2158838;
    v_dados(v_dados.last()).vr_vllanmto := 224.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80060242;
    v_dados(v_dados.last()).vr_nrctremp := 2214162;
    v_dados(v_dados.last()).vr_vllanmto := 84.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533179;
    v_dados(v_dados.last()).vr_nrctremp := 2439337;
    v_dados(v_dados.last()).vr_vllanmto := 28.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10776109;
    v_dados(v_dados.last()).vr_nrctremp := 2474174;
    v_dados(v_dados.last()).vr_vllanmto := 10.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9833307;
    v_dados(v_dados.last()).vr_nrctremp := 2498174;
    v_dados(v_dados.last()).vr_vllanmto := 10.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7637349;
    v_dados(v_dados.last()).vr_nrctremp := 2507514;
    v_dados(v_dados.last()).vr_vllanmto := 1.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7669437;
    v_dados(v_dados.last()).vr_nrctremp := 2507640;
    v_dados(v_dados.last()).vr_vllanmto := 20.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11338148;
    v_dados(v_dados.last()).vr_nrctremp := 2527169;
    v_dados(v_dados.last()).vr_vllanmto := 16.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4050061;
    v_dados(v_dados.last()).vr_nrctremp := 2595397;
    v_dados(v_dados.last()).vr_vllanmto := 347.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11207574;
    v_dados(v_dados.last()).vr_nrctremp := 2639416;
    v_dados(v_dados.last()).vr_vllanmto := 74.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7464525;
    v_dados(v_dados.last()).vr_nrctremp := 2642158;
    v_dados(v_dados.last()).vr_vllanmto := 67.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7449348;
    v_dados(v_dados.last()).vr_nrctremp := 2655988;
    v_dados(v_dados.last()).vr_vllanmto := 40.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8713529;
    v_dados(v_dados.last()).vr_nrctremp := 2661058;
    v_dados(v_dados.last()).vr_vllanmto := 21.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10777113;
    v_dados(v_dados.last()).vr_nrctremp := 2711935;
    v_dados(v_dados.last()).vr_vllanmto := 36.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80176674;
    v_dados(v_dados.last()).vr_nrctremp := 2818556;
    v_dados(v_dados.last()).vr_vllanmto := 87.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9877916;
    v_dados(v_dados.last()).vr_nrctremp := 2835102;
    v_dados(v_dados.last()).vr_vllanmto := 8.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2099195;
    v_dados(v_dados.last()).vr_nrctremp := 2883655;
    v_dados(v_dados.last()).vr_vllanmto := 172.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 647012;
    v_dados(v_dados.last()).vr_nrctremp := 2893007;
    v_dados(v_dados.last()).vr_vllanmto := 141.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3711625;
    v_dados(v_dados.last()).vr_nrctremp := 2909597;
    v_dados(v_dados.last()).vr_vllanmto := 26.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 72.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10245537;
    v_dados(v_dados.last()).vr_nrctremp := 2952113;
    v_dados(v_dados.last()).vr_vllanmto := 21.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6819346;
    v_dados(v_dados.last()).vr_nrctremp := 2955100;
    v_dados(v_dados.last()).vr_vllanmto := 66.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10074929;
    v_dados(v_dados.last()).vr_nrctremp := 2955103;
    v_dados(v_dados.last()).vr_vllanmto := 24.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2079836;
    v_dados(v_dados.last()).vr_nrctremp := 2955119;
    v_dados(v_dados.last()).vr_vllanmto := 12.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3791670;
    v_dados(v_dados.last()).vr_nrctremp := 2955168;
    v_dados(v_dados.last()).vr_vllanmto := 26.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7434928;
    v_dados(v_dados.last()).vr_nrctremp := 2955176;
    v_dados(v_dados.last()).vr_vllanmto := 33.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7448708;
    v_dados(v_dados.last()).vr_nrctremp := 2955184;
    v_dados(v_dados.last()).vr_vllanmto := 70.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8294615;
    v_dados(v_dados.last()).vr_nrctremp := 2955246;
    v_dados(v_dados.last()).vr_vllanmto := 40.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10403655;
    v_dados(v_dados.last()).vr_nrctremp := 2955266;
    v_dados(v_dados.last()).vr_vllanmto := 30.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101062;
    v_dados(v_dados.last()).vr_nrctremp := 2955278;
    v_dados(v_dados.last()).vr_vllanmto := 71.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7653700;
    v_dados(v_dados.last()).vr_nrctremp := 2955281;
    v_dados(v_dados.last()).vr_vllanmto := 32.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7652771;
    v_dados(v_dados.last()).vr_nrctremp := 2955284;
    v_dados(v_dados.last()).vr_vllanmto := 12.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9323511;
    v_dados(v_dados.last()).vr_nrctremp := 2955322;
    v_dados(v_dados.last()).vr_vllanmto := 38.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7813317;
    v_dados(v_dados.last()).vr_nrctremp := 2955328;
    v_dados(v_dados.last()).vr_vllanmto := 24.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8519552;
    v_dados(v_dados.last()).vr_nrctremp := 2955346;
    v_dados(v_dados.last()).vr_vllanmto := 11.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 120.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8810079;
    v_dados(v_dados.last()).vr_nrctremp := 2955393;
    v_dados(v_dados.last()).vr_vllanmto := 62.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10771808;
    v_dados(v_dados.last()).vr_nrctremp := 2955410;
    v_dados(v_dados.last()).vr_vllanmto := 36.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10772081;
    v_dados(v_dados.last()).vr_nrctremp := 2955434;
    v_dados(v_dados.last()).vr_vllanmto := 13.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8811679;
    v_dados(v_dados.last()).vr_nrctremp := 2955449;
    v_dados(v_dados.last()).vr_vllanmto := 87.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476988;
    v_dados(v_dados.last()).vr_nrctremp := 2955465;
    v_dados(v_dados.last()).vr_vllanmto := 21.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80337074;
    v_dados(v_dados.last()).vr_nrctremp := 2955519;
    v_dados(v_dados.last()).vr_vllanmto := 61.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10567925;
    v_dados(v_dados.last()).vr_nrctremp := 2955546;
    v_dados(v_dados.last()).vr_vllanmto := 59.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8837813;
    v_dados(v_dados.last()).vr_nrctremp := 2955566;
    v_dados(v_dados.last()).vr_vllanmto := 278.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80324347;
    v_dados(v_dados.last()).vr_nrctremp := 2955594;
    v_dados(v_dados.last()).vr_vllanmto := 24.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10032487;
    v_dados(v_dados.last()).vr_nrctremp := 2955607;
    v_dados(v_dados.last()).vr_vllanmto := 18.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80358179;
    v_dados(v_dados.last()).vr_nrctremp := 2955616;
    v_dados(v_dados.last()).vr_vllanmto := 83.66;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098592;
    v_dados(v_dados.last()).vr_nrctremp := 2955632;
    v_dados(v_dados.last()).vr_vllanmto := 161.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9415130;
    v_dados(v_dados.last()).vr_nrctremp := 2955637;
    v_dados(v_dados.last()).vr_vllanmto := 126.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9258116;
    v_dados(v_dados.last()).vr_nrctremp := 2955646;
    v_dados(v_dados.last()).vr_vllanmto := 29.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8791317;
    v_dados(v_dados.last()).vr_nrctremp := 2955664;
    v_dados(v_dados.last()).vr_vllanmto := 14.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7886560;
    v_dados(v_dados.last()).vr_nrctremp := 2955666;
    v_dados(v_dados.last()).vr_vllanmto := 29.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8463140;
    v_dados(v_dados.last()).vr_nrctremp := 2955667;
    v_dados(v_dados.last()).vr_vllanmto := 31.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9663274;
    v_dados(v_dados.last()).vr_nrctremp := 2955693;
    v_dados(v_dados.last()).vr_vllanmto := 22.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2955709;
    v_dados(v_dados.last()).vr_vllanmto := 329.92;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10673369;
    v_dados(v_dados.last()).vr_nrctremp := 2955710;
    v_dados(v_dados.last()).vr_vllanmto := 2.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9316841;
    v_dados(v_dados.last()).vr_nrctremp := 2955712;
    v_dados(v_dados.last()).vr_vllanmto := 7.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9659293;
    v_dados(v_dados.last()).vr_nrctremp := 2955761;
    v_dados(v_dados.last()).vr_vllanmto := 31.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6334423;
    v_dados(v_dados.last()).vr_nrctremp := 2955764;
    v_dados(v_dados.last()).vr_vllanmto := 22.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9683097;
    v_dados(v_dados.last()).vr_nrctremp := 2955793;
    v_dados(v_dados.last()).vr_vllanmto := 68.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80340873;
    v_dados(v_dados.last()).vr_nrctremp := 2955797;
    v_dados(v_dados.last()).vr_vllanmto := 173.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8082308;
    v_dados(v_dados.last()).vr_nrctremp := 2955798;
    v_dados(v_dados.last()).vr_vllanmto := 119.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7466528;
    v_dados(v_dados.last()).vr_nrctremp := 2955837;
    v_dados(v_dados.last()).vr_vllanmto := 39.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9191046;
    v_dados(v_dados.last()).vr_nrctremp := 2955838;
    v_dados(v_dados.last()).vr_vllanmto := 16.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7521537;
    v_dados(v_dados.last()).vr_nrctremp := 2955842;
    v_dados(v_dados.last()).vr_vllanmto := 32.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80068685;
    v_dados(v_dados.last()).vr_nrctremp := 2955843;
    v_dados(v_dados.last()).vr_vllanmto := 299.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 83.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4087763;
    v_dados(v_dados.last()).vr_nrctremp := 2955861;
    v_dados(v_dados.last()).vr_vllanmto := 108.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10846166;
    v_dados(v_dados.last()).vr_nrctremp := 2955881;
    v_dados(v_dados.last()).vr_vllanmto := 65.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9200380;
    v_dados(v_dados.last()).vr_nrctremp := 2955890;
    v_dados(v_dados.last()).vr_vllanmto := 35.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7519796;
    v_dados(v_dados.last()).vr_nrctremp := 2955918;
    v_dados(v_dados.last()).vr_vllanmto := 10.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9554726;
    v_dados(v_dados.last()).vr_nrctremp := 2955927;
    v_dados(v_dados.last()).vr_vllanmto := 117.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7882564;
    v_dados(v_dados.last()).vr_nrctremp := 2955931;
    v_dados(v_dados.last()).vr_vllanmto := 43.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80002390;
    v_dados(v_dados.last()).vr_nrctremp := 2955977;
    v_dados(v_dados.last()).vr_vllanmto := 19.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9563571;
    v_dados(v_dados.last()).vr_nrctremp := 2956027;
    v_dados(v_dados.last()).vr_vllanmto := 5196.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9808299;
    v_dados(v_dados.last()).vr_nrctremp := 2956029;
    v_dados(v_dados.last()).vr_vllanmto := 67.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80214118;
    v_dados(v_dados.last()).vr_nrctremp := 2956035;
    v_dados(v_dados.last()).vr_vllanmto := 4786.69;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80337643;
    v_dados(v_dados.last()).vr_nrctremp := 2956078;
    v_dados(v_dados.last()).vr_vllanmto := 10.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80004067;
    v_dados(v_dados.last()).vr_nrctremp := 2956092;
    v_dados(v_dados.last()).vr_vllanmto := 12.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80336302;
    v_dados(v_dados.last()).vr_nrctremp := 2956098;
    v_dados(v_dados.last()).vr_vllanmto := 35.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80176720;
    v_dados(v_dados.last()).vr_nrctremp := 2956136;
    v_dados(v_dados.last()).vr_vllanmto := 28.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4061209;
    v_dados(v_dados.last()).vr_nrctremp := 2956139;
    v_dados(v_dados.last()).vr_vllanmto := .88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356703;
    v_dados(v_dados.last()).vr_nrctremp := 2956154;
    v_dados(v_dados.last()).vr_vllanmto := 14.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8276412;
    v_dados(v_dados.last()).vr_nrctremp := 2956155;
    v_dados(v_dados.last()).vr_vllanmto := 9.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80438792;
    v_dados(v_dados.last()).vr_nrctremp := 2956201;
    v_dados(v_dados.last()).vr_vllanmto := 112.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093663;
    v_dados(v_dados.last()).vr_nrctremp := 2956255;
    v_dados(v_dados.last()).vr_vllanmto := 303.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9233962;
    v_dados(v_dados.last()).vr_nrctremp := 2958985;
    v_dados(v_dados.last()).vr_vllanmto := 52.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11751169;
    v_dados(v_dados.last()).vr_nrctremp := 2964955;
    v_dados(v_dados.last()).vr_vllanmto := 184.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10179569;
    v_dados(v_dados.last()).vr_nrctremp := 2967816;
    v_dados(v_dados.last()).vr_vllanmto := 68.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80417590;
    v_dados(v_dados.last()).vr_nrctremp := 2967847;
    v_dados(v_dados.last()).vr_vllanmto := 38.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9070079;
    v_dados(v_dados.last()).vr_nrctremp := 2972625;
    v_dados(v_dados.last()).vr_vllanmto := 29.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11752092;
    v_dados(v_dados.last()).vr_nrctremp := 2979438;
    v_dados(v_dados.last()).vr_vllanmto := 74.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11779608;
    v_dados(v_dados.last()).vr_nrctremp := 2979926;
    v_dados(v_dados.last()).vr_vllanmto := 192.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8679177;
    v_dados(v_dados.last()).vr_nrctremp := 2984359;
    v_dados(v_dados.last()).vr_vllanmto := 38.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11619554;
    v_dados(v_dados.last()).vr_nrctremp := 2984552;
    v_dados(v_dados.last()).vr_vllanmto := 55.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9038760;
    v_dados(v_dados.last()).vr_nrctremp := 2985651;
    v_dados(v_dados.last()).vr_vllanmto := 71.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11790776;
    v_dados(v_dados.last()).vr_nrctremp := 2987839;
    v_dados(v_dados.last()).vr_vllanmto := 38.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11766522;
    v_dados(v_dados.last()).vr_nrctremp := 2988271;
    v_dados(v_dados.last()).vr_vllanmto := 364.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6935915;
    v_dados(v_dados.last()).vr_nrctremp := 2991942;
    v_dados(v_dados.last()).vr_vllanmto := 367.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 2998837;
    v_dados(v_dados.last()).vr_vllanmto := 428.12;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717947;
    v_dados(v_dados.last()).vr_nrctremp := 3005429;
    v_dados(v_dados.last()).vr_vllanmto := 397.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10827200;
    v_dados(v_dados.last()).vr_nrctremp := 3008250;
    v_dados(v_dados.last()).vr_vllanmto := 108.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11703458;
    v_dados(v_dados.last()).vr_nrctremp := 3009568;
    v_dados(v_dados.last()).vr_vllanmto := 325.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11811862;
    v_dados(v_dados.last()).vr_nrctremp := 3011974;
    v_dados(v_dados.last()).vr_vllanmto := 16.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3014300;
    v_dados(v_dados.last()).vr_vllanmto := 26.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 3023875;
    v_dados(v_dados.last()).vr_vllanmto := 382.5;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11776340;
    v_dados(v_dados.last()).vr_nrctremp := 3032948;
    v_dados(v_dados.last()).vr_vllanmto := 35.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8462461;
    v_dados(v_dados.last()).vr_nrctremp := 3041554;
    v_dados(v_dados.last()).vr_vllanmto := 32.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10654445;
    v_dados(v_dados.last()).vr_nrctremp := 3046625;
    v_dados(v_dados.last()).vr_vllanmto := 132.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8111154;
    v_dados(v_dados.last()).vr_nrctremp := 3052911;
    v_dados(v_dados.last()).vr_vllanmto := 42.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 45.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4065859;
    v_dados(v_dados.last()).vr_nrctremp := 3066712;
    v_dados(v_dados.last()).vr_vllanmto := 13.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9192751;
    v_dados(v_dados.last()).vr_nrctremp := 3066854;
    v_dados(v_dados.last()).vr_vllanmto := 93.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861579;
    v_dados(v_dados.last()).vr_nrctremp := 3067139;
    v_dados(v_dados.last()).vr_vllanmto := 123.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11858001;
    v_dados(v_dados.last()).vr_nrctremp := 3070526;
    v_dados(v_dados.last()).vr_vllanmto := 129.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9158790;
    v_dados(v_dados.last()).vr_nrctremp := 3072259;
    v_dados(v_dados.last()).vr_vllanmto := 50.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80249469;
    v_dados(v_dados.last()).vr_nrctremp := 3075184;
    v_dados(v_dados.last()).vr_vllanmto := 88.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10006001;
    v_dados(v_dados.last()).vr_nrctremp := 3077352;
    v_dados(v_dados.last()).vr_vllanmto := 226.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 3077941;
    v_dados(v_dados.last()).vr_vllanmto := 30.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80277829;
    v_dados(v_dados.last()).vr_nrctremp := 3087767;
    v_dados(v_dados.last()).vr_vllanmto := 111.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3088171;
    v_dados(v_dados.last()).vr_vllanmto := 19.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712643;
    v_dados(v_dados.last()).vr_nrctremp := 3098270;
    v_dados(v_dados.last()).vr_vllanmto := 355.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11528753;
    v_dados(v_dados.last()).vr_nrctremp := 3098440;
    v_dados(v_dados.last()).vr_vllanmto := 129.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11905344;
    v_dados(v_dados.last()).vr_nrctremp := 3101408;
    v_dados(v_dados.last()).vr_vllanmto := 83.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11260661;
    v_dados(v_dados.last()).vr_nrctremp := 3101833;
    v_dados(v_dados.last()).vr_vllanmto := 62.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11943882;
    v_dados(v_dados.last()).vr_nrctremp := 3135724;
    v_dados(v_dados.last()).vr_vllanmto := 74.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11941650;
    v_dados(v_dados.last()).vr_nrctremp := 3140966;
    v_dados(v_dados.last()).vr_vllanmto := 254.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6928110;
    v_dados(v_dados.last()).vr_nrctremp := 3158672;
    v_dados(v_dados.last()).vr_vllanmto := 101.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3167828;
    v_dados(v_dados.last()).vr_vllanmto := 39.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773367;
    v_dados(v_dados.last()).vr_nrctremp := 3170781;
    v_dados(v_dados.last()).vr_vllanmto := 561.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 3170921;
    v_dados(v_dados.last()).vr_vllanmto := 353.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11991062;
    v_dados(v_dados.last()).vr_nrctremp := 3174399;
    v_dados(v_dados.last()).vr_vllanmto := 4992.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11990686;
    v_dados(v_dados.last()).vr_nrctremp := 3180120;
    v_dados(v_dados.last()).vr_vllanmto := 128.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3189310;
    v_dados(v_dados.last()).vr_vllanmto := 19.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019216;
    v_dados(v_dados.last()).vr_nrctremp := 3203944;
    v_dados(v_dados.last()).vr_vllanmto := 112.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12020397;
    v_dados(v_dados.last()).vr_nrctremp := 3204953;
    v_dados(v_dados.last()).vr_vllanmto := 131.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10903054;
    v_dados(v_dados.last()).vr_nrctremp := 3205813;
    v_dados(v_dados.last()).vr_vllanmto := 67.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7894694;
    v_dados(v_dados.last()).vr_nrctremp := 3222606;
    v_dados(v_dados.last()).vr_vllanmto := 41.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9868925;
    v_dados(v_dados.last()).vr_nrctremp := 3230862;
    v_dados(v_dados.last()).vr_vllanmto := 36.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3231886;
    v_dados(v_dados.last()).vr_vllanmto := 237.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11691700;
    v_dados(v_dados.last()).vr_nrctremp := 3235912;
    v_dados(v_dados.last()).vr_vllanmto := 403.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12055042;
    v_dados(v_dados.last()).vr_nrctremp := 3238779;
    v_dados(v_dados.last()).vr_vllanmto := 514.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9884955;
    v_dados(v_dados.last()).vr_nrctremp := 3253959;
    v_dados(v_dados.last()).vr_vllanmto := 12.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194711;
    v_dados(v_dados.last()).vr_nrctremp := 3255466;
    v_dados(v_dados.last()).vr_vllanmto := 11.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12074233;
    v_dados(v_dados.last()).vr_nrctremp := 3255681;
    v_dados(v_dados.last()).vr_vllanmto := 343;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12068977;
    v_dados(v_dados.last()).vr_nrctremp := 3271895;
    v_dados(v_dados.last()).vr_vllanmto := 99.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12068977;
    v_dados(v_dados.last()).vr_nrctremp := 3271903;
    v_dados(v_dados.last()).vr_vllanmto := 135.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12100595;
    v_dados(v_dados.last()).vr_nrctremp := 3288682;
    v_dados(v_dados.last()).vr_vllanmto := 277.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12103721;
    v_dados(v_dados.last()).vr_nrctremp := 3289303;
    v_dados(v_dados.last()).vr_vllanmto := 175.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12103721;
    v_dados(v_dados.last()).vr_nrctremp := 3289323;
    v_dados(v_dados.last()).vr_vllanmto := 173.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8289077;
    v_dados(v_dados.last()).vr_nrctremp := 3293193;
    v_dados(v_dados.last()).vr_vllanmto := 193.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12111791;
    v_dados(v_dados.last()).vr_nrctremp := 3296814;
    v_dados(v_dados.last()).vr_vllanmto := 239.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12109282;
    v_dados(v_dados.last()).vr_nrctremp := 3297031;
    v_dados(v_dados.last()).vr_vllanmto := 396.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11984961;
    v_dados(v_dados.last()).vr_nrctremp := 3301998;
    v_dados(v_dados.last()).vr_vllanmto := 15.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12113549;
    v_dados(v_dados.last()).vr_nrctremp := 3302334;
    v_dados(v_dados.last()).vr_vllanmto := 171.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11768614;
    v_dados(v_dados.last()).vr_nrctremp := 3305760;
    v_dados(v_dados.last()).vr_vllanmto := 408.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6880924;
    v_dados(v_dados.last()).vr_nrctremp := 3313425;
    v_dados(v_dados.last()).vr_vllanmto := 32.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 511.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12125237;
    v_dados(v_dados.last()).vr_nrctremp := 3316255;
    v_dados(v_dados.last()).vr_vllanmto := 245.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12127426;
    v_dados(v_dados.last()).vr_nrctremp := 3319430;
    v_dados(v_dados.last()).vr_vllanmto := 188.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7849613;
    v_dados(v_dados.last()).vr_nrctremp := 3354595;
    v_dados(v_dados.last()).vr_vllanmto := 16.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9777881;
    v_dados(v_dados.last()).vr_nrctremp := 3358147;
    v_dados(v_dados.last()).vr_vllanmto := 47.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11485922;
    v_dados(v_dados.last()).vr_nrctremp := 3358863;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12171956;
    v_dados(v_dados.last()).vr_nrctremp := 3382352;
    v_dados(v_dados.last()).vr_vllanmto := 222.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11870591;
    v_dados(v_dados.last()).vr_nrctremp := 3382517;
    v_dados(v_dados.last()).vr_vllanmto := 224.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12146870;
    v_dados(v_dados.last()).vr_nrctremp := 3383461;
    v_dados(v_dados.last()).vr_vllanmto := 148.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12182249;
    v_dados(v_dados.last()).vr_nrctremp := 3389755;
    v_dados(v_dados.last()).vr_vllanmto := 374.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12183890;
    v_dados(v_dados.last()).vr_nrctremp := 3393615;
    v_dados(v_dados.last()).vr_vllanmto := 367.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820840;
    v_dados(v_dados.last()).vr_nrctremp := 3399162;
    v_dados(v_dados.last()).vr_vllanmto := 209.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80415571;
    v_dados(v_dados.last()).vr_nrctremp := 3400099;
    v_dados(v_dados.last()).vr_vllanmto := 32.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11980435;
    v_dados(v_dados.last()).vr_nrctremp := 3404776;
    v_dados(v_dados.last()).vr_vllanmto := 299.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11656948;
    v_dados(v_dados.last()).vr_nrctremp := 3404940;
    v_dados(v_dados.last()).vr_vllanmto := 51.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8980381;
    v_dados(v_dados.last()).vr_nrctremp := 3406800;
    v_dados(v_dados.last()).vr_vllanmto := 46.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212539;
    v_dados(v_dados.last()).vr_nrctremp := 3415080;
    v_dados(v_dados.last()).vr_vllanmto := 186.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12208132;
    v_dados(v_dados.last()).vr_nrctremp := 3416575;
    v_dados(v_dados.last()).vr_vllanmto := 176.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12211109;
    v_dados(v_dados.last()).vr_nrctremp := 3417203;
    v_dados(v_dados.last()).vr_vllanmto := 56.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212202;
    v_dados(v_dados.last()).vr_nrctremp := 3420248;
    v_dados(v_dados.last()).vr_vllanmto := 368;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421230;
    v_dados(v_dados.last()).vr_vllanmto := 309.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421257;
    v_dados(v_dados.last()).vr_vllanmto := 386.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8707642;
    v_dados(v_dados.last()).vr_nrctremp := 3430425;
    v_dados(v_dados.last()).vr_vllanmto := 285.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3430704;
    v_dados(v_dados.last()).vr_vllanmto := 228.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035734;
    v_dados(v_dados.last()).vr_nrctremp := 3434461;
    v_dados(v_dados.last()).vr_vllanmto := 167.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230448;
    v_dados(v_dados.last()).vr_nrctremp := 3435628;
    v_dados(v_dados.last()).vr_vllanmto := 59.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12239470;
    v_dados(v_dados.last()).vr_nrctremp := 3436180;
    v_dados(v_dados.last()).vr_vllanmto := 146.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3449703;
    v_dados(v_dados.last()).vr_vllanmto := 129.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12257907;
    v_dados(v_dados.last()).vr_nrctremp := 3453198;
    v_dados(v_dados.last()).vr_vllanmto := 183.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12260657;
    v_dados(v_dados.last()).vr_nrctremp := 3454868;
    v_dados(v_dados.last()).vr_vllanmto := 56.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12258431;
    v_dados(v_dados.last()).vr_nrctremp := 3455167;
    v_dados(v_dados.last()).vr_vllanmto := 380.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80170781;
    v_dados(v_dados.last()).vr_nrctremp := 3472408;
    v_dados(v_dados.last()).vr_vllanmto := 80.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12281220;
    v_dados(v_dados.last()).vr_nrctremp := 3478543;
    v_dados(v_dados.last()).vr_vllanmto := 126.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9279032;
    v_dados(v_dados.last()).vr_nrctremp := 3481207;
    v_dados(v_dados.last()).vr_vllanmto := 282.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12292451;
    v_dados(v_dados.last()).vr_nrctremp := 3482970;
    v_dados(v_dados.last()).vr_vllanmto := 228.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12296570;
    v_dados(v_dados.last()).vr_nrctremp := 3485677;
    v_dados(v_dados.last()).vr_vllanmto := 93.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8934797;
    v_dados(v_dados.last()).vr_nrctremp := 3488014;
    v_dados(v_dados.last()).vr_vllanmto := 27.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12311170;
    v_dados(v_dados.last()).vr_nrctremp := 3502234;
    v_dados(v_dados.last()).vr_vllanmto := 174.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 3504420;
    v_dados(v_dados.last()).vr_vllanmto := 106.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 3504428;
    v_dados(v_dados.last()).vr_vllanmto := 168.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12313670;
    v_dados(v_dados.last()).vr_nrctremp := 3508051;
    v_dados(v_dados.last()).vr_vllanmto := 90.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12316628;
    v_dados(v_dados.last()).vr_nrctremp := 3510982;
    v_dados(v_dados.last()).vr_vllanmto := 172.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078602;
    v_dados(v_dados.last()).vr_nrctremp := 3520144;
    v_dados(v_dados.last()).vr_vllanmto := 325.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11889195;
    v_dados(v_dados.last()).vr_nrctremp := 3521680;
    v_dados(v_dados.last()).vr_vllanmto := 386.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11369248;
    v_dados(v_dados.last()).vr_nrctremp := 3542693;
    v_dados(v_dados.last()).vr_vllanmto := 55.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9819851;
    v_dados(v_dados.last()).vr_nrctremp := 3543735;
    v_dados(v_dados.last()).vr_vllanmto := 37.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12349909;
    v_dados(v_dados.last()).vr_nrctremp := 3549289;
    v_dados(v_dados.last()).vr_vllanmto := 175.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101089;
    v_dados(v_dados.last()).vr_nrctremp := 3549323;
    v_dados(v_dados.last()).vr_vllanmto := 84.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12360082;
    v_dados(v_dados.last()).vr_nrctremp := 3555694;
    v_dados(v_dados.last()).vr_vllanmto := 266.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12364690;
    v_dados(v_dados.last()).vr_nrctremp := 3572209;
    v_dados(v_dados.last()).vr_vllanmto := 243.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12377066;
    v_dados(v_dados.last()).vr_nrctremp := 3572938;
    v_dados(v_dados.last()).vr_vllanmto := 263;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12378917;
    v_dados(v_dados.last()).vr_nrctremp := 3577859;
    v_dados(v_dados.last()).vr_vllanmto := 204.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12383708;
    v_dados(v_dados.last()).vr_nrctremp := 3578578;
    v_dados(v_dados.last()).vr_vllanmto := 166.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12386952;
    v_dados(v_dados.last()).vr_nrctremp := 3582357;
    v_dados(v_dados.last()).vr_vllanmto := 85.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389080;
    v_dados(v_dados.last()).vr_nrctremp := 3584084;
    v_dados(v_dados.last()).vr_vllanmto := 198.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12390917;
    v_dados(v_dados.last()).vr_nrctremp := 3584687;
    v_dados(v_dados.last()).vr_vllanmto := 121.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12386987;
    v_dados(v_dados.last()).vr_nrctremp := 3586125;
    v_dados(v_dados.last()).vr_vllanmto := 239.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12392820;
    v_dados(v_dados.last()).vr_nrctremp := 3586887;
    v_dados(v_dados.last()).vr_vllanmto := 241.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12325570;
    v_dados(v_dados.last()).vr_nrctremp := 3599984;
    v_dados(v_dados.last()).vr_vllanmto := 297.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12397253;
    v_dados(v_dados.last()).vr_nrctremp := 3600273;
    v_dados(v_dados.last()).vr_vllanmto := 283.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12405060;
    v_dados(v_dados.last()).vr_nrctremp := 3602629;
    v_dados(v_dados.last()).vr_vllanmto := 334.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11747820;
    v_dados(v_dados.last()).vr_nrctremp := 3604371;
    v_dados(v_dados.last()).vr_vllanmto := 290.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12395234;
    v_dados(v_dados.last()).vr_nrctremp := 3607075;
    v_dados(v_dados.last()).vr_vllanmto := 198.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3607632;
    v_dados(v_dados.last()).vr_vllanmto := 13.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12395730;
    v_dados(v_dados.last()).vr_nrctremp := 3610106;
    v_dados(v_dados.last()).vr_vllanmto := 195.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413887;
    v_dados(v_dados.last()).vr_nrctremp := 3610206;
    v_dados(v_dados.last()).vr_vllanmto := 235.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11528753;
    v_dados(v_dados.last()).vr_nrctremp := 3613913;
    v_dados(v_dados.last()).vr_vllanmto := 62.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12417742;
    v_dados(v_dados.last()).vr_nrctremp := 3614655;
    v_dados(v_dados.last()).vr_vllanmto := 244.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12422320;
    v_dados(v_dados.last()).vr_nrctremp := 3615395;
    v_dados(v_dados.last()).vr_vllanmto := 93.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12424579;
    v_dados(v_dados.last()).vr_nrctremp := 3618246;
    v_dados(v_dados.last()).vr_vllanmto := 83.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12419940;
    v_dados(v_dados.last()).vr_nrctremp := 3618344;
    v_dados(v_dados.last()).vr_vllanmto := 352.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8176493;
    v_dados(v_dados.last()).vr_nrctremp := 3618471;
    v_dados(v_dados.last()).vr_vllanmto := 94.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 411.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425770;
    v_dados(v_dados.last()).vr_nrctremp := 3620293;
    v_dados(v_dados.last()).vr_vllanmto := 191.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12420085;
    v_dados(v_dados.last()).vr_nrctremp := 3621331;
    v_dados(v_dados.last()).vr_vllanmto := 116.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8907315;
    v_dados(v_dados.last()).vr_nrctremp := 3627786;
    v_dados(v_dados.last()).vr_vllanmto := 235.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9583211;
    v_dados(v_dados.last()).vr_nrctremp := 3639619;
    v_dados(v_dados.last()).vr_vllanmto := 159.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3074250;
    v_dados(v_dados.last()).vr_nrctremp := 3641650;
    v_dados(v_dados.last()).vr_vllanmto := 62.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11093293;
    v_dados(v_dados.last()).vr_nrctremp := 3646338;
    v_dados(v_dados.last()).vr_vllanmto := 96.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12450316;
    v_dados(v_dados.last()).vr_nrctremp := 3647430;
    v_dados(v_dados.last()).vr_vllanmto := 150.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11057300;
    v_dados(v_dados.last()).vr_nrctremp := 3653854;
    v_dados(v_dados.last()).vr_vllanmto := 126.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12455180;
    v_dados(v_dados.last()).vr_nrctremp := 3655624;
    v_dados(v_dados.last()).vr_vllanmto := 326.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12305804;
    v_dados(v_dados.last()).vr_nrctremp := 3656154;
    v_dados(v_dados.last()).vr_vllanmto := 153.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12463655;
    v_dados(v_dados.last()).vr_nrctremp := 3663444;
    v_dados(v_dados.last()).vr_vllanmto := 256.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2038650;
    v_dados(v_dados.last()).vr_nrctremp := 3664319;
    v_dados(v_dados.last()).vr_vllanmto := 462.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12469220;
    v_dados(v_dados.last()).vr_nrctremp := 3669103;
    v_dados(v_dados.last()).vr_vllanmto := 132.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12472778;
    v_dados(v_dados.last()).vr_nrctremp := 3673753;
    v_dados(v_dados.last()).vr_vllanmto := 149.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475165;
    v_dados(v_dados.last()).vr_nrctremp := 3675184;
    v_dados(v_dados.last()).vr_vllanmto := 18.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475408;
    v_dados(v_dados.last()).vr_nrctremp := 3680350;
    v_dados(v_dados.last()).vr_vllanmto := 161.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12484180;
    v_dados(v_dados.last()).vr_nrctremp := 3681772;
    v_dados(v_dados.last()).vr_vllanmto := 145.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12111422;
    v_dados(v_dados.last()).vr_nrctremp := 3684282;
    v_dados(v_dados.last()).vr_vllanmto := 231.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10800824;
    v_dados(v_dados.last()).vr_nrctremp := 3684745;
    v_dados(v_dados.last()).vr_vllanmto := 186.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12055042;
    v_dados(v_dados.last()).vr_nrctremp := 3692692;
    v_dados(v_dados.last()).vr_vllanmto := 208.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695197;
    v_dados(v_dados.last()).vr_vllanmto := 38.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 69.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194371;
    v_dados(v_dados.last()).vr_nrctremp := 3700170;
    v_dados(v_dados.last()).vr_vllanmto := 16.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10735224;
    v_dados(v_dados.last()).vr_nrctremp := 3701725;
    v_dados(v_dados.last()).vr_vllanmto := 106.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8176493;
    v_dados(v_dados.last()).vr_nrctremp := 3702027;
    v_dados(v_dados.last()).vr_vllanmto := 21.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12487937;
    v_dados(v_dados.last()).vr_nrctremp := 3703633;
    v_dados(v_dados.last()).vr_vllanmto := 243.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 3706648;
    v_dados(v_dados.last()).vr_vllanmto := 396.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9846867;
    v_dados(v_dados.last()).vr_nrctremp := 3707968;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9648623;
    v_dados(v_dados.last()).vr_nrctremp := 3708106;
    v_dados(v_dados.last()).vr_vllanmto := 94.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 3726006;
    v_dados(v_dados.last()).vr_vllanmto := 159.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 615.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10601465;
    v_dados(v_dados.last()).vr_nrctremp := 3730712;
    v_dados(v_dados.last()).vr_vllanmto := 23.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3864626;
    v_dados(v_dados.last()).vr_nrctremp := 3730749;
    v_dados(v_dados.last()).vr_vllanmto := 490.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11218142;
    v_dados(v_dados.last()).vr_nrctremp := 3732464;
    v_dados(v_dados.last()).vr_vllanmto := 74.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2825082;
    v_dados(v_dados.last()).vr_nrctremp := 3740871;
    v_dados(v_dados.last()).vr_vllanmto := 27.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12540552;
    v_dados(v_dados.last()).vr_nrctremp := 3741052;
    v_dados(v_dados.last()).vr_vllanmto := 28.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 3742862;
    v_dados(v_dados.last()).vr_vllanmto := 693.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11980435;
    v_dados(v_dados.last()).vr_nrctremp := 3751044;
    v_dados(v_dados.last()).vr_vllanmto := 17.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12548650;
    v_dados(v_dados.last()).vr_nrctremp := 3753649;
    v_dados(v_dados.last()).vr_vllanmto := 347.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12550884;
    v_dados(v_dados.last()).vr_nrctremp := 3756384;
    v_dados(v_dados.last()).vr_vllanmto := 95.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035734;
    v_dados(v_dados.last()).vr_nrctremp := 3758256;
    v_dados(v_dados.last()).vr_vllanmto := 62.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12553913;
    v_dados(v_dados.last()).vr_nrctremp := 3758627;
    v_dados(v_dados.last()).vr_vllanmto := 308.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12541265;
    v_dados(v_dados.last()).vr_nrctremp := 3760813;
    v_dados(v_dados.last()).vr_vllanmto := 300.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12557889;
    v_dados(v_dados.last()).vr_nrctremp := 3762595;
    v_dados(v_dados.last()).vr_vllanmto := 288.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12558010;
    v_dados(v_dados.last()).vr_nrctremp := 3763615;
    v_dados(v_dados.last()).vr_vllanmto := 184.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12491233;
    v_dados(v_dados.last()).vr_nrctremp := 3764113;
    v_dados(v_dados.last()).vr_vllanmto := 257.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12558923;
    v_dados(v_dados.last()).vr_nrctremp := 3766913;
    v_dados(v_dados.last()).vr_vllanmto := 258.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12526452;
    v_dados(v_dados.last()).vr_nrctremp := 3770518;
    v_dados(v_dados.last()).vr_vllanmto := 111.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12568457;
    v_dados(v_dados.last()).vr_nrctremp := 3774764;
    v_dados(v_dados.last()).vr_vllanmto := 447.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9956484;
    v_dados(v_dados.last()).vr_nrctremp := 3775596;
    v_dados(v_dados.last()).vr_vllanmto := 275.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12446521;
    v_dados(v_dados.last()).vr_nrctremp := 3776059;
    v_dados(v_dados.last()).vr_vllanmto := 149.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12544515;
    v_dados(v_dados.last()).vr_nrctremp := 3794871;
    v_dados(v_dados.last()).vr_vllanmto := 74.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 3795640;
    v_dados(v_dados.last()).vr_vllanmto := 299.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12590487;
    v_dados(v_dados.last()).vr_nrctremp := 3799167;
    v_dados(v_dados.last()).vr_vllanmto := 252.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3519201;
    v_dados(v_dados.last()).vr_nrctremp := 3799730;
    v_dados(v_dados.last()).vr_vllanmto := 46.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12591424;
    v_dados(v_dados.last()).vr_nrctremp := 3799822;
    v_dados(v_dados.last()).vr_vllanmto := 164.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520870;
    v_dados(v_dados.last()).vr_nrctremp := 3800114;
    v_dados(v_dados.last()).vr_vllanmto := 234.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 761893;
    v_dados(v_dados.last()).vr_nrctremp := 3801383;
    v_dados(v_dados.last()).vr_vllanmto := 21.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8111383;
    v_dados(v_dados.last()).vr_nrctremp := 3805450;
    v_dados(v_dados.last()).vr_vllanmto := 40.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12594750;
    v_dados(v_dados.last()).vr_nrctremp := 3807129;
    v_dados(v_dados.last()).vr_vllanmto := 331.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 3808261;
    v_dados(v_dados.last()).vr_vllanmto := 26.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7763557;
    v_dados(v_dados.last()).vr_nrctremp := 3808400;
    v_dados(v_dados.last()).vr_vllanmto := 64.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8479461;
    v_dados(v_dados.last()).vr_nrctremp := 3811627;
    v_dados(v_dados.last()).vr_vllanmto := 62.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80193501;
    v_dados(v_dados.last()).vr_nrctremp := 3813432;
    v_dados(v_dados.last()).vr_vllanmto := 148.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9313516;
    v_dados(v_dados.last()).vr_nrctremp := 3814502;
    v_dados(v_dados.last()).vr_vllanmto := 34.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12560448;
    v_dados(v_dados.last()).vr_nrctremp := 3815167;
    v_dados(v_dados.last()).vr_vllanmto := 10.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12560448;
    v_dados(v_dados.last()).vr_nrctremp := 3815662;
    v_dados(v_dados.last()).vr_vllanmto := 49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7764430;
    v_dados(v_dados.last()).vr_nrctremp := 3821955;
    v_dados(v_dados.last()).vr_vllanmto := 49.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617008;
    v_dados(v_dados.last()).vr_nrctremp := 3827456;
    v_dados(v_dados.last()).vr_vllanmto := 81.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10424121;
    v_dados(v_dados.last()).vr_nrctremp := 3830632;
    v_dados(v_dados.last()).vr_vllanmto := 98.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12620394;
    v_dados(v_dados.last()).vr_nrctremp := 3830750;
    v_dados(v_dados.last()).vr_vllanmto := 325.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12386987;
    v_dados(v_dados.last()).vr_nrctremp := 3830755;
    v_dados(v_dados.last()).vr_vllanmto := 12.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12620491;
    v_dados(v_dados.last()).vr_nrctremp := 3830907;
    v_dados(v_dados.last()).vr_vllanmto := 212.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9790900;
    v_dados(v_dados.last()).vr_nrctremp := 3831349;
    v_dados(v_dados.last()).vr_vllanmto := 74.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595080;
    v_dados(v_dados.last()).vr_nrctremp := 3836849;
    v_dados(v_dados.last()).vr_vllanmto := 263.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11083050;
    v_dados(v_dados.last()).vr_nrctremp := 3837073;
    v_dados(v_dados.last()).vr_vllanmto := 63.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8177589;
    v_dados(v_dados.last()).vr_nrctremp := 3837514;
    v_dados(v_dados.last()).vr_vllanmto := 44.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820408;
    v_dados(v_dados.last()).vr_nrctremp := 3838282;
    v_dados(v_dados.last()).vr_vllanmto := 127.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389466;
    v_dados(v_dados.last()).vr_nrctremp := 3843922;
    v_dados(v_dados.last()).vr_vllanmto := 45.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12624586;
    v_dados(v_dados.last()).vr_nrctremp := 3844543;
    v_dados(v_dados.last()).vr_vllanmto := 166.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10718087;
    v_dados(v_dados.last()).vr_nrctremp := 3845139;
    v_dados(v_dados.last()).vr_vllanmto := 28.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12316628;
    v_dados(v_dados.last()).vr_nrctremp := 3845592;
    v_dados(v_dados.last()).vr_vllanmto := 32.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8133298;
    v_dados(v_dados.last()).vr_nrctremp := 3851537;
    v_dados(v_dados.last()).vr_vllanmto := 142.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2124726;
    v_dados(v_dados.last()).vr_nrctremp := 3851551;
    v_dados(v_dados.last()).vr_vllanmto := 167.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10140425;
    v_dados(v_dados.last()).vr_nrctremp := 3852530;
    v_dados(v_dados.last()).vr_vllanmto := 126.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3150054;
    v_dados(v_dados.last()).vr_nrctremp := 3855698;
    v_dados(v_dados.last()).vr_vllanmto := 159.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9517766;
    v_dados(v_dados.last()).vr_nrctremp := 3855948;
    v_dados(v_dados.last()).vr_vllanmto := 239.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80334768;
    v_dados(v_dados.last()).vr_nrctremp := 3858963;
    v_dados(v_dados.last()).vr_vllanmto := 271.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6880924;
    v_dados(v_dados.last()).vr_nrctremp := 3859002;
    v_dados(v_dados.last()).vr_vllanmto := 22.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3004031;
    v_dados(v_dados.last()).vr_nrctremp := 3859328;
    v_dados(v_dados.last()).vr_vllanmto := 122.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425737;
    v_dados(v_dados.last()).vr_nrctremp := 3860454;
    v_dados(v_dados.last()).vr_vllanmto := 208.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637106;
    v_dados(v_dados.last()).vr_nrctremp := 3868680;
    v_dados(v_dados.last()).vr_vllanmto := 209.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12543004;
    v_dados(v_dados.last()).vr_nrctremp := 3869309;
    v_dados(v_dados.last()).vr_vllanmto := 339.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7797320;
    v_dados(v_dados.last()).vr_nrctremp := 3869609;
    v_dados(v_dados.last()).vr_vllanmto := 219.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12669016;
    v_dados(v_dados.last()).vr_nrctremp := 3876683;
    v_dados(v_dados.last()).vr_vllanmto := 35.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877832;
    v_dados(v_dados.last()).vr_vllanmto := 43.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877848;
    v_dados(v_dados.last()).vr_vllanmto := 103.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2752336;
    v_dados(v_dados.last()).vr_nrctremp := 3884678;
    v_dados(v_dados.last()).vr_vllanmto := 235.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 135.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12602787;
    v_dados(v_dados.last()).vr_nrctremp := 3889272;
    v_dados(v_dados.last()).vr_vllanmto := 67.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12602787;
    v_dados(v_dados.last()).vr_nrctremp := 3889300;
    v_dados(v_dados.last()).vr_vllanmto := 133.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 3889867;
    v_dados(v_dados.last()).vr_vllanmto := 172.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 3889874;
    v_dados(v_dados.last()).vr_vllanmto := 9075.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12397466;
    v_dados(v_dados.last()).vr_nrctremp := 3890143;
    v_dados(v_dados.last()).vr_vllanmto := 279.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3890428;
    v_dados(v_dados.last()).vr_vllanmto := 45.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12634344;
    v_dados(v_dados.last()).vr_nrctremp := 3891425;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11396733;
    v_dados(v_dados.last()).vr_nrctremp := 3897105;
    v_dados(v_dados.last()).vr_vllanmto := 219.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 3897149;
    v_dados(v_dados.last()).vr_vllanmto := 91.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690392;
    v_dados(v_dados.last()).vr_nrctremp := 3897211;
    v_dados(v_dados.last()).vr_vllanmto := 151.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2183315;
    v_dados(v_dados.last()).vr_nrctremp := 3907302;
    v_dados(v_dados.last()).vr_vllanmto := 213.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10049916;
    v_dados(v_dados.last()).vr_nrctremp := 3917431;
    v_dados(v_dados.last()).vr_vllanmto := 27.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6683045;
    v_dados(v_dados.last()).vr_nrctremp := 3919366;
    v_dados(v_dados.last()).vr_vllanmto := 20.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 305.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11768614;
    v_dados(v_dados.last()).vr_nrctremp := 3920052;
    v_dados(v_dados.last()).vr_vllanmto := 14.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12182249;
    v_dados(v_dados.last()).vr_nrctremp := 3925674;
    v_dados(v_dados.last()).vr_vllanmto := 64.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533640;
    v_dados(v_dados.last()).vr_nrctremp := 3927171;
    v_dados(v_dados.last()).vr_vllanmto := 30.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2515938;
    v_dados(v_dados.last()).vr_nrctremp := 3930543;
    v_dados(v_dados.last()).vr_vllanmto := 82.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11750200;
    v_dados(v_dados.last()).vr_nrctremp := 3931873;
    v_dados(v_dados.last()).vr_vllanmto := 47.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10487662;
    v_dados(v_dados.last()).vr_nrctremp := 3932268;
    v_dados(v_dados.last()).vr_vllanmto := 41.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190449;
    v_dados(v_dados.last()).vr_nrctremp := 3932307;
    v_dados(v_dados.last()).vr_vllanmto := 136.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12724009;
    v_dados(v_dados.last()).vr_nrctremp := 3932327;
    v_dados(v_dados.last()).vr_vllanmto := 243.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12724009;
    v_dados(v_dados.last()).vr_nrctremp := 3932359;
    v_dados(v_dados.last()).vr_vllanmto := 50.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710091;
    v_dados(v_dados.last()).vr_nrctremp := 3935842;
    v_dados(v_dados.last()).vr_vllanmto := 427.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12465321;
    v_dados(v_dados.last()).vr_nrctremp := 3936331;
    v_dados(v_dados.last()).vr_vllanmto := 132.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4048164;
    v_dados(v_dados.last()).vr_nrctremp := 3936549;
    v_dados(v_dados.last()).vr_vllanmto := 24.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10197559;
    v_dados(v_dados.last()).vr_nrctremp := 3937980;
    v_dados(v_dados.last()).vr_vllanmto := 28.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12293407;
    v_dados(v_dados.last()).vr_nrctremp := 3938066;
    v_dados(v_dados.last()).vr_vllanmto := 519.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12731986;
    v_dados(v_dados.last()).vr_nrctremp := 3938134;
    v_dados(v_dados.last()).vr_vllanmto := 55.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939431;
    v_dados(v_dados.last()).vr_vllanmto := 58.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939478;
    v_dados(v_dados.last()).vr_vllanmto := 54.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11887745;
    v_dados(v_dados.last()).vr_nrctremp := 3941325;
    v_dados(v_dados.last()).vr_vllanmto := 386.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2617480;
    v_dados(v_dados.last()).vr_nrctremp := 3942943;
    v_dados(v_dados.last()).vr_vllanmto := 139.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10250603;
    v_dados(v_dados.last()).vr_nrctremp := 3955391;
    v_dados(v_dados.last()).vr_vllanmto := 114.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752827;
    v_dados(v_dados.last()).vr_nrctremp := 3960181;
    v_dados(v_dados.last()).vr_vllanmto := 129.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3628280;
    v_dados(v_dados.last()).vr_nrctremp := 3965338;
    v_dados(v_dados.last()).vr_vllanmto := 52.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760102;
    v_dados(v_dados.last()).vr_nrctremp := 3965764;
    v_dados(v_dados.last()).vr_vllanmto := 64.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3966458;
    v_dados(v_dados.last()).vr_vllanmto := 18.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12763802;
    v_dados(v_dados.last()).vr_nrctremp := 3968735;
    v_dados(v_dados.last()).vr_vllanmto := 52.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2515938;
    v_dados(v_dados.last()).vr_nrctremp := 3969605;
    v_dados(v_dados.last()).vr_vllanmto := 606.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413640;
    v_dados(v_dados.last()).vr_nrctremp := 3977580;
    v_dados(v_dados.last()).vr_vllanmto := 54.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12780693;
    v_dados(v_dados.last()).vr_nrctremp := 3985633;
    v_dados(v_dados.last()).vr_vllanmto := 111.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12582565;
    v_dados(v_dados.last()).vr_nrctremp := 3986201;
    v_dados(v_dados.last()).vr_vllanmto := 461.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10677542;
    v_dados(v_dados.last()).vr_nrctremp := 3986642;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12027413;
    v_dados(v_dados.last()).vr_nrctremp := 3988033;
    v_dados(v_dados.last()).vr_vllanmto := 29.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9202749;
    v_dados(v_dados.last()).vr_nrctremp := 3990162;
    v_dados(v_dados.last()).vr_vllanmto := 184.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 3990203;
    v_dados(v_dados.last()).vr_vllanmto := 2772.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3004031;
    v_dados(v_dados.last()).vr_nrctremp := 3990299;
    v_dados(v_dados.last()).vr_vllanmto := 50.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3990688;
    v_dados(v_dados.last()).vr_vllanmto := 454.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12717304;
    v_dados(v_dados.last()).vr_nrctremp := 3995442;
    v_dados(v_dados.last()).vr_vllanmto := 124.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12720828;
    v_dados(v_dados.last()).vr_nrctremp := 3995814;
    v_dados(v_dados.last()).vr_vllanmto := 58.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12350990;
    v_dados(v_dados.last()).vr_nrctremp := 3996044;
    v_dados(v_dados.last()).vr_vllanmto := 114.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716200;
    v_dados(v_dados.last()).vr_nrctremp := 3996934;
    v_dados(v_dados.last()).vr_vllanmto := 195.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12701521;
    v_dados(v_dados.last()).vr_nrctremp := 3997739;
    v_dados(v_dados.last()).vr_vllanmto := 386.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12411574;
    v_dados(v_dados.last()).vr_nrctremp := 4002024;
    v_dados(v_dados.last()).vr_vllanmto := 50.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078793;
    v_dados(v_dados.last()).vr_nrctremp := 4002953;
    v_dados(v_dados.last()).vr_vllanmto := 83.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 4003870;
    v_dados(v_dados.last()).vr_vllanmto := 69.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12735779;
    v_dados(v_dados.last()).vr_nrctremp := 4004030;
    v_dados(v_dados.last()).vr_vllanmto := 222.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4005739;
    v_dados(v_dados.last()).vr_vllanmto := 26.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12558010;
    v_dados(v_dados.last()).vr_nrctremp := 4007173;
    v_dados(v_dados.last()).vr_vllanmto := 12.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9319131;
    v_dados(v_dados.last()).vr_nrctremp := 4007479;
    v_dados(v_dados.last()).vr_vllanmto := 20.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717351;
    v_dados(v_dados.last()).vr_nrctremp := 4014142;
    v_dados(v_dados.last()).vr_vllanmto := 175.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12713287;
    v_dados(v_dados.last()).vr_nrctremp := 4014252;
    v_dados(v_dados.last()).vr_vllanmto := 59.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12706477;
    v_dados(v_dados.last()).vr_nrctremp := 4016118;
    v_dados(v_dados.last()).vr_vllanmto := 445.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12361283;
    v_dados(v_dados.last()).vr_nrctremp := 4016461;
    v_dados(v_dados.last()).vr_vllanmto := 51.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 75.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12462888;
    v_dados(v_dados.last()).vr_nrctremp := 4022402;
    v_dados(v_dados.last()).vr_vllanmto := 257.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10530541;
    v_dados(v_dados.last()).vr_nrctremp := 4022488;
    v_dados(v_dados.last()).vr_vllanmto := 99.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12763802;
    v_dados(v_dados.last()).vr_nrctremp := 4022781;
    v_dados(v_dados.last()).vr_vllanmto := 29.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4024341;
    v_dados(v_dados.last()).vr_vllanmto := 106.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601977;
    v_dados(v_dados.last()).vr_nrctremp := 4029953;
    v_dados(v_dados.last()).vr_vllanmto := 550.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6887660;
    v_dados(v_dados.last()).vr_nrctremp := 4034949;
    v_dados(v_dados.last()).vr_vllanmto := 195.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10206345;
    v_dados(v_dados.last()).vr_nrctremp := 4035306;
    v_dados(v_dados.last()).vr_vllanmto := 57.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4038250;
    v_dados(v_dados.last()).vr_vllanmto := 698.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7928041;
    v_dados(v_dados.last()).vr_nrctremp := 4044684;
    v_dados(v_dados.last()).vr_vllanmto := 979.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12724882;
    v_dados(v_dados.last()).vr_nrctremp := 4046022;
    v_dados(v_dados.last()).vr_vllanmto := 166.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9744711;
    v_dados(v_dados.last()).vr_nrctremp := 4046030;
    v_dados(v_dados.last()).vr_vllanmto := 69.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12129054;
    v_dados(v_dados.last()).vr_nrctremp := 4047834;
    v_dados(v_dados.last()).vr_vllanmto := 238.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 4049377;
    v_dados(v_dados.last()).vr_vllanmto := 35.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12673161;
    v_dados(v_dados.last()).vr_nrctremp := 4052613;
    v_dados(v_dados.last()).vr_vllanmto := 541.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4053802;
    v_dados(v_dados.last()).vr_vllanmto := 61.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12665193;
    v_dados(v_dados.last()).vr_nrctremp := 4054130;
    v_dados(v_dados.last()).vr_vllanmto := 39.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2909421;
    v_dados(v_dados.last()).vr_nrctremp := 4055454;
    v_dados(v_dados.last()).vr_vllanmto := 20.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11723203;
    v_dados(v_dados.last()).vr_nrctremp := 4058671;
    v_dados(v_dados.last()).vr_vllanmto := 265.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11752130;
    v_dados(v_dados.last()).vr_nrctremp := 4058868;
    v_dados(v_dados.last()).vr_vllanmto := 288.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 4059743;
    v_dados(v_dados.last()).vr_vllanmto := 35.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8675678;
    v_dados(v_dados.last()).vr_nrctremp := 4060220;
    v_dados(v_dados.last()).vr_vllanmto := 69.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7811284;
    v_dados(v_dados.last()).vr_nrctremp := 4060384;
    v_dados(v_dados.last()).vr_vllanmto := 30.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12720828;
    v_dados(v_dados.last()).vr_nrctremp := 4065438;
    v_dados(v_dados.last()).vr_vllanmto := 19.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80012248;
    v_dados(v_dados.last()).vr_nrctremp := 4068844;
    v_dados(v_dados.last()).vr_vllanmto := 23.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 4072763;
    v_dados(v_dados.last()).vr_vllanmto := 1434.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752916;
    v_dados(v_dados.last()).vr_nrctremp := 4073735;
    v_dados(v_dados.last()).vr_vllanmto := 232.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 4074407;
    v_dados(v_dados.last()).vr_vllanmto := 61.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12074233;
    v_dados(v_dados.last()).vr_nrctremp := 4074671;
    v_dados(v_dados.last()).vr_vllanmto := 35.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710563;
    v_dados(v_dados.last()).vr_nrctremp := 4075169;
    v_dados(v_dados.last()).vr_vllanmto := 352.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2182955;
    v_dados(v_dados.last()).vr_nrctremp := 4076508;
    v_dados(v_dados.last()).vr_vllanmto := 399.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873853;
    v_dados(v_dados.last()).vr_nrctremp := 4082058;
    v_dados(v_dados.last()).vr_vllanmto := 195.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12785369;
    v_dados(v_dados.last()).vr_nrctremp := 4083531;
    v_dados(v_dados.last()).vr_vllanmto := 339.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873632;
    v_dados(v_dados.last()).vr_nrctremp := 4085979;
    v_dados(v_dados.last()).vr_vllanmto := 249.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12891185;
    v_dados(v_dados.last()).vr_nrctremp := 4090475;
    v_dados(v_dados.last()).vr_vllanmto := 201.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898899;
    v_dados(v_dados.last()).vr_nrctremp := 4097203;
    v_dados(v_dados.last()).vr_vllanmto := 179.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2125579;
    v_dados(v_dados.last()).vr_nrctremp := 4097261;
    v_dados(v_dados.last()).vr_vllanmto := 27.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097708;
    v_dados(v_dados.last()).vr_vllanmto := 12.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097729;
    v_dados(v_dados.last()).vr_vllanmto := 15.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097741;
    v_dados(v_dados.last()).vr_vllanmto := 14.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097768;
    v_dados(v_dados.last()).vr_vllanmto := 131.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8637733;
    v_dados(v_dados.last()).vr_nrctremp := 4101609;
    v_dados(v_dados.last()).vr_vllanmto := 73.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12632643;
    v_dados(v_dados.last()).vr_nrctremp := 4102190;
    v_dados(v_dados.last()).vr_vllanmto := 22.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739090;
    v_dados(v_dados.last()).vr_nrctremp := 4102671;
    v_dados(v_dados.last()).vr_vllanmto := 751.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098258;
    v_dados(v_dados.last()).vr_nrctremp := 4104217;
    v_dados(v_dados.last()).vr_vllanmto := 120.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4107091;
    v_dados(v_dados.last()).vr_vllanmto := 83.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6319572;
    v_dados(v_dados.last()).vr_nrctremp := 4108542;
    v_dados(v_dados.last()).vr_vllanmto := 16.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12561762;
    v_dados(v_dados.last()).vr_nrctremp := 4109959;
    v_dados(v_dados.last()).vr_vllanmto := 161.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710563;
    v_dados(v_dados.last()).vr_nrctremp := 4117414;
    v_dados(v_dados.last()).vr_vllanmto := 12.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12926779;
    v_dados(v_dados.last()).vr_nrctremp := 4118536;
    v_dados(v_dados.last()).vr_vllanmto := 292.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 4118776;
    v_dados(v_dados.last()).vr_vllanmto := 18.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12926779;
    v_dados(v_dados.last()).vr_nrctremp := 4121872;
    v_dados(v_dados.last()).vr_vllanmto := 15.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12860301;
    v_dados(v_dados.last()).vr_nrctremp := 4123564;
    v_dados(v_dados.last()).vr_vllanmto := 155.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8656126;
    v_dados(v_dados.last()).vr_nrctremp := 4130394;
    v_dados(v_dados.last()).vr_vllanmto := 109.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8390681;
    v_dados(v_dados.last()).vr_nrctremp := 4131111;
    v_dados(v_dados.last()).vr_vllanmto := 103.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12694541;
    v_dados(v_dados.last()).vr_nrctremp := 4133615;
    v_dados(v_dados.last()).vr_vllanmto := 319.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12948861;
    v_dados(v_dados.last()).vr_nrctremp := 4134890;
    v_dados(v_dados.last()).vr_vllanmto := 139.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12371297;
    v_dados(v_dados.last()).vr_nrctremp := 4139299;
    v_dados(v_dados.last()).vr_vllanmto := 95.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690392;
    v_dados(v_dados.last()).vr_nrctremp := 4139534;
    v_dados(v_dados.last()).vr_vllanmto := 182.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10412670;
    v_dados(v_dados.last()).vr_nrctremp := 4140383;
    v_dados(v_dados.last()).vr_vllanmto := 85.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 49.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10919597;
    v_dados(v_dados.last()).vr_nrctremp := 4141182;
    v_dados(v_dados.last()).vr_vllanmto := 81.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12731498;
    v_dados(v_dados.last()).vr_nrctremp := 4141397;
    v_dados(v_dados.last()).vr_vllanmto := 119.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12949353;
    v_dados(v_dados.last()).vr_nrctremp := 4148318;
    v_dados(v_dados.last()).vr_vllanmto := 33.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6613314;
    v_dados(v_dados.last()).vr_nrctremp := 4152976;
    v_dados(v_dados.last()).vr_vllanmto := 26.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 4153200;
    v_dados(v_dados.last()).vr_vllanmto := 13.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6613314;
    v_dados(v_dados.last()).vr_nrctremp := 4159437;
    v_dados(v_dados.last()).vr_vllanmto := 103.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12706523;
    v_dados(v_dados.last()).vr_nrctremp := 4160235;
    v_dados(v_dados.last()).vr_vllanmto := 450.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12943533;
    v_dados(v_dados.last()).vr_nrctremp := 4161475;
    v_dados(v_dados.last()).vr_vllanmto := 29.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12979236;
    v_dados(v_dados.last()).vr_nrctremp := 4161519;
    v_dados(v_dados.last()).vr_vllanmto := 18.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12701904;
    v_dados(v_dados.last()).vr_nrctremp := 4163680;
    v_dados(v_dados.last()).vr_vllanmto := 166.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11897805;
    v_dados(v_dados.last()).vr_nrctremp := 4164493;
    v_dados(v_dados.last()).vr_vllanmto := 121.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 4164558;
    v_dados(v_dados.last()).vr_vllanmto := 54.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9710604;
    v_dados(v_dados.last()).vr_nrctremp := 4164602;
    v_dados(v_dados.last()).vr_vllanmto := 49.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 4165540;
    v_dados(v_dados.last()).vr_vllanmto := 4467.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10571760;
    v_dados(v_dados.last()).vr_nrctremp := 4167462;
    v_dados(v_dados.last()).vr_vllanmto := 277.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12954101;
    v_dados(v_dados.last()).vr_nrctremp := 4169225;
    v_dados(v_dados.last()).vr_vllanmto := 35.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10012800;
    v_dados(v_dados.last()).vr_nrctremp := 4169565;
    v_dados(v_dados.last()).vr_vllanmto := 24.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11921005;
    v_dados(v_dados.last()).vr_nrctremp := 4170514;
    v_dados(v_dados.last()).vr_vllanmto := 53.36;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7374763;
    v_dados(v_dados.last()).vr_nrctremp := 4178604;
    v_dados(v_dados.last()).vr_vllanmto := 32.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12771317;
    v_dados(v_dados.last()).vr_nrctremp := 4181725;
    v_dados(v_dados.last()).vr_vllanmto := 128.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12833797;
    v_dados(v_dados.last()).vr_nrctremp := 4181782;
    v_dados(v_dados.last()).vr_vllanmto := 344.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12768898;
    v_dados(v_dados.last()).vr_nrctremp := 4181885;
    v_dados(v_dados.last()).vr_vllanmto := 203.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12897400;
    v_dados(v_dados.last()).vr_nrctremp := 4182034;
    v_dados(v_dados.last()).vr_vllanmto := 218.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12543004;
    v_dados(v_dados.last()).vr_nrctremp := 4182794;
    v_dados(v_dados.last()).vr_vllanmto := 80.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9191020;
    v_dados(v_dados.last()).vr_nrctremp := 4183332;
    v_dados(v_dados.last()).vr_vllanmto := 134.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7668058;
    v_dados(v_dados.last()).vr_nrctremp := 4183670;
    v_dados(v_dados.last()).vr_vllanmto := 69.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898651;
    v_dados(v_dados.last()).vr_nrctremp := 4188743;
    v_dados(v_dados.last()).vr_vllanmto := 400.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11453680;
    v_dados(v_dados.last()).vr_nrctremp := 4189966;
    v_dados(v_dados.last()).vr_vllanmto := 38.63;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10847103;
    v_dados(v_dados.last()).vr_nrctremp := 4190567;
    v_dados(v_dados.last()).vr_vllanmto := 151.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12363669;
    v_dados(v_dados.last()).vr_nrctremp := 4190975;
    v_dados(v_dados.last()).vr_vllanmto := 204.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8164509;
    v_dados(v_dados.last()).vr_nrctremp := 4193531;
    v_dados(v_dados.last()).vr_vllanmto := 186.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10245537;
    v_dados(v_dados.last()).vr_nrctremp := 4193713;
    v_dados(v_dados.last()).vr_vllanmto := 11.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2940523;
    v_dados(v_dados.last()).vr_nrctremp := 4193769;
    v_dados(v_dados.last()).vr_vllanmto := 230.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12632643;
    v_dados(v_dados.last()).vr_nrctremp := 4194374;
    v_dados(v_dados.last()).vr_vllanmto := 67.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12632643;
    v_dados(v_dados.last()).vr_nrctremp := 4194404;
    v_dados(v_dados.last()).vr_vllanmto := 70.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12632643;
    v_dados(v_dados.last()).vr_nrctremp := 4194437;
    v_dados(v_dados.last()).vr_vllanmto := 36.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12656925;
    v_dados(v_dados.last()).vr_nrctremp := 4194657;
    v_dados(v_dados.last()).vr_vllanmto := 182.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11762497;
    v_dados(v_dados.last()).vr_nrctremp := 4198938;
    v_dados(v_dados.last()).vr_vllanmto := 26.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4201717;
    v_dados(v_dados.last()).vr_vllanmto := 194.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12725480;
    v_dados(v_dados.last()).vr_nrctremp := 4202145;
    v_dados(v_dados.last()).vr_vllanmto := 280.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12756466;
    v_dados(v_dados.last()).vr_nrctremp := 4210230;
    v_dados(v_dados.last()).vr_vllanmto := 332.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13038699;
    v_dados(v_dados.last()).vr_nrctremp := 4210493;
    v_dados(v_dados.last()).vr_vllanmto := 126.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13038699;
    v_dados(v_dados.last()).vr_nrctremp := 4210518;
    v_dados(v_dados.last()).vr_vllanmto := 129.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4212320;
    v_dados(v_dados.last()).vr_vllanmto := 49.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 647012;
    v_dados(v_dados.last()).vr_nrctremp := 4215689;
    v_dados(v_dados.last()).vr_vllanmto := 125.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3709795;
    v_dados(v_dados.last()).vr_nrctremp := 4217193;
    v_dados(v_dados.last()).vr_vllanmto := 19.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12113743;
    v_dados(v_dados.last()).vr_nrctremp := 4221205;
    v_dados(v_dados.last()).vr_vllanmto := 296.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8719705;
    v_dados(v_dados.last()).vr_nrctremp := 4222466;
    v_dados(v_dados.last()).vr_vllanmto := 103.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3190820;
    v_dados(v_dados.last()).vr_nrctremp := 4222544;
    v_dados(v_dados.last()).vr_vllanmto := 61.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12390917;
    v_dados(v_dados.last()).vr_nrctremp := 4224342;
    v_dados(v_dados.last()).vr_vllanmto := 295.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12950750;
    v_dados(v_dados.last()).vr_nrctremp := 4224701;
    v_dados(v_dados.last()).vr_vllanmto := 189.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4226847;
    v_dados(v_dados.last()).vr_vllanmto := 170.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13063928;
    v_dados(v_dados.last()).vr_nrctremp := 4229022;
    v_dados(v_dados.last()).vr_vllanmto := 105.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12504998;
    v_dados(v_dados.last()).vr_nrctremp := 4229059;
    v_dados(v_dados.last()).vr_vllanmto := 203.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13063928;
    v_dados(v_dados.last()).vr_nrctremp := 4229064;
    v_dados(v_dados.last()).vr_vllanmto := 152.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13063928;
    v_dados(v_dados.last()).vr_nrctremp := 4229086;
    v_dados(v_dados.last()).vr_vllanmto := 32.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13063928;
    v_dados(v_dados.last()).vr_nrctremp := 4229100;
    v_dados(v_dados.last()).vr_vllanmto := 52.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12963941;
    v_dados(v_dados.last()).vr_nrctremp := 4232365;
    v_dados(v_dados.last()).vr_vllanmto := 338.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 98.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12869856;
    v_dados(v_dados.last()).vr_nrctremp := 4243645;
    v_dados(v_dados.last()).vr_vllanmto := 45.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12786675;
    v_dados(v_dados.last()).vr_nrctremp := 4243736;
    v_dados(v_dados.last()).vr_vllanmto := 337.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12953563;
    v_dados(v_dados.last()).vr_nrctremp := 4243776;
    v_dados(v_dados.last()).vr_vllanmto := 201.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12281220;
    v_dados(v_dados.last()).vr_nrctremp := 4244769;
    v_dados(v_dados.last()).vr_vllanmto := 11.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12412902;
    v_dados(v_dados.last()).vr_nrctremp := 4244848;
    v_dados(v_dados.last()).vr_vllanmto := 96.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11806222;
    v_dados(v_dados.last()).vr_nrctremp := 4245131;
    v_dados(v_dados.last()).vr_vllanmto := 215.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12810533;
    v_dados(v_dados.last()).vr_nrctremp := 4245483;
    v_dados(v_dados.last()).vr_vllanmto := 167.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13087525;
    v_dados(v_dados.last()).vr_nrctremp := 4248623;
    v_dados(v_dados.last()).vr_vllanmto := 10.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10866515;
    v_dados(v_dados.last()).vr_nrctremp := 4249800;
    v_dados(v_dados.last()).vr_vllanmto := 20.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389404;
    v_dados(v_dados.last()).vr_nrctremp := 4250955;
    v_dados(v_dados.last()).vr_vllanmto := 254.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12146870;
    v_dados(v_dados.last()).vr_nrctremp := 4251082;
    v_dados(v_dados.last()).vr_vllanmto := 74.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4252218;
    v_dados(v_dados.last()).vr_vllanmto := 15.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13101420;
    v_dados(v_dados.last()).vr_nrctremp := 4252745;
    v_dados(v_dados.last()).vr_vllanmto := 103.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13101820;
    v_dados(v_dados.last()).vr_nrctremp := 4252853;
    v_dados(v_dados.last()).vr_vllanmto := 77.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10491970;
    v_dados(v_dados.last()).vr_nrctremp := 4253223;
    v_dados(v_dados.last()).vr_vllanmto := 50.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12964719;
    v_dados(v_dados.last()).vr_nrctremp := 4253530;
    v_dados(v_dados.last()).vr_vllanmto := 209.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12730297;
    v_dados(v_dados.last()).vr_nrctremp := 4254328;
    v_dados(v_dados.last()).vr_vllanmto := 45.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13007319;
    v_dados(v_dados.last()).vr_nrctremp := 4255077;
    v_dados(v_dados.last()).vr_vllanmto := 164.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028847;
    v_dados(v_dados.last()).vr_nrctremp := 4256265;
    v_dados(v_dados.last()).vr_vllanmto := 292.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817678;
    v_dados(v_dados.last()).vr_nrctremp := 4256682;
    v_dados(v_dados.last()).vr_vllanmto := 449.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 183.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4267714;
    v_dados(v_dados.last()).vr_vllanmto := 226.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6337015;
    v_dados(v_dados.last()).vr_nrctremp := 4268513;
    v_dados(v_dados.last()).vr_vllanmto := 23.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13126288;
    v_dados(v_dados.last()).vr_nrctremp := 4269245;
    v_dados(v_dados.last()).vr_vllanmto := 131.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4270455;
    v_dados(v_dados.last()).vr_vllanmto := 234.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7532571;
    v_dados(v_dados.last()).vr_nrctremp := 4271105;
    v_dados(v_dados.last()).vr_vllanmto := 43.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13133039;
    v_dados(v_dados.last()).vr_nrctremp := 4273075;
    v_dados(v_dados.last()).vr_vllanmto := 245.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13131044;
    v_dados(v_dados.last()).vr_nrctremp := 4275417;
    v_dados(v_dados.last()).vr_vllanmto := 192.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10115218;
    v_dados(v_dados.last()).vr_nrctremp := 4275578;
    v_dados(v_dados.last()).vr_vllanmto := 36.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11875283;
    v_dados(v_dados.last()).vr_nrctremp := 4276059;
    v_dados(v_dados.last()).vr_vllanmto := 42.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13131044;
    v_dados(v_dados.last()).vr_nrctremp := 4277909;
    v_dados(v_dados.last()).vr_vllanmto := 12.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12768898;
    v_dados(v_dados.last()).vr_nrctremp := 4280143;
    v_dados(v_dados.last()).vr_vllanmto := 33.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028405;
    v_dados(v_dados.last()).vr_nrctremp := 4280212;
    v_dados(v_dados.last()).vr_vllanmto := 218.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11591609;
    v_dados(v_dados.last()).vr_nrctremp := 4294442;
    v_dados(v_dados.last()).vr_vllanmto := 60.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13014374;
    v_dados(v_dados.last()).vr_nrctremp := 4296706;
    v_dados(v_dados.last()).vr_vllanmto := 117.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13014374;
    v_dados(v_dados.last()).vr_nrctremp := 4296724;
    v_dados(v_dados.last()).vr_vllanmto := 28.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12407836;
    v_dados(v_dados.last()).vr_nrctremp := 4297701;
    v_dados(v_dados.last()).vr_vllanmto := 13.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2555433;
    v_dados(v_dados.last()).vr_nrctremp := 4298280;
    v_dados(v_dados.last()).vr_vllanmto := 60.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078793;
    v_dados(v_dados.last()).vr_nrctremp := 4301243;
    v_dados(v_dados.last()).vr_vllanmto := 62.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13023020;
    v_dados(v_dados.last()).vr_nrctremp := 4301698;
    v_dados(v_dados.last()).vr_vllanmto := 157.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12305804;
    v_dados(v_dados.last()).vr_nrctremp := 4302211;
    v_dados(v_dados.last()).vr_vllanmto := 23.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11941650;
    v_dados(v_dados.last()).vr_nrctremp := 4302378;
    v_dados(v_dados.last()).vr_vllanmto := 24.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116967;
    v_dados(v_dados.last()).vr_nrctremp := 4305664;
    v_dados(v_dados.last()).vr_vllanmto := 50.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3790622;
    v_dados(v_dados.last()).vr_nrctremp := 4307968;
    v_dados(v_dados.last()).vr_vllanmto := 318.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3626628;
    v_dados(v_dados.last()).vr_nrctremp := 4308386;
    v_dados(v_dados.last()).vr_vllanmto := 235.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1705660;
    v_dados(v_dados.last()).vr_nrctremp := 4310541;
    v_dados(v_dados.last()).vr_vllanmto := 22.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10799850;
    v_dados(v_dados.last()).vr_nrctremp := 4312290;
    v_dados(v_dados.last()).vr_vllanmto := 19.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10645292;
    v_dados(v_dados.last()).vr_nrctremp := 4312871;
    v_dados(v_dados.last()).vr_vllanmto := 24.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13184270;
    v_dados(v_dados.last()).vr_nrctremp := 4313478;
    v_dados(v_dados.last()).vr_vllanmto := 474.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8043949;
    v_dados(v_dados.last()).vr_nrctremp := 4321581;
    v_dados(v_dados.last()).vr_vllanmto := 136.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9016520;
    v_dados(v_dados.last()).vr_nrctremp := 4322559;
    v_dados(v_dados.last()).vr_vllanmto := 211.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 4322781;
    v_dados(v_dados.last()).vr_vllanmto := 13.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13202502;
    v_dados(v_dados.last()).vr_nrctremp := 4330143;
    v_dados(v_dados.last()).vr_vllanmto := 78.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7002203;
    v_dados(v_dados.last()).vr_nrctremp := 4334772;
    v_dados(v_dados.last()).vr_vllanmto := 60.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717351;
    v_dados(v_dados.last()).vr_nrctremp := 4336721;
    v_dados(v_dados.last()).vr_vllanmto := 108.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9210750;
    v_dados(v_dados.last()).vr_nrctremp := 4338371;
    v_dados(v_dados.last()).vr_vllanmto := 42.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11464747;
    v_dados(v_dados.last()).vr_nrctremp := 4338788;
    v_dados(v_dados.last()).vr_vllanmto := 33.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058466;
    v_dados(v_dados.last()).vr_nrctremp := 4339296;
    v_dados(v_dados.last()).vr_vllanmto := 83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9633316;
    v_dados(v_dados.last()).vr_nrctremp := 4343361;
    v_dados(v_dados.last()).vr_vllanmto := 199.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9380051;
    v_dados(v_dados.last()).vr_nrctremp := 4343440;
    v_dados(v_dados.last()).vr_vllanmto := 12.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230448;
    v_dados(v_dados.last()).vr_nrctremp := 4343680;
    v_dados(v_dados.last()).vr_vllanmto := 99.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12424463;
    v_dados(v_dados.last()).vr_nrctremp := 4343824;
    v_dados(v_dados.last()).vr_vllanmto := 235.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11044039;
    v_dados(v_dados.last()).vr_nrctremp := 4344288;
    v_dados(v_dados.last()).vr_vllanmto := 189.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12998052;
    v_dados(v_dados.last()).vr_nrctremp := 4346665;
    v_dados(v_dados.last()).vr_vllanmto := 203.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13032127;
    v_dados(v_dados.last()).vr_nrctremp := 4346766;
    v_dados(v_dados.last()).vr_vllanmto := 71.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13132504;
    v_dados(v_dados.last()).vr_nrctremp := 4346910;
    v_dados(v_dados.last()).vr_vllanmto := 279.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13096702;
    v_dados(v_dados.last()).vr_nrctremp := 4346981;
    v_dados(v_dados.last()).vr_vllanmto := 462.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13009389;
    v_dados(v_dados.last()).vr_nrctremp := 4348153;
    v_dados(v_dados.last()).vr_vllanmto := 511.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9822763;
    v_dados(v_dados.last()).vr_nrctremp := 4348332;
    v_dados(v_dados.last()).vr_vllanmto := 27.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116967;
    v_dados(v_dados.last()).vr_nrctremp := 4348356;
    v_dados(v_dados.last()).vr_vllanmto := 37.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11204800;
    v_dados(v_dados.last()).vr_nrctremp := 4349266;
    v_dados(v_dados.last()).vr_vllanmto := 15.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12891185;
    v_dados(v_dados.last()).vr_nrctremp := 4349609;
    v_dados(v_dados.last()).vr_vllanmto := 74.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12790079;
    v_dados(v_dados.last()).vr_nrctremp := 4349720;
    v_dados(v_dados.last()).vr_vllanmto := 496.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12957461;
    v_dados(v_dados.last()).vr_nrctremp := 4349766;
    v_dados(v_dados.last()).vr_vllanmto := 365.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773766;
    v_dados(v_dados.last()).vr_nrctremp := 4350017;
    v_dados(v_dados.last()).vr_vllanmto := 510.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10896384;
    v_dados(v_dados.last()).vr_nrctremp := 4357704;
    v_dados(v_dados.last()).vr_vllanmto := 128.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9939652;
    v_dados(v_dados.last()).vr_nrctremp := 4359983;
    v_dados(v_dados.last()).vr_vllanmto := 21.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4363932;
    v_dados(v_dados.last()).vr_vllanmto := 20.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4364882;
    v_dados(v_dados.last()).vr_vllanmto := 28.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4364951;
    v_dados(v_dados.last()).vr_vllanmto := 109.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4364977;
    v_dados(v_dados.last()).vr_vllanmto := 66.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4365012;
    v_dados(v_dados.last()).vr_vllanmto := 121.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12281220;
    v_dados(v_dados.last()).vr_nrctremp := 4366078;
    v_dados(v_dados.last()).vr_vllanmto := 60.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13244051;
    v_dados(v_dados.last()).vr_nrctremp := 4366155;
    v_dados(v_dados.last()).vr_vllanmto := 270.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8079625;
    v_dados(v_dados.last()).vr_nrctremp := 4366220;
    v_dados(v_dados.last()).vr_vllanmto := 120.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369283;
    v_dados(v_dados.last()).vr_vllanmto := 38.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369298;
    v_dados(v_dados.last()).vr_vllanmto := 85.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369330;
    v_dados(v_dados.last()).vr_vllanmto := 26.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369360;
    v_dados(v_dados.last()).vr_vllanmto := 41.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4374959;
    v_dados(v_dados.last()).vr_vllanmto := 64.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13110519;
    v_dados(v_dados.last()).vr_nrctremp := 4375141;
    v_dados(v_dados.last()).vr_vllanmto := 334.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13151088;
    v_dados(v_dados.last()).vr_nrctremp := 4375227;
    v_dados(v_dados.last()).vr_vllanmto := 529.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13087525;
    v_dados(v_dados.last()).vr_nrctremp := 4375284;
    v_dados(v_dados.last()).vr_vllanmto := 386.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12875023;
    v_dados(v_dados.last()).vr_nrctremp := 4375333;
    v_dados(v_dados.last()).vr_vllanmto := 252.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12407836;
    v_dados(v_dados.last()).vr_nrctremp := 4375361;
    v_dados(v_dados.last()).vr_vllanmto := 208.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7568266;
    v_dados(v_dados.last()).vr_nrctremp := 4375900;
    v_dados(v_dados.last()).vr_vllanmto := 477.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13246003;
    v_dados(v_dados.last()).vr_nrctremp := 4375937;
    v_dados(v_dados.last()).vr_vllanmto := 571.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12544515;
    v_dados(v_dados.last()).vr_nrctremp := 4376574;
    v_dados(v_dados.last()).vr_vllanmto := 25.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4376948;
    v_dados(v_dados.last()).vr_vllanmto := 23.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3500713;
    v_dados(v_dados.last()).vr_nrctremp := 4377724;
    v_dados(v_dados.last()).vr_vllanmto := 314.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4378452;
    v_dados(v_dados.last()).vr_vllanmto := 117.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13279424;
    v_dados(v_dados.last()).vr_nrctremp := 4389259;
    v_dados(v_dados.last()).vr_vllanmto := 95.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 56.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 397.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2710374;
    v_dados(v_dados.last()).vr_nrctremp := 4391409;
    v_dados(v_dados.last()).vr_vllanmto := 571.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9543490;
    v_dados(v_dados.last()).vr_nrctremp := 4391966;
    v_dados(v_dados.last()).vr_vllanmto := 93.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717017;
    v_dados(v_dados.last()).vr_nrctremp := 4394694;
    v_dados(v_dados.last()).vr_vllanmto := 33.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717017;
    v_dados(v_dados.last()).vr_nrctremp := 4400559;
    v_dados(v_dados.last()).vr_vllanmto := 224.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11747820;
    v_dados(v_dados.last()).vr_nrctremp := 4401141;
    v_dados(v_dados.last()).vr_vllanmto := 90.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11834021;
    v_dados(v_dados.last()).vr_nrctremp := 4407237;
    v_dados(v_dados.last()).vr_vllanmto := 74.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13305280;
    v_dados(v_dados.last()).vr_nrctremp := 4407480;
    v_dados(v_dados.last()).vr_vllanmto := 290.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13308173;
    v_dados(v_dados.last()).vr_nrctremp := 4409489;
    v_dados(v_dados.last()).vr_vllanmto := 631.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13171925;
    v_dados(v_dados.last()).vr_nrctremp := 4413068;
    v_dados(v_dados.last()).vr_vllanmto := 101.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4016041;
    v_dados(v_dados.last()).vr_nrctremp := 4413361;
    v_dados(v_dados.last()).vr_vllanmto := 104.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13314084;
    v_dados(v_dados.last()).vr_nrctremp := 4413621;
    v_dados(v_dados.last()).vr_vllanmto := 69.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 54.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10531769;
    v_dados(v_dados.last()).vr_nrctremp := 4414552;
    v_dados(v_dados.last()).vr_vllanmto := 67.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6940684;
    v_dados(v_dados.last()).vr_nrctremp := 4421220;
    v_dados(v_dados.last()).vr_vllanmto := 172.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13322362;
    v_dados(v_dados.last()).vr_nrctremp := 4422107;
    v_dados(v_dados.last()).vr_vllanmto := 60.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2296667;
    v_dados(v_dados.last()).vr_nrctremp := 4423623;
    v_dados(v_dados.last()).vr_vllanmto := 400.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6900950;
    v_dados(v_dados.last()).vr_nrctremp := 4423811;
    v_dados(v_dados.last()).vr_vllanmto := 137.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873853;
    v_dados(v_dados.last()).vr_nrctremp := 4426391;
    v_dados(v_dados.last()).vr_vllanmto := 59.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13177630;
    v_dados(v_dados.last()).vr_nrctremp := 4428083;
    v_dados(v_dados.last()).vr_vllanmto := 174.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6087370;
    v_dados(v_dados.last()).vr_nrctremp := 4428207;
    v_dados(v_dados.last()).vr_vllanmto := 303.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13068512;
    v_dados(v_dados.last()).vr_nrctremp := 4428289;
    v_dados(v_dados.last()).vr_vllanmto := 234.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 4430586;
    v_dados(v_dados.last()).vr_vllanmto := 216.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13145088;
    v_dados(v_dados.last()).vr_nrctremp := 4430603;
    v_dados(v_dados.last()).vr_vllanmto := 274.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9304444;
    v_dados(v_dados.last()).vr_nrctremp := 4434555;
    v_dados(v_dados.last()).vr_vllanmto := 139.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13253131;
    v_dados(v_dados.last()).vr_nrctremp := 4434759;
    v_dados(v_dados.last()).vr_vllanmto := 408.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8456445;
    v_dados(v_dados.last()).vr_nrctremp := 4438913;
    v_dados(v_dados.last()).vr_vllanmto := 83.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13147110;
    v_dados(v_dados.last()).vr_nrctremp := 4439926;
    v_dados(v_dados.last()).vr_vllanmto := 111.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13147110;
    v_dados(v_dados.last()).vr_nrctremp := 4439943;
    v_dados(v_dados.last()).vr_vllanmto := 170.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2415119;
    v_dados(v_dados.last()).vr_nrctremp := 4440402;
    v_dados(v_dados.last()).vr_vllanmto := 555.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10226745;
    v_dados(v_dados.last()).vr_nrctremp := 4440559;
    v_dados(v_dados.last()).vr_vllanmto := 26.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6788432;
    v_dados(v_dados.last()).vr_nrctremp := 4440698;
    v_dados(v_dados.last()).vr_vllanmto := 115.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739103;
    v_dados(v_dados.last()).vr_nrctremp := 4441023;
    v_dados(v_dados.last()).vr_vllanmto := 77.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11768614;
    v_dados(v_dados.last()).vr_nrctremp := 4441075;
    v_dados(v_dados.last()).vr_vllanmto := 20.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12654515;
    v_dados(v_dados.last()).vr_nrctremp := 4444398;
    v_dados(v_dados.last()).vr_vllanmto := 24.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7129599;
    v_dados(v_dados.last()).vr_nrctremp := 4444549;
    v_dados(v_dados.last()).vr_vllanmto := 13.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9942831;
    v_dados(v_dados.last()).vr_nrctremp := 4445492;
    v_dados(v_dados.last()).vr_vllanmto := 140.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12089613;
    v_dados(v_dados.last()).vr_nrctremp := 4445918;
    v_dados(v_dados.last()).vr_vllanmto := 355.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11327804;
    v_dados(v_dados.last()).vr_nrctremp := 4451368;
    v_dados(v_dados.last()).vr_vllanmto := 34.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12020192;
    v_dados(v_dados.last()).vr_nrctremp := 4452101;
    v_dados(v_dados.last()).vr_vllanmto := 290.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10637753;
    v_dados(v_dados.last()).vr_nrctremp := 4453483;
    v_dados(v_dados.last()).vr_vllanmto := 69.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13371240;
    v_dados(v_dados.last()).vr_nrctremp := 4453865;
    v_dados(v_dados.last()).vr_vllanmto := 65.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12947920;
    v_dados(v_dados.last()).vr_nrctremp := 4462306;
    v_dados(v_dados.last()).vr_vllanmto := 218.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13344048;
    v_dados(v_dados.last()).vr_nrctremp := 4462768;
    v_dados(v_dados.last()).vr_vllanmto := 423.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12823350;
    v_dados(v_dados.last()).vr_nrctremp := 4463112;
    v_dados(v_dados.last()).vr_vllanmto := 52.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 339.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466162;
    v_dados(v_dados.last()).vr_vllanmto := 28.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466176;
    v_dados(v_dados.last()).vr_vllanmto := 49.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466185;
    v_dados(v_dados.last()).vr_vllanmto := 231.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466200;
    v_dados(v_dados.last()).vr_vllanmto := 70.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466205;
    v_dados(v_dados.last()).vr_vllanmto := 63.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10112669;
    v_dados(v_dados.last()).vr_nrctremp := 4466246;
    v_dados(v_dados.last()).vr_vllanmto := 33.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6904360;
    v_dados(v_dados.last()).vr_nrctremp := 4469248;
    v_dados(v_dados.last()).vr_vllanmto := 210.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11780800;
    v_dados(v_dados.last()).vr_nrctremp := 4470682;
    v_dados(v_dados.last()).vr_vllanmto := 64.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4471080;
    v_dados(v_dados.last()).vr_vllanmto := 63.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10230602;
    v_dados(v_dados.last()).vr_nrctremp := 4472925;
    v_dados(v_dados.last()).vr_vllanmto := 140.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10465537;
    v_dados(v_dados.last()).vr_nrctremp := 4476841;
    v_dados(v_dados.last()).vr_vllanmto := 42.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9299386;
    v_dados(v_dados.last()).vr_nrctremp := 4477950;
    v_dados(v_dados.last()).vr_vllanmto := 19.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11778148;
    v_dados(v_dados.last()).vr_nrctremp := 4485845;
    v_dados(v_dados.last()).vr_vllanmto := 444.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11505184;
    v_dados(v_dados.last()).vr_nrctremp := 4486388;
    v_dados(v_dados.last()).vr_vllanmto := 1080.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488084;
    v_dados(v_dados.last()).vr_vllanmto := 52.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488103;
    v_dados(v_dados.last()).vr_vllanmto := 25.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488120;
    v_dados(v_dados.last()).vr_vllanmto := 40.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488129;
    v_dados(v_dados.last()).vr_vllanmto := 58.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488146;
    v_dados(v_dados.last()).vr_vllanmto := 29.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4488682;
    v_dados(v_dados.last()).vr_vllanmto := 31.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11761350;
    v_dados(v_dados.last()).vr_nrctremp := 4490149;
    v_dados(v_dados.last()).vr_vllanmto := 458.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9519947;
    v_dados(v_dados.last()).vr_nrctremp := 4492928;
    v_dados(v_dados.last()).vr_vllanmto := 313.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9189416;
    v_dados(v_dados.last()).vr_nrctremp := 4494116;
    v_dados(v_dados.last()).vr_vllanmto := 38.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 4494631;
    v_dados(v_dados.last()).vr_vllanmto := 28.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019216;
    v_dados(v_dados.last()).vr_nrctremp := 4496815;
    v_dados(v_dados.last()).vr_vllanmto := 191.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13223127;
    v_dados(v_dados.last()).vr_nrctremp := 4499370;
    v_dados(v_dados.last()).vr_vllanmto := 422.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209248;
    v_dados(v_dados.last()).vr_nrctremp := 4499591;
    v_dados(v_dados.last()).vr_vllanmto := 261.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 4499626;
    v_dados(v_dados.last()).vr_vllanmto := 23.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13151088;
    v_dados(v_dados.last()).vr_nrctremp := 4499659;
    v_dados(v_dados.last()).vr_vllanmto := 20.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 318.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13430980;
    v_dados(v_dados.last()).vr_nrctremp := 4499810;
    v_dados(v_dados.last()).vr_vllanmto := 149.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13430980;
    v_dados(v_dados.last()).vr_nrctremp := 4499826;
    v_dados(v_dados.last()).vr_vllanmto := 12.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13432109;
    v_dados(v_dados.last()).vr_nrctremp := 4500267;
    v_dados(v_dados.last()).vr_vllanmto := 60.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13432109;
    v_dados(v_dados.last()).vr_nrctremp := 4500293;
    v_dados(v_dados.last()).vr_vllanmto := 184.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13432109;
    v_dados(v_dados.last()).vr_nrctremp := 4500315;
    v_dados(v_dados.last()).vr_vllanmto := 54.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8762473;
    v_dados(v_dados.last()).vr_nrctremp := 4500533;
    v_dados(v_dados.last()).vr_vllanmto := 10.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12591424;
    v_dados(v_dados.last()).vr_nrctremp := 4502499;
    v_dados(v_dados.last()).vr_vllanmto := 36.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124129;
    v_dados(v_dados.last()).vr_nrctremp := 4502808;
    v_dados(v_dados.last()).vr_vllanmto := 405.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2525062;
    v_dados(v_dados.last()).vr_nrctremp := 4504730;
    v_dados(v_dados.last()).vr_vllanmto := 242.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 4505051;
    v_dados(v_dados.last()).vr_vllanmto := 207.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13189425;
    v_dados(v_dados.last()).vr_nrctremp := 4506686;
    v_dados(v_dados.last()).vr_vllanmto := 26.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8646813;
    v_dados(v_dados.last()).vr_nrctremp := 4510788;
    v_dados(v_dados.last()).vr_vllanmto := 55.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10464816;
    v_dados(v_dados.last()).vr_nrctremp := 4511327;
    v_dados(v_dados.last()).vr_vllanmto := 123.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13147110;
    v_dados(v_dados.last()).vr_nrctremp := 4511852;
    v_dados(v_dados.last()).vr_vllanmto := 58.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9206388;
    v_dados(v_dados.last()).vr_nrctremp := 4512209;
    v_dados(v_dados.last()).vr_vllanmto := 25.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11763744;
    v_dados(v_dados.last()).vr_nrctremp := 4513090;
    v_dados(v_dados.last()).vr_vllanmto := 668.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12943533;
    v_dados(v_dados.last()).vr_nrctremp := 4513694;
    v_dados(v_dados.last()).vr_vllanmto := 41.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11643951;
    v_dados(v_dados.last()).vr_nrctremp := 4514458;
    v_dados(v_dados.last()).vr_vllanmto := 335.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752916;
    v_dados(v_dados.last()).vr_nrctremp := 4519463;
    v_dados(v_dados.last()).vr_vllanmto := 49.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3595803;
    v_dados(v_dados.last()).vr_nrctremp := 4521182;
    v_dados(v_dados.last()).vr_vllanmto := 203.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10092366;
    v_dados(v_dados.last()).vr_nrctremp := 4521572;
    v_dados(v_dados.last()).vr_vllanmto := 125.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10360581;
    v_dados(v_dados.last()).vr_nrctremp := 4521812;
    v_dados(v_dados.last()).vr_vllanmto := 456.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595080;
    v_dados(v_dados.last()).vr_nrctremp := 4522660;
    v_dados(v_dados.last()).vr_vllanmto := 20.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9313516;
    v_dados(v_dados.last()).vr_nrctremp := 4523045;
    v_dados(v_dados.last()).vr_vllanmto := 89.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12860301;
    v_dados(v_dados.last()).vr_nrctremp := 4524843;
    v_dados(v_dados.last()).vr_vllanmto := 23.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9638997;
    v_dados(v_dados.last()).vr_nrctremp := 4527665;
    v_dados(v_dados.last()).vr_vllanmto := 365.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12508551;
    v_dados(v_dados.last()).vr_nrctremp := 4527754;
    v_dados(v_dados.last()).vr_vllanmto := 71.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065903;
    v_dados(v_dados.last()).vr_nrctremp := 4529120;
    v_dados(v_dados.last()).vr_vllanmto := 91.5;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9031308;
    v_dados(v_dados.last()).vr_nrctremp := 4529456;
    v_dados(v_dados.last()).vr_vllanmto := 92.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13253131;
    v_dados(v_dados.last()).vr_nrctremp := 4529887;
    v_dados(v_dados.last()).vr_vllanmto := 138.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11443120;
    v_dados(v_dados.last()).vr_nrctremp := 4530164;
    v_dados(v_dados.last()).vr_vllanmto := 45.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12694541;
    v_dados(v_dados.last()).vr_nrctremp := 4533400;
    v_dados(v_dados.last()).vr_vllanmto := 2523.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8923574;
    v_dados(v_dados.last()).vr_nrctremp := 4534970;
    v_dados(v_dados.last()).vr_vllanmto := 99.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9575448;
    v_dados(v_dados.last()).vr_nrctremp := 4535138;
    v_dados(v_dados.last()).vr_vllanmto := 47.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413887;
    v_dados(v_dados.last()).vr_nrctremp := 4535597;
    v_dados(v_dados.last()).vr_vllanmto := 124.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13197967;
    v_dados(v_dados.last()).vr_nrctremp := 4536802;
    v_dados(v_dados.last()).vr_vllanmto := 255.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10675515;
    v_dados(v_dados.last()).vr_nrctremp := 4539792;
    v_dados(v_dados.last()).vr_vllanmto := 134.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11862300;
    v_dados(v_dados.last()).vr_nrctremp := 4539802;
    v_dados(v_dados.last()).vr_vllanmto := 48.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13269518;
    v_dados(v_dados.last()).vr_nrctremp := 4540328;
    v_dados(v_dados.last()).vr_vllanmto := 145.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11449098;
    v_dados(v_dados.last()).vr_nrctremp := 4540377;
    v_dados(v_dados.last()).vr_vllanmto := 89.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80233066;
    v_dados(v_dados.last()).vr_nrctremp := 4542234;
    v_dados(v_dados.last()).vr_vllanmto := 102.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 4542269;
    v_dados(v_dados.last()).vr_vllanmto := 105.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10858768;
    v_dados(v_dados.last()).vr_nrctremp := 4542275;
    v_dados(v_dados.last()).vr_vllanmto := 121.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7532571;
    v_dados(v_dados.last()).vr_nrctremp := 4546847;
    v_dados(v_dados.last()).vr_vllanmto := 15.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11475587;
    v_dados(v_dados.last()).vr_nrctremp := 4547174;
    v_dados(v_dados.last()).vr_vllanmto := 57.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13499947;
    v_dados(v_dados.last()).vr_nrctremp := 4547840;
    v_dados(v_dados.last()).vr_vllanmto := 131.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11289848;
    v_dados(v_dados.last()).vr_nrctremp := 4556448;
    v_dados(v_dados.last()).vr_vllanmto := 122.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13381750;
    v_dados(v_dados.last()).vr_nrctremp := 4557518;
    v_dados(v_dados.last()).vr_vllanmto := 22.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12581151;
    v_dados(v_dados.last()).vr_nrctremp := 4557907;
    v_dados(v_dados.last()).vr_vllanmto := 191.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476651;
    v_dados(v_dados.last()).vr_nrctremp := 4558023;
    v_dados(v_dados.last()).vr_vllanmto := 94.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11875283;
    v_dados(v_dados.last()).vr_nrctremp := 4559125;
    v_dados(v_dados.last()).vr_vllanmto := 76.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9433171;
    v_dados(v_dados.last()).vr_nrctremp := 4559377;
    v_dados(v_dados.last()).vr_vllanmto := 137.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4083415;
    v_dados(v_dados.last()).vr_nrctremp := 4560639;
    v_dados(v_dados.last()).vr_vllanmto := 49.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9475354;
    v_dados(v_dados.last()).vr_nrctremp := 4564343;
    v_dados(v_dados.last()).vr_vllanmto := 126.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7864825;
    v_dados(v_dados.last()).vr_nrctremp := 4564568;
    v_dados(v_dados.last()).vr_vllanmto := 47.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13523252;
    v_dados(v_dados.last()).vr_nrctremp := 4564654;
    v_dados(v_dados.last()).vr_vllanmto := 118.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80100830;
    v_dados(v_dados.last()).vr_nrctremp := 4564808;
    v_dados(v_dados.last()).vr_vllanmto := 221.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6788580;
    v_dados(v_dados.last()).vr_nrctremp := 4566950;
    v_dados(v_dados.last()).vr_vllanmto := 102.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 227.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741741;
    v_dados(v_dados.last()).vr_nrctremp := 4570333;
    v_dados(v_dados.last()).vr_vllanmto := 137.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11152869;
    v_dados(v_dados.last()).vr_nrctremp := 4570581;
    v_dados(v_dados.last()).vr_vllanmto := 51.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11115289;
    v_dados(v_dados.last()).vr_nrctremp := 4571142;
    v_dados(v_dados.last()).vr_vllanmto := 189.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12309265;
    v_dados(v_dados.last()).vr_nrctremp := 4571378;
    v_dados(v_dados.last()).vr_vllanmto := 34.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11889195;
    v_dados(v_dados.last()).vr_nrctremp := 4571419;
    v_dados(v_dados.last()).vr_vllanmto := 64.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10831150;
    v_dados(v_dados.last()).vr_nrctremp := 4571633;
    v_dados(v_dados.last()).vr_vllanmto := 220.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573086;
    v_dados(v_dados.last()).vr_vllanmto := 81.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573101;
    v_dados(v_dados.last()).vr_vllanmto := 23.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573117;
    v_dados(v_dados.last()).vr_vllanmto := 220.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13316419;
    v_dados(v_dados.last()).vr_nrctremp := 4575351;
    v_dados(v_dados.last()).vr_vllanmto := 348.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576167;
    v_dados(v_dados.last()).vr_vllanmto := 252.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576196;
    v_dados(v_dados.last()).vr_vllanmto := 41.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576219;
    v_dados(v_dados.last()).vr_vllanmto := 31.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12825212;
    v_dados(v_dados.last()).vr_nrctremp := 4576380;
    v_dados(v_dados.last()).vr_vllanmto := 355.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9406352;
    v_dados(v_dados.last()).vr_nrctremp := 4576551;
    v_dados(v_dados.last()).vr_vllanmto := 66.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13437275;
    v_dados(v_dados.last()).vr_nrctremp := 4576677;
    v_dados(v_dados.last()).vr_vllanmto := 122.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 66.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8753822;
    v_dados(v_dados.last()).vr_nrctremp := 4577604;
    v_dados(v_dados.last()).vr_vllanmto := 77.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11929901;
    v_dados(v_dados.last()).vr_nrctremp := 4578088;
    v_dados(v_dados.last()).vr_vllanmto := 152.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11929901;
    v_dados(v_dados.last()).vr_nrctremp := 4578147;
    v_dados(v_dados.last()).vr_vllanmto := 33.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4020359;
    v_dados(v_dados.last()).vr_nrctremp := 4580510;
    v_dados(v_dados.last()).vr_vllanmto := 66.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10889833;
    v_dados(v_dados.last()).vr_nrctremp := 4581853;
    v_dados(v_dados.last()).vr_vllanmto := 117.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11228083;
    v_dados(v_dados.last()).vr_nrctremp := 4581982;
    v_dados(v_dados.last()).vr_vllanmto := 85.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13251201;
    v_dados(v_dados.last()).vr_nrctremp := 4582005;
    v_dados(v_dados.last()).vr_vllanmto := 218.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7692404;
    v_dados(v_dados.last()).vr_nrctremp := 4582645;
    v_dados(v_dados.last()).vr_vllanmto := 26.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569731;
    v_dados(v_dados.last()).vr_nrctremp := 4583142;
    v_dados(v_dados.last()).vr_vllanmto := 79.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10005528;
    v_dados(v_dados.last()).vr_nrctremp := 4583188;
    v_dados(v_dados.last()).vr_vllanmto := 60.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11615770;
    v_dados(v_dados.last()).vr_nrctremp := 4589257;
    v_dados(v_dados.last()).vr_vllanmto := 226.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12474444;
    v_dados(v_dados.last()).vr_nrctremp := 4592182;
    v_dados(v_dados.last()).vr_vllanmto := 17.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80139388;
    v_dados(v_dados.last()).vr_nrctremp := 4592374;
    v_dados(v_dados.last()).vr_vllanmto := 141.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 63.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11912138;
    v_dados(v_dados.last()).vr_nrctremp := 4598827;
    v_dados(v_dados.last()).vr_vllanmto := 21.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13579495;
    v_dados(v_dados.last()).vr_nrctremp := 4602900;
    v_dados(v_dados.last()).vr_vllanmto := 128.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6065317;
    v_dados(v_dados.last()).vr_nrctremp := 4604018;
    v_dados(v_dados.last()).vr_vllanmto := 78.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8638047;
    v_dados(v_dados.last()).vr_nrctremp := 4604082;
    v_dados(v_dados.last()).vr_vllanmto := 269.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8663700;
    v_dados(v_dados.last()).vr_nrctremp := 4604397;
    v_dados(v_dados.last()).vr_vllanmto := 54.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6927289;
    v_dados(v_dados.last()).vr_nrctremp := 4604542;
    v_dados(v_dados.last()).vr_vllanmto := 63.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11195541;
    v_dados(v_dados.last()).vr_nrctremp := 4604839;
    v_dados(v_dados.last()).vr_vllanmto := 279.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605327;
    v_dados(v_dados.last()).vr_vllanmto := 322.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605498;
    v_dados(v_dados.last()).vr_vllanmto := 88.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605658;
    v_dados(v_dados.last()).vr_vllanmto := 384.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3968944;
    v_dados(v_dados.last()).vr_nrctremp := 4606072;
    v_dados(v_dados.last()).vr_vllanmto := 252.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8033498;
    v_dados(v_dados.last()).vr_nrctremp := 4606131;
    v_dados(v_dados.last()).vr_vllanmto := 513.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584715;
    v_dados(v_dados.last()).vr_nrctremp := 4606375;
    v_dados(v_dados.last()).vr_vllanmto := 130.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7255195;
    v_dados(v_dados.last()).vr_nrctremp := 4609372;
    v_dados(v_dados.last()).vr_vllanmto := 44.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10785159;
    v_dados(v_dados.last()).vr_nrctremp := 4611211;
    v_dados(v_dados.last()).vr_vllanmto := 39.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 349.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10752188;
    v_dados(v_dados.last()).vr_nrctremp := 4616770;
    v_dados(v_dados.last()).vr_vllanmto := 68.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11820004;
    v_dados(v_dados.last()).vr_nrctremp := 4617074;
    v_dados(v_dados.last()).vr_vllanmto := 42.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13335464;
    v_dados(v_dados.last()).vr_nrctremp := 4617398;
    v_dados(v_dados.last()).vr_vllanmto := 379.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12897400;
    v_dados(v_dados.last()).vr_nrctremp := 4617687;
    v_dados(v_dados.last()).vr_vllanmto := 88.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683352;
    v_dados(v_dados.last()).vr_nrctremp := 4624468;
    v_dados(v_dados.last()).vr_vllanmto := 102.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875638;
    v_dados(v_dados.last()).vr_nrctremp := 4626907;
    v_dados(v_dados.last()).vr_vllanmto := 21.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6635369;
    v_dados(v_dados.last()).vr_nrctremp := 4627413;
    v_dados(v_dados.last()).vr_vllanmto := 42.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10204547;
    v_dados(v_dados.last()).vr_nrctremp := 4635900;
    v_dados(v_dados.last()).vr_vllanmto := 29.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9564330;
    v_dados(v_dados.last()).vr_nrctremp := 4636021;
    v_dados(v_dados.last()).vr_vllanmto := 1.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8357854;
    v_dados(v_dados.last()).vr_nrctremp := 4636849;
    v_dados(v_dados.last()).vr_vllanmto := 41.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6155677;
    v_dados(v_dados.last()).vr_nrctremp := 4638991;
    v_dados(v_dados.last()).vr_vllanmto := 25.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10940650;
    v_dados(v_dados.last()).vr_nrctremp := 4639145;
    v_dados(v_dados.last()).vr_vllanmto := 21.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13389408;
    v_dados(v_dados.last()).vr_nrctremp := 4639193;
    v_dados(v_dados.last()).vr_vllanmto := 508.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10748873;
    v_dados(v_dados.last()).vr_nrctremp := 4640120;
    v_dados(v_dados.last()).vr_vllanmto := 108.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356380;
    v_dados(v_dados.last()).vr_nrctremp := 4642262;
    v_dados(v_dados.last()).vr_vllanmto := 169.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3026450;
    v_dados(v_dados.last()).vr_nrctremp := 4642781;
    v_dados(v_dados.last()).vr_vllanmto := 262.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12125237;
    v_dados(v_dados.last()).vr_nrctremp := 4643457;
    v_dados(v_dados.last()).vr_vllanmto := 44.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12085243;
    v_dados(v_dados.last()).vr_nrctremp := 4644509;
    v_dados(v_dados.last()).vr_vllanmto := 34.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8171645;
    v_dados(v_dados.last()).vr_nrctremp := 4644755;
    v_dados(v_dados.last()).vr_vllanmto := 443.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13639080;
    v_dados(v_dados.last()).vr_nrctremp := 4644846;
    v_dados(v_dados.last()).vr_vllanmto := 46.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13639080;
    v_dados(v_dados.last()).vr_nrctremp := 4645059;
    v_dados(v_dados.last()).vr_vllanmto := 29.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8273332;
    v_dados(v_dados.last()).vr_nrctremp := 4648247;
    v_dados(v_dados.last()).vr_vllanmto := 82.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6942032;
    v_dados(v_dados.last()).vr_nrctremp := 4649636;
    v_dados(v_dados.last()).vr_vllanmto := 31.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11908637;
    v_dados(v_dados.last()).vr_nrctremp := 4650401;
    v_dados(v_dados.last()).vr_vllanmto := 119.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13481622;
    v_dados(v_dados.last()).vr_nrctremp := 4650705;
    v_dados(v_dados.last()).vr_vllanmto := 348.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12847089;
    v_dados(v_dados.last()).vr_nrctremp := 4651191;
    v_dados(v_dados.last()).vr_vllanmto := 48.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10412697;
    v_dados(v_dados.last()).vr_nrctremp := 4651714;
    v_dados(v_dados.last()).vr_vllanmto := 45.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658244;
    v_dados(v_dados.last()).vr_vllanmto := 71.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658270;
    v_dados(v_dados.last()).vr_vllanmto := 87.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658300;
    v_dados(v_dados.last()).vr_vllanmto := 110.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658324;
    v_dados(v_dados.last()).vr_vllanmto := 16.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658343;
    v_dados(v_dados.last()).vr_vllanmto := 288.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658410;
    v_dados(v_dados.last()).vr_vllanmto := 19.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13653555;
    v_dados(v_dados.last()).vr_nrctremp := 4659308;
    v_dados(v_dados.last()).vr_vllanmto := 37.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10443576;
    v_dados(v_dados.last()).vr_nrctremp := 4660368;
    v_dados(v_dados.last()).vr_vllanmto := 101.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10735224;
    v_dados(v_dados.last()).vr_nrctremp := 4660748;
    v_dados(v_dados.last()).vr_vllanmto := 75.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861056;
    v_dados(v_dados.last()).vr_nrctremp := 4660846;
    v_dados(v_dados.last()).vr_vllanmto := 318.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9474021;
    v_dados(v_dados.last()).vr_nrctremp := 4661418;
    v_dados(v_dados.last()).vr_vllanmto := 145.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13298216;
    v_dados(v_dados.last()).vr_nrctremp := 4662710;
    v_dados(v_dados.last()).vr_vllanmto := 294.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13659030;
    v_dados(v_dados.last()).vr_nrctremp := 4663143;
    v_dados(v_dados.last()).vr_vllanmto := 37.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413775;
    v_dados(v_dados.last()).vr_nrctremp := 4665968;
    v_dados(v_dados.last()).vr_vllanmto := 547.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666436;
    v_dados(v_dados.last()).vr_nrctremp := 4668416;
    v_dados(v_dados.last()).vr_vllanmto := 99.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 23370;
    v_dados(v_dados.last()).vr_nrctremp := 4672518;
    v_dados(v_dados.last()).vr_vllanmto := 26.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13440241;
    v_dados(v_dados.last()).vr_nrctremp := 4672702;
    v_dados(v_dados.last()).vr_vllanmto := 363.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80236987;
    v_dados(v_dados.last()).vr_nrctremp := 4673835;
    v_dados(v_dados.last()).vr_vllanmto := 132.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7914857;
    v_dados(v_dados.last()).vr_nrctremp := 4673930;
    v_dados(v_dados.last()).vr_vllanmto := 27.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13455435;
    v_dados(v_dados.last()).vr_nrctremp := 4674078;
    v_dados(v_dados.last()).vr_vllanmto := 78.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11576537;
    v_dados(v_dados.last()).vr_nrctremp := 4674681;
    v_dados(v_dados.last()).vr_vllanmto := 40.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11679956;
    v_dados(v_dados.last()).vr_nrctremp := 4674687;
    v_dados(v_dados.last()).vr_vllanmto := 67.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13569449;
    v_dados(v_dados.last()).vr_nrctremp := 4675199;
    v_dados(v_dados.last()).vr_vllanmto := 270.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666053;
    v_dados(v_dados.last()).vr_nrctremp := 4675309;
    v_dados(v_dados.last()).vr_vllanmto := 94.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10317694;
    v_dados(v_dados.last()).vr_nrctremp := 4677944;
    v_dados(v_dados.last()).vr_vllanmto := 127.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6891659;
    v_dados(v_dados.last()).vr_nrctremp := 4678799;
    v_dados(v_dados.last()).vr_vllanmto := 159;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665944;
    v_dados(v_dados.last()).vr_nrctremp := 4679297;
    v_dados(v_dados.last()).vr_vllanmto := 89.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9660143;
    v_dados(v_dados.last()).vr_nrctremp := 4680083;
    v_dados(v_dados.last()).vr_vllanmto := 109.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11786345;
    v_dados(v_dados.last()).vr_nrctremp := 4680798;
    v_dados(v_dados.last()).vr_vllanmto := 66.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601730;
    v_dados(v_dados.last()).vr_nrctremp := 4681371;
    v_dados(v_dados.last()).vr_vllanmto := 198.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12189227;
    v_dados(v_dados.last()).vr_nrctremp := 4683187;
    v_dados(v_dados.last()).vr_vllanmto := 17.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13686500;
    v_dados(v_dados.last()).vr_nrctremp := 4683743;
    v_dados(v_dados.last()).vr_vllanmto := 23.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8918600;
    v_dados(v_dados.last()).vr_nrctremp := 4684423;
    v_dados(v_dados.last()).vr_vllanmto := 342.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13689533;
    v_dados(v_dados.last()).vr_nrctremp := 4685615;
    v_dados(v_dados.last()).vr_vllanmto := 213.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10276505;
    v_dados(v_dados.last()).vr_nrctremp := 4685637;
    v_dados(v_dados.last()).vr_vllanmto := 100.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13689533;
    v_dados(v_dados.last()).vr_nrctremp := 4685660;
    v_dados(v_dados.last()).vr_vllanmto := 116.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10670807;
    v_dados(v_dados.last()).vr_nrctremp := 4692518;
    v_dados(v_dados.last()).vr_vllanmto := 75.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13217526;
    v_dados(v_dados.last()).vr_nrctremp := 4692786;
    v_dados(v_dados.last()).vr_vllanmto := 598.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11267690;
    v_dados(v_dados.last()).vr_nrctremp := 4693624;
    v_dados(v_dados.last()).vr_vllanmto := 78.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10442391;
    v_dados(v_dados.last()).vr_nrctremp := 4693678;
    v_dados(v_dados.last()).vr_vllanmto := 37.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8496293;
    v_dados(v_dados.last()).vr_nrctremp := 4694140;
    v_dados(v_dados.last()).vr_vllanmto := 160.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13638602;
    v_dados(v_dados.last()).vr_nrctremp := 4694444;
    v_dados(v_dados.last()).vr_vllanmto := 61.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9099638;
    v_dados(v_dados.last()).vr_nrctremp := 4694766;
    v_dados(v_dados.last()).vr_vllanmto := 124.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80340229;
    v_dados(v_dados.last()).vr_nrctremp := 4695007;
    v_dados(v_dados.last()).vr_vllanmto := 168.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124684;
    v_dados(v_dados.last()).vr_nrctremp := 4695113;
    v_dados(v_dados.last()).vr_vllanmto := 174.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12020397;
    v_dados(v_dados.last()).vr_nrctremp := 4695498;
    v_dados(v_dados.last()).vr_vllanmto := 208.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13006703;
    v_dados(v_dados.last()).vr_nrctremp := 4696585;
    v_dados(v_dados.last()).vr_vllanmto := 39.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2540495;
    v_dados(v_dados.last()).vr_nrctremp := 4699203;
    v_dados(v_dados.last()).vr_vllanmto := 47.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9199420;
    v_dados(v_dados.last()).vr_nrctremp := 4699390;
    v_dados(v_dados.last()).vr_vllanmto := 127.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9199420;
    v_dados(v_dados.last()).vr_nrctremp := 4699446;
    v_dados(v_dados.last()).vr_vllanmto := 126.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2425017;
    v_dados(v_dados.last()).vr_nrctremp := 4699506;
    v_dados(v_dados.last()).vr_vllanmto := 195.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4699843;
    v_dados(v_dados.last()).vr_vllanmto := 100.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13155997;
    v_dados(v_dados.last()).vr_nrctremp := 4701450;
    v_dados(v_dados.last()).vr_vllanmto := 100.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10115218;
    v_dados(v_dados.last()).vr_nrctremp := 4701497;
    v_dados(v_dados.last()).vr_vllanmto := 40.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8928029;
    v_dados(v_dados.last()).vr_nrctremp := 4702686;
    v_dados(v_dados.last()).vr_vllanmto := 34.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13343602;
    v_dados(v_dados.last()).vr_nrctremp := 4702720;
    v_dados(v_dados.last()).vr_vllanmto := 231.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := 141.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80434720;
    v_dados(v_dados.last()).vr_nrctremp := 4705785;
    v_dados(v_dados.last()).vr_vllanmto := 389.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665944;
    v_dados(v_dados.last()).vr_nrctremp := 4706959;
    v_dados(v_dados.last()).vr_vllanmto := 82.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10266402;
    v_dados(v_dados.last()).vr_nrctremp := 4707684;
    v_dados(v_dados.last()).vr_vllanmto := 64.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13536290;
    v_dados(v_dados.last()).vr_nrctremp := 4708727;
    v_dados(v_dados.last()).vr_vllanmto := 295.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6721087;
    v_dados(v_dados.last()).vr_nrctremp := 4708999;
    v_dados(v_dados.last()).vr_vllanmto := 17.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13726455;
    v_dados(v_dados.last()).vr_nrctremp := 4711789;
    v_dados(v_dados.last()).vr_vllanmto := 26.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10885471;
    v_dados(v_dados.last()).vr_nrctremp := 4712416;
    v_dados(v_dados.last()).vr_vllanmto := 93.81;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10265651;
    v_dados(v_dados.last()).vr_nrctremp := 4717159;
    v_dados(v_dados.last()).vr_vllanmto := 54.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 761885;
    v_dados(v_dados.last()).vr_nrctremp := 4725663;
    v_dados(v_dados.last()).vr_vllanmto := 69.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10099468;
    v_dados(v_dados.last()).vr_nrctremp := 4728864;
    v_dados(v_dados.last()).vr_vllanmto := 167.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9676902;
    v_dados(v_dados.last()).vr_nrctremp := 4729697;
    v_dados(v_dados.last()).vr_vllanmto := 56.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7770081;
    v_dados(v_dados.last()).vr_nrctremp := 4732196;
    v_dados(v_dados.last()).vr_vllanmto := 91.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13763890;
    v_dados(v_dados.last()).vr_nrctremp := 4739175;
    v_dados(v_dados.last()).vr_vllanmto := 114.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11691700;
    v_dados(v_dados.last()).vr_nrctremp := 4739813;
    v_dados(v_dados.last()).vr_vllanmto := 37.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10148795;
    v_dados(v_dados.last()).vr_nrctremp := 4740173;
    v_dados(v_dados.last()).vr_vllanmto := 32.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11484080;
    v_dados(v_dados.last()).vr_nrctremp := 4741094;
    v_dados(v_dados.last()).vr_vllanmto := 46.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12923419;
    v_dados(v_dados.last()).vr_nrctremp := 4741564;
    v_dados(v_dados.last()).vr_vllanmto := 39.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11951605;
    v_dados(v_dados.last()).vr_nrctremp := 4745153;
    v_dados(v_dados.last()).vr_vllanmto := 64.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9516298;
    v_dados(v_dados.last()).vr_nrctremp := 4745345;
    v_dados(v_dados.last()).vr_vllanmto := 22.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10534083;
    v_dados(v_dados.last()).vr_nrctremp := 4745410;
    v_dados(v_dados.last()).vr_vllanmto := 107.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8822905;
    v_dados(v_dados.last()).vr_nrctremp := 4746205;
    v_dados(v_dados.last()).vr_vllanmto := 46.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10355898;
    v_dados(v_dados.last()).vr_nrctremp := 4746635;
    v_dados(v_dados.last()).vr_vllanmto := 10.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4077008;
    v_dados(v_dados.last()).vr_nrctremp := 4746811;
    v_dados(v_dados.last()).vr_vllanmto := 77.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9322817;
    v_dados(v_dados.last()).vr_nrctremp := 4747166;
    v_dados(v_dados.last()).vr_vllanmto := 70.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13775421;
    v_dados(v_dados.last()).vr_nrctremp := 4748190;
    v_dados(v_dados.last()).vr_vllanmto := 75.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7204612;
    v_dados(v_dados.last()).vr_nrctremp := 4750120;
    v_dados(v_dados.last()).vr_vllanmto := 100.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2811030;
    v_dados(v_dados.last()).vr_nrctremp := 4751728;
    v_dados(v_dados.last()).vr_vllanmto := 107.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717017;
    v_dados(v_dados.last()).vr_nrctremp := 4751830;
    v_dados(v_dados.last()).vr_vllanmto := 52.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12377066;
    v_dados(v_dados.last()).vr_nrctremp := 4751942;
    v_dados(v_dados.last()).vr_vllanmto := 19.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584715;
    v_dados(v_dados.last()).vr_nrctremp := 4752371;
    v_dados(v_dados.last()).vr_vllanmto := 39.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10293345;
    v_dados(v_dados.last()).vr_nrctremp := 4753411;
    v_dados(v_dados.last()).vr_vllanmto := 77.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595373;
    v_dados(v_dados.last()).vr_nrctremp := 4753507;
    v_dados(v_dados.last()).vr_vllanmto := 112.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8912270;
    v_dados(v_dados.last()).vr_nrctremp := 4753775;
    v_dados(v_dados.last()).vr_vllanmto := 93.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6389643;
    v_dados(v_dados.last()).vr_nrctremp := 4754021;
    v_dados(v_dados.last()).vr_vllanmto := 37.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12439592;
    v_dados(v_dados.last()).vr_nrctremp := 4760725;
    v_dados(v_dados.last()).vr_vllanmto := 317.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13789538;
    v_dados(v_dados.last()).vr_nrctremp := 4761309;
    v_dados(v_dados.last()).vr_vllanmto := 119.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12288195;
    v_dados(v_dados.last()).vr_nrctremp := 4761996;
    v_dados(v_dados.last()).vr_vllanmto := 139.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80362419;
    v_dados(v_dados.last()).vr_nrctremp := 4762997;
    v_dados(v_dados.last()).vr_vllanmto := 140.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6786430;
    v_dados(v_dados.last()).vr_nrctremp := 4774963;
    v_dados(v_dados.last()).vr_vllanmto := 75.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12998052;
    v_dados(v_dados.last()).vr_nrctremp := 4777236;
    v_dados(v_dados.last()).vr_vllanmto := 81.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9681485;
    v_dados(v_dados.last()).vr_nrctremp := 4778228;
    v_dados(v_dados.last()).vr_vllanmto := 97.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10278630;
    v_dados(v_dados.last()).vr_nrctremp := 4778376;
    v_dados(v_dados.last()).vr_vllanmto := 212.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11887176;
    v_dados(v_dados.last()).vr_nrctremp := 4778799;
    v_dados(v_dados.last()).vr_vllanmto := 33.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209248;
    v_dados(v_dados.last()).vr_nrctremp := 4779286;
    v_dados(v_dados.last()).vr_vllanmto := 107.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11468610;
    v_dados(v_dados.last()).vr_nrctremp := 4779849;
    v_dados(v_dados.last()).vr_vllanmto := 90.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11468610;
    v_dados(v_dados.last()).vr_nrctremp := 4779906;
    v_dados(v_dados.last()).vr_vllanmto := 30.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637106;
    v_dados(v_dados.last()).vr_nrctremp := 4782826;
    v_dados(v_dados.last()).vr_vllanmto := 68.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12720828;
    v_dados(v_dados.last()).vr_nrctremp := 4783788;
    v_dados(v_dados.last()).vr_vllanmto := 41.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10432515;
    v_dados(v_dados.last()).vr_nrctremp := 4783814;
    v_dados(v_dados.last()).vr_vllanmto := 226.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10640622;
    v_dados(v_dados.last()).vr_nrctremp := 4784340;
    v_dados(v_dados.last()).vr_vllanmto := 38.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9064397;
    v_dados(v_dados.last()).vr_nrctremp := 4784897;
    v_dados(v_dados.last()).vr_vllanmto := 284.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13809849;
    v_dados(v_dados.last()).vr_nrctremp := 4790217;
    v_dados(v_dados.last()).vr_vllanmto := 156.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8060266;
    v_dados(v_dados.last()).vr_nrctremp := 4800878;
    v_dados(v_dados.last()).vr_vllanmto := 596.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9712666;
    v_dados(v_dados.last()).vr_nrctremp := 4801045;
    v_dados(v_dados.last()).vr_vllanmto := 57.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11070293;
    v_dados(v_dados.last()).vr_nrctremp := 4801285;
    v_dados(v_dados.last()).vr_vllanmto := 41.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6788580;
    v_dados(v_dados.last()).vr_nrctremp := 4802898;
    v_dados(v_dados.last()).vr_vllanmto := 183.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11892633;
    v_dados(v_dados.last()).vr_nrctremp := 4808955;
    v_dados(v_dados.last()).vr_vllanmto := 80.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11468610;
    v_dados(v_dados.last()).vr_nrctremp := 4809481;
    v_dados(v_dados.last()).vr_vllanmto := 23.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7187068;
    v_dados(v_dados.last()).vr_nrctremp := 4810669;
    v_dados(v_dados.last()).vr_vllanmto := 428.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12656992;
    v_dados(v_dados.last()).vr_nrctremp := 4813530;
    v_dados(v_dados.last()).vr_vllanmto := 21.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13855549;
    v_dados(v_dados.last()).vr_nrctremp := 4814043;
    v_dados(v_dados.last()).vr_vllanmto := 275.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4045645;
    v_dados(v_dados.last()).vr_nrctremp := 4815888;
    v_dados(v_dados.last()).vr_vllanmto := 98.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3721124;
    v_dados(v_dados.last()).vr_nrctremp := 4816442;
    v_dados(v_dados.last()).vr_vllanmto := 188.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 4821038;
    v_dados(v_dados.last()).vr_vllanmto := 46.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12324841;
    v_dados(v_dados.last()).vr_nrctremp := 4822507;
    v_dados(v_dados.last()).vr_vllanmto := 60.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266578;
    v_dados(v_dados.last()).vr_nrctremp := 4829270;
    v_dados(v_dados.last()).vr_vllanmto := 386.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4829674;
    v_dados(v_dados.last()).vr_vllanmto := 210.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10325727;
    v_dados(v_dados.last()).vr_nrctremp := 4829682;
    v_dados(v_dados.last()).vr_vllanmto := 136.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 4832937;
    v_dados(v_dados.last()).vr_vllanmto := 51.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8912270;
    v_dados(v_dados.last()).vr_nrctremp := 4837737;
    v_dados(v_dados.last()).vr_vllanmto := 47.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10636048;
    v_dados(v_dados.last()).vr_nrctremp := 4839172;
    v_dados(v_dados.last()).vr_vllanmto := 119.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13864793;
    v_dados(v_dados.last()).vr_nrctremp := 4843094;
    v_dados(v_dados.last()).vr_vllanmto := 102.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7136420;
    v_dados(v_dados.last()).vr_nrctremp := 4845394;
    v_dados(v_dados.last()).vr_vllanmto := 59.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13197967;
    v_dados(v_dados.last()).vr_nrctremp := 4846390;
    v_dados(v_dados.last()).vr_vllanmto := 39.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725190;
    v_dados(v_dados.last()).vr_nrctremp := 4846648;
    v_dados(v_dados.last()).vr_vllanmto := 51.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725262;
    v_dados(v_dados.last()).vr_nrctremp := 4846774;
    v_dados(v_dados.last()).vr_vllanmto := 173.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8737665;
    v_dados(v_dados.last()).vr_nrctremp := 4850258;
    v_dados(v_dados.last()).vr_vllanmto := 51.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 970000;
    v_dados(v_dados.last()).vr_nrctremp := 4851095;
    v_dados(v_dados.last()).vr_vllanmto := 709.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666053;
    v_dados(v_dados.last()).vr_nrctremp := 4852622;
    v_dados(v_dados.last()).vr_vllanmto := 63.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569871;
    v_dados(v_dados.last()).vr_nrctremp := 4855726;
    v_dados(v_dados.last()).vr_vllanmto := 112.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12143200;
    v_dados(v_dados.last()).vr_nrctremp := 4857588;
    v_dados(v_dados.last()).vr_vllanmto := 288.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13808702;
    v_dados(v_dados.last()).vr_nrctremp := 4858468;
    v_dados(v_dados.last()).vr_vllanmto := 170.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11675837;
    v_dados(v_dados.last()).vr_nrctremp := 4866685;
    v_dados(v_dados.last()).vr_vllanmto := 24.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9608710;
    v_dados(v_dados.last()).vr_nrctremp := 4871992;
    v_dados(v_dados.last()).vr_vllanmto := 69.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12771317;
    v_dados(v_dados.last()).vr_nrctremp := 4873794;
    v_dados(v_dados.last()).vr_vllanmto := 63.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8904375;
    v_dados(v_dados.last()).vr_nrctremp := 4874504;
    v_dados(v_dados.last()).vr_vllanmto := 115.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3637271;
    v_dados(v_dados.last()).vr_nrctremp := 4876229;
    v_dados(v_dados.last()).vr_vllanmto := 439.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12184390;
    v_dados(v_dados.last()).vr_nrctremp := 4879593;
    v_dados(v_dados.last()).vr_vllanmto := 65.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11183284;
    v_dados(v_dados.last()).vr_nrctremp := 4880547;
    v_dados(v_dados.last()).vr_vllanmto := 55.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9274456;
    v_dados(v_dados.last()).vr_nrctremp := 4881776;
    v_dados(v_dados.last()).vr_vllanmto := 125.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12219290;
    v_dados(v_dados.last()).vr_nrctremp := 4884313;
    v_dados(v_dados.last()).vr_vllanmto := 100.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4060768;
    v_dados(v_dados.last()).vr_nrctremp := 4884938;
    v_dados(v_dados.last()).vr_vllanmto := 299.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9561200;
    v_dados(v_dados.last()).vr_nrctremp := 4885076;
    v_dados(v_dados.last()).vr_vllanmto := 9194.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725580;
    v_dados(v_dados.last()).vr_nrctremp := 4885820;
    v_dados(v_dados.last()).vr_vllanmto := 361.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11449098;
    v_dados(v_dados.last()).vr_nrctremp := 4887179;
    v_dados(v_dados.last()).vr_vllanmto := 167.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11191945;
    v_dados(v_dados.last()).vr_nrctremp := 4887457;
    v_dados(v_dados.last()).vr_vllanmto := 290.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7486090;
    v_dados(v_dados.last()).vr_nrctremp := 4887550;
    v_dados(v_dados.last()).vr_vllanmto := 71.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13257676;
    v_dados(v_dados.last()).vr_nrctremp := 4889285;
    v_dados(v_dados.last()).vr_vllanmto := 38.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209035;
    v_dados(v_dados.last()).vr_nrctremp := 4890173;
    v_dados(v_dados.last()).vr_vllanmto := 30.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2458950;
    v_dados(v_dados.last()).vr_nrctremp := 4890823;
    v_dados(v_dados.last()).vr_vllanmto := 47.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13942689;
    v_dados(v_dados.last()).vr_nrctremp := 4892149;
    v_dados(v_dados.last()).vr_vllanmto := 49.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9626352;
    v_dados(v_dados.last()).vr_nrctremp := 4898022;
    v_dados(v_dados.last()).vr_vllanmto := 84.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2757222;
    v_dados(v_dados.last()).vr_nrctremp := 4899377;
    v_dados(v_dados.last()).vr_vllanmto := 20.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11035528;
    v_dados(v_dados.last()).vr_nrctremp := 4901280;
    v_dados(v_dados.last()).vr_vllanmto := 142.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11223332;
    v_dados(v_dados.last()).vr_nrctremp := 4901463;
    v_dados(v_dados.last()).vr_vllanmto := 125.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11009993;
    v_dados(v_dados.last()).vr_nrctremp := 4901511;
    v_dados(v_dados.last()).vr_vllanmto := 81.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13306138;
    v_dados(v_dados.last()).vr_nrctremp := 4901939;
    v_dados(v_dados.last()).vr_vllanmto := 360.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11751169;
    v_dados(v_dados.last()).vr_nrctremp := 4904813;
    v_dados(v_dados.last()).vr_vllanmto := 49.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8254346;
    v_dados(v_dados.last()).vr_nrctremp := 4907943;
    v_dados(v_dados.last()).vr_vllanmto := 83.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13171925;
    v_dados(v_dados.last()).vr_nrctremp := 4908378;
    v_dados(v_dados.last()).vr_vllanmto := 247.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13520563;
    v_dados(v_dados.last()).vr_nrctremp := 4909297;
    v_dados(v_dados.last()).vr_vllanmto := 264.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12278653;
    v_dados(v_dados.last()).vr_nrctremp := 4912772;
    v_dados(v_dados.last()).vr_vllanmto := 315.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665464;
    v_dados(v_dados.last()).vr_nrctremp := 4912942;
    v_dados(v_dados.last()).vr_vllanmto := 242.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7448619;
    v_dados(v_dados.last()).vr_nrctremp := 4914399;
    v_dados(v_dados.last()).vr_vllanmto := 20.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13581155;
    v_dados(v_dados.last()).vr_nrctremp := 4921029;
    v_dados(v_dados.last()).vr_vllanmto := 415.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80214479;
    v_dados(v_dados.last()).vr_nrctremp := 4921364;
    v_dados(v_dados.last()).vr_vllanmto := 625.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 773565;
    v_dados(v_dados.last()).vr_nrctremp := 4922540;
    v_dados(v_dados.last()).vr_vllanmto := 140.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11629410;
    v_dados(v_dados.last()).vr_nrctremp := 4924495;
    v_dados(v_dados.last()).vr_vllanmto := 58.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11262818;
    v_dados(v_dados.last()).vr_nrctremp := 4925150;
    v_dados(v_dados.last()).vr_vllanmto := 128.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9688854;
    v_dados(v_dados.last()).vr_nrctremp := 4934407;
    v_dados(v_dados.last()).vr_vllanmto := 62.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2984628;
    v_dados(v_dados.last()).vr_nrctremp := 4935932;
    v_dados(v_dados.last()).vr_vllanmto := 86.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11214317;
    v_dados(v_dados.last()).vr_nrctremp := 4937033;
    v_dados(v_dados.last()).vr_vllanmto := 63.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10340491;
    v_dados(v_dados.last()).vr_nrctremp := 4948791;
    v_dados(v_dados.last()).vr_vllanmto := 168.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13225146;
    v_dados(v_dados.last()).vr_nrctremp := 4950218;
    v_dados(v_dados.last()).vr_vllanmto := 422.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12651443;
    v_dados(v_dados.last()).vr_nrctremp := 4950509;
    v_dados(v_dados.last()).vr_vllanmto := 62.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2944227;
    v_dados(v_dados.last()).vr_nrctremp := 4953363;
    v_dados(v_dados.last()).vr_vllanmto := 84.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2019558;
    v_dados(v_dados.last()).vr_nrctremp := 4955785;
    v_dados(v_dados.last()).vr_vllanmto := 158.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13171925;
    v_dados(v_dados.last()).vr_nrctremp := 4955907;
    v_dados(v_dados.last()).vr_vllanmto := 18.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3672077;
    v_dados(v_dados.last()).vr_nrctremp := 4966918;
    v_dados(v_dados.last()).vr_vllanmto := 57.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9603611;
    v_dados(v_dados.last()).vr_nrctremp := 4967132;
    v_dados(v_dados.last()).vr_vllanmto := 133.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10787895;
    v_dados(v_dados.last()).vr_nrctremp := 4968778;
    v_dados(v_dados.last()).vr_vllanmto := 72.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13986708;
    v_dados(v_dados.last()).vr_nrctremp := 4969120;
    v_dados(v_dados.last()).vr_vllanmto := 85.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13768689;
    v_dados(v_dados.last()).vr_nrctremp := 4969255;
    v_dados(v_dados.last()).vr_vllanmto := 242.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11785837;
    v_dados(v_dados.last()).vr_nrctremp := 4974493;
    v_dados(v_dados.last()).vr_vllanmto := 157.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80115241;
    v_dados(v_dados.last()).vr_nrctremp := 4978930;
    v_dados(v_dados.last()).vr_vllanmto := 19.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3961630;
    v_dados(v_dados.last()).vr_nrctremp := 4984115;
    v_dados(v_dados.last()).vr_vllanmto := 324.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10804331;
    v_dados(v_dados.last()).vr_nrctremp := 4984188;
    v_dados(v_dados.last()).vr_vllanmto := 96.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682368;
    v_dados(v_dados.last()).vr_nrctremp := 4987449;
    v_dados(v_dados.last()).vr_vllanmto := 139.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13686500;
    v_dados(v_dados.last()).vr_nrctremp := 4987745;
    v_dados(v_dados.last()).vr_vllanmto := 15.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80234216;
    v_dados(v_dados.last()).vr_nrctremp := 4997069;
    v_dados(v_dados.last()).vr_vllanmto := 128.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9266178;
    v_dados(v_dados.last()).vr_nrctremp := 4997437;
    v_dados(v_dados.last()).vr_vllanmto := 107.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 5001668;
    v_dados(v_dados.last()).vr_vllanmto := 48.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12673161;
    v_dados(v_dados.last()).vr_nrctremp := 5009130;
    v_dados(v_dados.last()).vr_vllanmto := 52.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7860609;
    v_dados(v_dados.last()).vr_nrctremp := 5009730;
    v_dados(v_dados.last()).vr_vllanmto := 39.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 5014906;
    v_dados(v_dados.last()).vr_vllanmto := 104.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12141275;
    v_dados(v_dados.last()).vr_nrctremp := 5019971;
    v_dados(v_dados.last()).vr_vllanmto := 438.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7765002;
    v_dados(v_dados.last()).vr_nrctremp := 5020530;
    v_dados(v_dados.last()).vr_vllanmto := 176.72;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13923595;
    v_dados(v_dados.last()).vr_nrctremp := 5022137;
    v_dados(v_dados.last()).vr_vllanmto := 90.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14068184;
    v_dados(v_dados.last()).vr_nrctremp := 5022566;
    v_dados(v_dados.last()).vr_vllanmto := 46.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9352562;
    v_dados(v_dados.last()).vr_nrctremp := 5027319;
    v_dados(v_dados.last()).vr_vllanmto := 87.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12260657;
    v_dados(v_dados.last()).vr_nrctremp := 5027839;
    v_dados(v_dados.last()).vr_vllanmto := 58.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14075075;
    v_dados(v_dados.last()).vr_nrctremp := 5027859;
    v_dados(v_dados.last()).vr_vllanmto := 30.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11754079;
    v_dados(v_dados.last()).vr_nrctremp := 5034347;
    v_dados(v_dados.last()).vr_vllanmto := 172.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3140113;
    v_dados(v_dados.last()).vr_nrctremp := 5037859;
    v_dados(v_dados.last()).vr_vllanmto := 56.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80140939;
    v_dados(v_dados.last()).vr_nrctremp := 5042593;
    v_dados(v_dados.last()).vr_vllanmto := 31.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7494602;
    v_dados(v_dados.last()).vr_nrctremp := 5042656;
    v_dados(v_dados.last()).vr_vllanmto := 55.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13437275;
    v_dados(v_dados.last()).vr_nrctremp := 5043613;
    v_dados(v_dados.last()).vr_vllanmto := 329.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13641107;
    v_dados(v_dados.last()).vr_nrctremp := 5043888;
    v_dados(v_dados.last()).vr_vllanmto := 157.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14097605;
    v_dados(v_dados.last()).vr_nrctremp := 5045931;
    v_dados(v_dados.last()).vr_vllanmto := 136.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 5053220;
    v_dados(v_dados.last()).vr_vllanmto := 32.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2953412;
    v_dados(v_dados.last()).vr_nrctremp := 5060611;
    v_dados(v_dados.last()).vr_vllanmto := 2182.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12390917;
    v_dados(v_dados.last()).vr_nrctremp := 5060921;
    v_dados(v_dados.last()).vr_vllanmto := 86.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10223495;
    v_dados(v_dados.last()).vr_nrctremp := 5061087;
    v_dados(v_dados.last()).vr_vllanmto := 69.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11379014;
    v_dados(v_dados.last()).vr_nrctremp := 5061942;
    v_dados(v_dados.last()).vr_vllanmto := 955.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12343099;
    v_dados(v_dados.last()).vr_nrctremp := 5065328;
    v_dados(v_dados.last()).vr_vllanmto := 38.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9768076;
    v_dados(v_dados.last()).vr_nrctremp := 5068501;
    v_dados(v_dados.last()).vr_vllanmto := 104.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12869856;
    v_dados(v_dados.last()).vr_nrctremp := 5070594;
    v_dados(v_dados.last()).vr_vllanmto := 36.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 5076020;
    v_dados(v_dados.last()).vr_vllanmto := 182.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14134489;
    v_dados(v_dados.last()).vr_nrctremp := 5076228;
    v_dados(v_dados.last()).vr_vllanmto := 39.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14134489;
    v_dados(v_dados.last()).vr_nrctremp := 5076253;
    v_dados(v_dados.last()).vr_vllanmto := 186.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12801658;
    v_dados(v_dados.last()).vr_nrctremp := 5077570;
    v_dados(v_dados.last()).vr_vllanmto := 164.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12386952;
    v_dados(v_dados.last()).vr_nrctremp := 5077771;
    v_dados(v_dados.last()).vr_vllanmto := 13.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084027;
    v_dados(v_dados.last()).vr_vllanmto := 3.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084035;
    v_dados(v_dados.last()).vr_vllanmto := 1978.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084047;
    v_dados(v_dados.last()).vr_vllanmto := 4782.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084058;
    v_dados(v_dados.last()).vr_vllanmto := 7174.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80099920;
    v_dados(v_dados.last()).vr_nrctremp := 5085776;
    v_dados(v_dados.last()).vr_vllanmto := 166.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12514233;
    v_dados(v_dados.last()).vr_nrctremp := 5085830;
    v_dados(v_dados.last()).vr_vllanmto := 310.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12962066;
    v_dados(v_dados.last()).vr_nrctremp := 5086577;
    v_dados(v_dados.last()).vr_vllanmto := 21.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14074320;
    v_dados(v_dados.last()).vr_nrctremp := 5086593;
    v_dados(v_dados.last()).vr_vllanmto := 319.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12115819;
    v_dados(v_dados.last()).vr_nrctremp := 5092728;
    v_dados(v_dados.last()).vr_vllanmto := 246.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8034656;
    v_dados(v_dados.last()).vr_nrctremp := 5097439;
    v_dados(v_dados.last()).vr_vllanmto := 222.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898899;
    v_dados(v_dados.last()).vr_nrctremp := 5098127;
    v_dados(v_dados.last()).vr_vllanmto := 63.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12381020;
    v_dados(v_dados.last()).vr_nrctremp := 5103175;
    v_dados(v_dados.last()).vr_vllanmto := 38.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14169320;
    v_dados(v_dados.last()).vr_nrctremp := 5104679;
    v_dados(v_dados.last()).vr_vllanmto := 29.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13639080;
    v_dados(v_dados.last()).vr_nrctremp := 5104902;
    v_dados(v_dados.last()).vr_vllanmto := 160.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4038142;
    v_dados(v_dados.last()).vr_nrctremp := 5108831;
    v_dados(v_dados.last()).vr_vllanmto := 126.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9191674;
    v_dados(v_dados.last()).vr_nrctremp := 5119775;
    v_dados(v_dados.last()).vr_vllanmto := 294.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065067;
    v_dados(v_dados.last()).vr_nrctremp := 5120902;
    v_dados(v_dados.last()).vr_vllanmto := 161.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6890725;
    v_dados(v_dados.last()).vr_nrctremp := 5124524;
    v_dados(v_dados.last()).vr_vllanmto := 273.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 5125079;
    v_dados(v_dados.last()).vr_vllanmto := 19.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13925920;
    v_dados(v_dados.last()).vr_nrctremp := 5125957;
    v_dados(v_dados.last()).vr_vllanmto := 49.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10782524;
    v_dados(v_dados.last()).vr_nrctremp := 5126283;
    v_dados(v_dados.last()).vr_vllanmto := 191.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12141534;
    v_dados(v_dados.last()).vr_nrctremp := 5130609;
    v_dados(v_dados.last()).vr_vllanmto := 53.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8655529;
    v_dados(v_dados.last()).vr_nrctremp := 5131105;
    v_dados(v_dados.last()).vr_vllanmto := 1670.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9153055;
    v_dados(v_dados.last()).vr_nrctremp := 5132046;
    v_dados(v_dados.last()).vr_vllanmto := 195.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3710300;
    v_dados(v_dados.last()).vr_nrctremp := 5133807;
    v_dados(v_dados.last()).vr_vllanmto := 2473.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10615474;
    v_dados(v_dados.last()).vr_nrctremp := 5136571;
    v_dados(v_dados.last()).vr_vllanmto := 169.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7069774;
    v_dados(v_dados.last()).vr_nrctremp := 5137090;
    v_dados(v_dados.last()).vr_vllanmto := 197.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9697128;
    v_dados(v_dados.last()).vr_nrctremp := 5139065;
    v_dados(v_dados.last()).vr_vllanmto := 36.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10851925;
    v_dados(v_dados.last()).vr_nrctremp := 5141026;
    v_dados(v_dados.last()).vr_vllanmto := 166.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7310595;
    v_dados(v_dados.last()).vr_nrctremp := 5146936;
    v_dados(v_dados.last()).vr_vllanmto := 199.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12020397;
    v_dados(v_dados.last()).vr_nrctremp := 5153920;
    v_dados(v_dados.last()).vr_vllanmto := 39.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10066020;
    v_dados(v_dados.last()).vr_nrctremp := 5157236;
    v_dados(v_dados.last()).vr_vllanmto := 153.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12027413;
    v_dados(v_dados.last()).vr_nrctremp := 5157281;
    v_dados(v_dados.last()).vr_vllanmto := 36.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14134489;
    v_dados(v_dados.last()).vr_nrctremp := 5157927;
    v_dados(v_dados.last()).vr_vllanmto := 66.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10663452;
    v_dados(v_dados.last()).vr_nrctremp := 5158755;
    v_dados(v_dados.last()).vr_vllanmto := 698.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10077928;
    v_dados(v_dados.last()).vr_nrctremp := 5159124;
    v_dados(v_dados.last()).vr_vllanmto := 120.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11593059;
    v_dados(v_dados.last()).vr_nrctremp := 5159171;
    v_dados(v_dados.last()).vr_vllanmto := 32.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11401990;
    v_dados(v_dados.last()).vr_nrctremp := 5159727;
    v_dados(v_dados.last()).vr_vllanmto := 78.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9678697;
    v_dados(v_dados.last()).vr_nrctremp := 5161156;
    v_dados(v_dados.last()).vr_vllanmto := 85.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13236300;
    v_dados(v_dados.last()).vr_nrctremp := 5161998;
    v_dados(v_dados.last()).vr_vllanmto := 75.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14068184;
    v_dados(v_dados.last()).vr_nrctremp := 5162184;
    v_dados(v_dados.last()).vr_vllanmto := 184.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3158250;
    v_dados(v_dados.last()).vr_nrctremp := 5162841;
    v_dados(v_dados.last()).vr_vllanmto := 15.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12518581;
    v_dados(v_dados.last()).vr_nrctremp := 5165015;
    v_dados(v_dados.last()).vr_vllanmto := 170.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14261006;
    v_dados(v_dados.last()).vr_nrctremp := 5167737;
    v_dados(v_dados.last()).vr_vllanmto := 15.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14261006;
    v_dados(v_dados.last()).vr_nrctremp := 5167759;
    v_dados(v_dados.last()).vr_vllanmto := 45.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11253355;
    v_dados(v_dados.last()).vr_nrctremp := 5169313;
    v_dados(v_dados.last()).vr_vllanmto := 46.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7206895;
    v_dados(v_dados.last()).vr_nrctremp := 5170845;
    v_dados(v_dados.last()).vr_vllanmto := 109.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11720891;
    v_dados(v_dados.last()).vr_nrctremp := 5171881;
    v_dados(v_dados.last()).vr_vllanmto := 189.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7364695;
    v_dados(v_dados.last()).vr_nrctremp := 5172208;
    v_dados(v_dados.last()).vr_vllanmto := 234.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11165090;
    v_dados(v_dados.last()).vr_nrctremp := 5174995;
    v_dados(v_dados.last()).vr_vllanmto := 162.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11326379;
    v_dados(v_dados.last()).vr_nrctremp := 5181153;
    v_dados(v_dados.last()).vr_vllanmto := 145.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 5183107;
    v_dados(v_dados.last()).vr_vllanmto := 28.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11752440;
    v_dados(v_dados.last()).vr_nrctremp := 5185692;
    v_dados(v_dados.last()).vr_vllanmto := 70.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10596720;
    v_dados(v_dados.last()).vr_nrctremp := 5186410;
    v_dados(v_dados.last()).vr_vllanmto := 82.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12501514;
    v_dados(v_dados.last()).vr_nrctremp := 5189367;
    v_dados(v_dados.last()).vr_vllanmto := 160.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13023020;
    v_dados(v_dados.last()).vr_nrctremp := 5190011;
    v_dados(v_dados.last()).vr_vllanmto := 35.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3559548;
    v_dados(v_dados.last()).vr_nrctremp := 5191167;
    v_dados(v_dados.last()).vr_vllanmto := 137.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9666869;
    v_dados(v_dados.last()).vr_nrctremp := 5196774;
    v_dados(v_dados.last()).vr_vllanmto := 64.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11618191;
    v_dados(v_dados.last()).vr_nrctremp := 5198619;
    v_dados(v_dados.last()).vr_vllanmto := 26.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9708090;
    v_dados(v_dados.last()).vr_nrctremp := 5199517;
    v_dados(v_dados.last()).vr_vllanmto := 32.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14310562;
    v_dados(v_dados.last()).vr_nrctremp := 5199705;
    v_dados(v_dados.last()).vr_vllanmto := 39.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12981877;
    v_dados(v_dados.last()).vr_nrctremp := 5200658;
    v_dados(v_dados.last()).vr_vllanmto := 44.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12981230;
    v_dados(v_dados.last()).vr_nrctremp := 5202427;
    v_dados(v_dados.last()).vr_vllanmto := 46.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7750072;
    v_dados(v_dados.last()).vr_nrctremp := 5205891;
    v_dados(v_dados.last()).vr_vllanmto := 23.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13024205;
    v_dados(v_dados.last()).vr_nrctremp := 5215765;
    v_dados(v_dados.last()).vr_vllanmto := 39.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5216299;
    v_dados(v_dados.last()).vr_vllanmto := 154.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11768614;
    v_dados(v_dados.last()).vr_nrctremp := 5220110;
    v_dados(v_dados.last()).vr_vllanmto := 17.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12361283;
    v_dados(v_dados.last()).vr_nrctremp := 5220893;
    v_dados(v_dados.last()).vr_vllanmto := 17.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3183076;
    v_dados(v_dados.last()).vr_nrctremp := 5221443;
    v_dados(v_dados.last()).vr_vllanmto := 7618.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13709020;
    v_dados(v_dados.last()).vr_nrctremp := 5222855;
    v_dados(v_dados.last()).vr_vllanmto := 73.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13264729;
    v_dados(v_dados.last()).vr_nrctremp := 5225341;
    v_dados(v_dados.last()).vr_vllanmto := 12.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2825082;
    v_dados(v_dados.last()).vr_nrctremp := 5227375;
    v_dados(v_dados.last()).vr_vllanmto := 41.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11778598;
    v_dados(v_dados.last()).vr_nrctremp := 5233294;
    v_dados(v_dados.last()).vr_vllanmto := 24.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7214014;
    v_dados(v_dados.last()).vr_nrctremp := 5235680;
    v_dados(v_dados.last()).vr_vllanmto := 10.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12688665;
    v_dados(v_dados.last()).vr_nrctremp := 5246944;
    v_dados(v_dados.last()).vr_vllanmto := 11.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11943882;
    v_dados(v_dados.last()).vr_nrctremp := 5249785;
    v_dados(v_dados.last()).vr_vllanmto := 10.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716200;
    v_dados(v_dados.last()).vr_nrctremp := 5256443;
    v_dados(v_dados.last()).vr_vllanmto := 357.41;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6890725;
    v_dados(v_dados.last()).vr_nrctremp := 5279076;
    v_dados(v_dados.last()).vr_vllanmto := 11.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6669697;
    v_dados(v_dados.last()).vr_nrctremp := 5300474;
    v_dados(v_dados.last()).vr_vllanmto := 10.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9327320;
    v_dados(v_dados.last()).vr_nrctremp := 5307466;
    v_dados(v_dados.last()).vr_vllanmto := 13.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9819436;
    v_dados(v_dados.last()).vr_nrctremp := 5308137;
    v_dados(v_dados.last()).vr_vllanmto := 5677.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6587216;
    v_dados(v_dados.last()).vr_nrctremp := 5309033;
    v_dados(v_dados.last()).vr_vllanmto := 14.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10249168;
    v_dados(v_dados.last()).vr_nrctremp := 5311587;
    v_dados(v_dados.last()).vr_vllanmto := 17.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 62.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7283989;
    v_dados(v_dados.last()).vr_nrctremp := 571824979;
    v_dados(v_dados.last()).vr_vllanmto := 68.15;
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
