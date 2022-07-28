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
    v_dados(v_dados.last()).vr_vllanmto := 12.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8664668;
    v_dados(v_dados.last()).vr_nrctremp := 1881934;
    v_dados(v_dados.last()).vr_vllanmto := 18.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8513384;
    v_dados(v_dados.last()).vr_nrctremp := 1882819;
    v_dados(v_dados.last()).vr_vllanmto := 1.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093159;
    v_dados(v_dados.last()).vr_nrctremp := 1886421;
    v_dados(v_dados.last()).vr_vllanmto := 167.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098258;
    v_dados(v_dados.last()).vr_nrctremp := 1892259;
    v_dados(v_dados.last()).vr_vllanmto := 248.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10980113;
    v_dados(v_dados.last()).vr_nrctremp := 1893344;
    v_dados(v_dados.last()).vr_vllanmto := 25.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8142335;
    v_dados(v_dados.last()).vr_nrctremp := 1951712;
    v_dados(v_dados.last()).vr_vllanmto := 24.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7613466;
    v_dados(v_dados.last()).vr_nrctremp := 1979043;
    v_dados(v_dados.last()).vr_vllanmto := 34.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10493425;
    v_dados(v_dados.last()).vr_nrctremp := 1987643;
    v_dados(v_dados.last()).vr_vllanmto := 815.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80419461;
    v_dados(v_dados.last()).vr_nrctremp := 2005566;
    v_dados(v_dados.last()).vr_vllanmto := 27.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11109742;
    v_dados(v_dados.last()).vr_nrctremp := 2028302;
    v_dados(v_dados.last()).vr_vllanmto := 69.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8467595;
    v_dados(v_dados.last()).vr_nrctremp := 2041966;
    v_dados(v_dados.last()).vr_vllanmto := 12.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194460;
    v_dados(v_dados.last()).vr_nrctremp := 2114224;
    v_dados(v_dados.last()).vr_vllanmto := 114.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10349898;
    v_dados(v_dados.last()).vr_nrctremp := 2118569;
    v_dados(v_dados.last()).vr_vllanmto := 155.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9325743;
    v_dados(v_dados.last()).vr_nrctremp := 2073818;
    v_dados(v_dados.last()).vr_vllanmto := 1410.01;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193081;
    v_dados(v_dados.last()).vr_nrctremp := 2102720;
    v_dados(v_dados.last()).vr_vllanmto := 64.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037550;
    v_dados(v_dados.last()).vr_nrctremp := 2158838;
    v_dados(v_dados.last()).vr_vllanmto := 678.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533179;
    v_dados(v_dados.last()).vr_nrctremp := 2439337;
    v_dados(v_dados.last()).vr_vllanmto := 8.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10234225;
    v_dados(v_dados.last()).vr_nrctremp := 2123037;
    v_dados(v_dados.last()).vr_vllanmto := 184.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80091288;
    v_dados(v_dados.last()).vr_nrctremp := 2145249;
    v_dados(v_dados.last()).vr_vllanmto := 1329.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10776109;
    v_dados(v_dados.last()).vr_nrctremp := 2474174;
    v_dados(v_dados.last()).vr_vllanmto := 4.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11338148;
    v_dados(v_dados.last()).vr_nrctremp := 2527169;
    v_dados(v_dados.last()).vr_vllanmto := 6.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 2855130;
    v_dados(v_dados.last()).vr_vllanmto := 1.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2099195;
    v_dados(v_dados.last()).vr_nrctremp := 2883655;
    v_dados(v_dados.last()).vr_vllanmto := 19.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8840598;
    v_dados(v_dados.last()).vr_nrctremp := 2955363;
    v_dados(v_dados.last()).vr_vllanmto := 285.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10745319;
    v_dados(v_dados.last()).vr_nrctremp := 2955382;
    v_dados(v_dados.last()).vr_vllanmto := 23.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476260;
    v_dados(v_dados.last()).vr_nrctremp := 2816090;
    v_dados(v_dados.last()).vr_vllanmto := 2619.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9082530;
    v_dados(v_dados.last()).vr_nrctremp := 2955578;
    v_dados(v_dados.last()).vr_vllanmto := 236.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7519796;
    v_dados(v_dados.last()).vr_nrctremp := 2955918;
    v_dados(v_dados.last()).vr_vllanmto := 2.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6525610;
    v_dados(v_dados.last()).vr_nrctremp := 2891921;
    v_dados(v_dados.last()).vr_vllanmto := 435.3;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9612696;
    v_dados(v_dados.last()).vr_nrctremp := 2913350;
    v_dados(v_dados.last()).vr_vllanmto := 11419.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101062;
    v_dados(v_dados.last()).vr_nrctremp := 2955278;
    v_dados(v_dados.last()).vr_vllanmto := 113.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9563571;
    v_dados(v_dados.last()).vr_nrctremp := 2956027;
    v_dados(v_dados.last()).vr_vllanmto := 369.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7652704;
    v_dados(v_dados.last()).vr_nrctremp := 2955374;
    v_dados(v_dados.last()).vr_vllanmto := 112.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8120374;
    v_dados(v_dados.last()).vr_nrctremp := 2956126;
    v_dados(v_dados.last()).vr_vllanmto := 1.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356703;
    v_dados(v_dados.last()).vr_nrctremp := 2956154;
    v_dados(v_dados.last()).vr_vllanmto := 71.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2955709;
    v_dados(v_dados.last()).vr_vllanmto := 1699.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11703458;
    v_dados(v_dados.last()).vr_nrctremp := 3009568;
    v_dados(v_dados.last()).vr_vllanmto := 17.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8043124;
    v_dados(v_dados.last()).vr_nrctremp := 3024875;
    v_dados(v_dados.last()).vr_vllanmto := 99.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80214118;
    v_dados(v_dados.last()).vr_nrctremp := 2956035;
    v_dados(v_dados.last()).vr_vllanmto := 4588.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11858001;
    v_dados(v_dados.last()).vr_nrctremp := 3070526;
    v_dados(v_dados.last()).vr_vllanmto := 14.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 3178667;
    v_dados(v_dados.last()).vr_vllanmto := 1.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193537;
    v_dados(v_dados.last()).vr_nrctremp := 2956223;
    v_dados(v_dados.last()).vr_vllanmto := 59.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 2998837;
    v_dados(v_dados.last()).vr_vllanmto := 7624.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8177589;
    v_dados(v_dados.last()).vr_nrctremp := 3837514;
    v_dados(v_dados.last()).vr_vllanmto := 12.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 3023875;
    v_dados(v_dados.last()).vr_vllanmto := 6756.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13007319;
    v_dados(v_dados.last()).vr_nrctremp := 4255077;
    v_dados(v_dados.last()).vr_vllanmto := 18.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10338306;
    v_dados(v_dados.last()).vr_nrctremp := 3042647;
    v_dados(v_dados.last()).vr_vllanmto := 17187.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817678;
    v_dados(v_dados.last()).vr_nrctremp := 4256682;
    v_dados(v_dados.last()).vr_vllanmto := 67.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9349049;
    v_dados(v_dados.last()).vr_nrctremp := 3142973;
    v_dados(v_dados.last()).vr_vllanmto := 7057.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 19.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10886176;
    v_dados(v_dados.last()).vr_nrctremp := 3174348;
    v_dados(v_dados.last()).vr_vllanmto := 82.23;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4267714;
    v_dados(v_dados.last()).vr_vllanmto := 25.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9884955;
    v_dados(v_dados.last()).vr_nrctremp := 3253959;
    v_dados(v_dados.last()).vr_vllanmto := 29.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12166103;
    v_dados(v_dados.last()).vr_nrctremp := 3369926;
    v_dados(v_dados.last()).vr_vllanmto := 58592.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476260;
    v_dados(v_dados.last()).vr_nrctremp := 3458595;
    v_dados(v_dados.last()).vr_vllanmto := 1366.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10848029;
    v_dados(v_dados.last()).vr_nrctremp := 4290074;
    v_dados(v_dados.last()).vr_vllanmto := 2.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12407836;
    v_dados(v_dados.last()).vr_nrctremp := 4297701;
    v_dados(v_dados.last()).vr_vllanmto := 1.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2555433;
    v_dados(v_dados.last()).vr_nrctremp := 4298280;
    v_dados(v_dados.last()).vr_vllanmto := 13.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10799850;
    v_dados(v_dados.last()).vr_nrctremp := 4312290;
    v_dados(v_dados.last()).vr_vllanmto := .68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13184270;
    v_dados(v_dados.last()).vr_nrctremp := 4313478;
    v_dados(v_dados.last()).vr_vllanmto := 56.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 4322781;
    v_dados(v_dados.last()).vr_vllanmto := 2.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13202502;
    v_dados(v_dados.last()).vr_nrctremp := 4330143;
    v_dados(v_dados.last()).vr_vllanmto := 11.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7002203;
    v_dados(v_dados.last()).vr_nrctremp := 4334772;
    v_dados(v_dados.last()).vr_vllanmto := 21.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717351;
    v_dados(v_dados.last()).vr_nrctremp := 4336721;
    v_dados(v_dados.last()).vr_vllanmto := 13.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058466;
    v_dados(v_dados.last()).vr_nrctremp := 4339296;
    v_dados(v_dados.last()).vr_vllanmto := 11.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9633316;
    v_dados(v_dados.last()).vr_nrctremp := 4343361;
    v_dados(v_dados.last()).vr_vllanmto := 23.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230448;
    v_dados(v_dados.last()).vr_nrctremp := 4343680;
    v_dados(v_dados.last()).vr_vllanmto := 11.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12424463;
    v_dados(v_dados.last()).vr_nrctremp := 4343824;
    v_dados(v_dados.last()).vr_vllanmto := 31.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11044039;
    v_dados(v_dados.last()).vr_nrctremp := 4344288;
    v_dados(v_dados.last()).vr_vllanmto := 68.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12998052;
    v_dados(v_dados.last()).vr_nrctremp := 4346665;
    v_dados(v_dados.last()).vr_vllanmto := 30.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13032127;
    v_dados(v_dados.last()).vr_nrctremp := 4346766;
    v_dados(v_dados.last()).vr_vllanmto := 8.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13132504;
    v_dados(v_dados.last()).vr_nrctremp := 4346910;
    v_dados(v_dados.last()).vr_vllanmto := 36.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13096702;
    v_dados(v_dados.last()).vr_nrctremp := 4346981;
    v_dados(v_dados.last()).vr_vllanmto := 60.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13009389;
    v_dados(v_dados.last()).vr_nrctremp := 4348153;
    v_dados(v_dados.last()).vr_vllanmto := 66.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12891185;
    v_dados(v_dados.last()).vr_nrctremp := 4349609;
    v_dados(v_dados.last()).vr_vllanmto := 9.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12790079;
    v_dados(v_dados.last()).vr_nrctremp := 4349720;
    v_dados(v_dados.last()).vr_vllanmto := 66.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12957461;
    v_dados(v_dados.last()).vr_nrctremp := 4349766;
    v_dados(v_dados.last()).vr_vllanmto := 71.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773766;
    v_dados(v_dados.last()).vr_nrctremp := 4350017;
    v_dados(v_dados.last()).vr_vllanmto := 66.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4363932;
    v_dados(v_dados.last()).vr_vllanmto := 2.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4364977;
    v_dados(v_dados.last()).vr_vllanmto := 9.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12281220;
    v_dados(v_dados.last()).vr_nrctremp := 4366078;
    v_dados(v_dados.last()).vr_vllanmto := 10.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13244051;
    v_dados(v_dados.last()).vr_nrctremp := 4366155;
    v_dados(v_dados.last()).vr_vllanmto := 43.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369298;
    v_dados(v_dados.last()).vr_vllanmto := 10.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4374959;
    v_dados(v_dados.last()).vr_vllanmto := 8.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13110519;
    v_dados(v_dados.last()).vr_nrctremp := 4375141;
    v_dados(v_dados.last()).vr_vllanmto := 44.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13151088;
    v_dados(v_dados.last()).vr_nrctremp := 4375227;
    v_dados(v_dados.last()).vr_vllanmto := 82.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13087525;
    v_dados(v_dados.last()).vr_nrctremp := 4375284;
    v_dados(v_dados.last()).vr_vllanmto := 51.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12407836;
    v_dados(v_dados.last()).vr_nrctremp := 4375361;
    v_dados(v_dados.last()).vr_vllanmto := 27.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7568266;
    v_dados(v_dados.last()).vr_nrctremp := 4375900;
    v_dados(v_dados.last()).vr_vllanmto := 104.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13246003;
    v_dados(v_dados.last()).vr_nrctremp := 4375937;
    v_dados(v_dados.last()).vr_vllanmto := 88.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12544515;
    v_dados(v_dados.last()).vr_nrctremp := 4376574;
    v_dados(v_dados.last()).vr_vllanmto := 11.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3500713;
    v_dados(v_dados.last()).vr_nrctremp := 4377724;
    v_dados(v_dados.last()).vr_vllanmto := 43.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13279424;
    v_dados(v_dados.last()).vr_nrctremp := 4389259;
    v_dados(v_dados.last()).vr_vllanmto := 20.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 17.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2710374;
    v_dados(v_dados.last()).vr_nrctremp := 4391409;
    v_dados(v_dados.last()).vr_vllanmto := 79.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9543490;
    v_dados(v_dados.last()).vr_nrctremp := 4391966;
    v_dados(v_dados.last()).vr_vllanmto := 33.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717017;
    v_dados(v_dados.last()).vr_nrctremp := 4394694;
    v_dados(v_dados.last()).vr_vllanmto := 6.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11747820;
    v_dados(v_dados.last()).vr_nrctremp := 4401141;
    v_dados(v_dados.last()).vr_vllanmto := 18.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4016041;
    v_dados(v_dados.last()).vr_nrctremp := 4413361;
    v_dados(v_dados.last()).vr_vllanmto := 25.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13314084;
    v_dados(v_dados.last()).vr_nrctremp := 4413621;
    v_dados(v_dados.last()).vr_vllanmto := 9.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10531769;
    v_dados(v_dados.last()).vr_nrctremp := 4414552;
    v_dados(v_dados.last()).vr_vllanmto := 13.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13322362;
    v_dados(v_dados.last()).vr_nrctremp := 4422107;
    v_dados(v_dados.last()).vr_vllanmto := 8.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2296667;
    v_dados(v_dados.last()).vr_nrctremp := 4423623;
    v_dados(v_dados.last()).vr_vllanmto := 67.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13177630;
    v_dados(v_dados.last()).vr_nrctremp := 4428083;
    v_dados(v_dados.last()).vr_vllanmto := 24.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 4430586;
    v_dados(v_dados.last()).vr_vllanmto := 23.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13147110;
    v_dados(v_dados.last()).vr_nrctremp := 4439926;
    v_dados(v_dados.last()).vr_vllanmto := 13.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13344048;
    v_dados(v_dados.last()).vr_nrctremp := 4462768;
    v_dados(v_dados.last()).vr_vllanmto := 44.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 40.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4488682;
    v_dados(v_dados.last()).vr_vllanmto := 5.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 36.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13432109;
    v_dados(v_dados.last()).vr_nrctremp := 4500315;
    v_dados(v_dados.last()).vr_vllanmto := 4.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2525062;
    v_dados(v_dados.last()).vr_nrctremp := 4504730;
    v_dados(v_dados.last()).vr_vllanmto := 26.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752916;
    v_dados(v_dados.last()).vr_nrctremp := 4519463;
    v_dados(v_dados.last()).vr_vllanmto := 4.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595080;
    v_dados(v_dados.last()).vr_nrctremp := 4522660;
    v_dados(v_dados.last()).vr_vllanmto := 2.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12860301;
    v_dados(v_dados.last()).vr_nrctremp := 4524843;
    v_dados(v_dados.last()).vr_vllanmto := 3.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9638997;
    v_dados(v_dados.last()).vr_nrctremp := 4527665;
    v_dados(v_dados.last()).vr_vllanmto := 47.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13197967;
    v_dados(v_dados.last()).vr_nrctremp := 4536802;
    v_dados(v_dados.last()).vr_vllanmto := 32.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11862300;
    v_dados(v_dados.last()).vr_nrctremp := 4539802;
    v_dados(v_dados.last()).vr_vllanmto := 11.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13189425;
    v_dados(v_dados.last()).vr_nrctremp := 4506686;
    v_dados(v_dados.last()).vr_vllanmto := 26.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13269518;
    v_dados(v_dados.last()).vr_nrctremp := 4540328;
    v_dados(v_dados.last()).vr_vllanmto := 12.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6155057;
    v_dados(v_dados.last()).vr_nrctremp := 4520425;
    v_dados(v_dados.last()).vr_vllanmto := 2878.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 4542269;
    v_dados(v_dados.last()).vr_vllanmto := 16.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10858768;
    v_dados(v_dados.last()).vr_nrctremp := 4542275;
    v_dados(v_dados.last()).vr_vllanmto := 27.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7532571;
    v_dados(v_dados.last()).vr_nrctremp := 4546847;
    v_dados(v_dados.last()).vr_vllanmto := 3.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12694541;
    v_dados(v_dados.last()).vr_nrctremp := 4533400;
    v_dados(v_dados.last()).vr_vllanmto := 2523.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11475587;
    v_dados(v_dados.last()).vr_nrctremp := 4547174;
    v_dados(v_dados.last()).vr_vllanmto := 5.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13499947;
    v_dados(v_dados.last()).vr_nrctremp := 4547840;
    v_dados(v_dados.last()).vr_vllanmto := 18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7178565;
    v_dados(v_dados.last()).vr_nrctremp := 4556663;
    v_dados(v_dados.last()).vr_vllanmto := 15.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13381750;
    v_dados(v_dados.last()).vr_nrctremp := 4557518;
    v_dados(v_dados.last()).vr_vllanmto := 2.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 592838;
    v_dados(v_dados.last()).vr_nrctremp := 4557656;
    v_dados(v_dados.last()).vr_vllanmto := 4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476651;
    v_dados(v_dados.last()).vr_nrctremp := 4558023;
    v_dados(v_dados.last()).vr_vllanmto := 25.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4083415;
    v_dados(v_dados.last()).vr_nrctremp := 4560639;
    v_dados(v_dados.last()).vr_vllanmto := 11.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9475354;
    v_dados(v_dados.last()).vr_nrctremp := 4564343;
    v_dados(v_dados.last()).vr_vllanmto := 19.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7864825;
    v_dados(v_dados.last()).vr_nrctremp := 4564568;
    v_dados(v_dados.last()).vr_vllanmto := 10.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13523252;
    v_dados(v_dados.last()).vr_nrctremp := 4564654;
    v_dados(v_dados.last()).vr_vllanmto := 22.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 19.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11152869;
    v_dados(v_dados.last()).vr_nrctremp := 4570581;
    v_dados(v_dados.last()).vr_vllanmto := 8.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12309265;
    v_dados(v_dados.last()).vr_nrctremp := 4571378;
    v_dados(v_dados.last()).vr_vllanmto := 7.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11889195;
    v_dados(v_dados.last()).vr_nrctremp := 4571419;
    v_dados(v_dados.last()).vr_vllanmto := 5.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10831150;
    v_dados(v_dados.last()).vr_nrctremp := 4571633;
    v_dados(v_dados.last()).vr_vllanmto := 30.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576167;
    v_dados(v_dados.last()).vr_vllanmto := 12.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7206895;
    v_dados(v_dados.last()).vr_nrctremp := 4568549;
    v_dados(v_dados.last()).vr_vllanmto := 103.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576196;
    v_dados(v_dados.last()).vr_vllanmto := 8.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9406352;
    v_dados(v_dados.last()).vr_nrctremp := 4576551;
    v_dados(v_dados.last()).vr_vllanmto := 16.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13437275;
    v_dados(v_dados.last()).vr_nrctremp := 4576677;
    v_dados(v_dados.last()).vr_vllanmto := 10.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 8.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8753822;
    v_dados(v_dados.last()).vr_nrctremp := 4577604;
    v_dados(v_dados.last()).vr_vllanmto := 9.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11929901;
    v_dados(v_dados.last()).vr_nrctremp := 4578088;
    v_dados(v_dados.last()).vr_vllanmto := 18.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11929901;
    v_dados(v_dados.last()).vr_nrctremp := 4578147;
    v_dados(v_dados.last()).vr_vllanmto := 4.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4020359;
    v_dados(v_dados.last()).vr_nrctremp := 4580510;
    v_dados(v_dados.last()).vr_vllanmto := 15.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11228083;
    v_dados(v_dados.last()).vr_nrctremp := 4581982;
    v_dados(v_dados.last()).vr_vllanmto := 12.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13251201;
    v_dados(v_dados.last()).vr_nrctremp := 4582005;
    v_dados(v_dados.last()).vr_vllanmto := 19.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7692404;
    v_dados(v_dados.last()).vr_nrctremp := 4582645;
    v_dados(v_dados.last()).vr_vllanmto := 4.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569731;
    v_dados(v_dados.last()).vr_nrctremp := 4583142;
    v_dados(v_dados.last()).vr_vllanmto := 11.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10005528;
    v_dados(v_dados.last()).vr_nrctremp := 4583188;
    v_dados(v_dados.last()).vr_vllanmto := 9.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 14.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13579495;
    v_dados(v_dados.last()).vr_nrctremp := 4602900;
    v_dados(v_dados.last()).vr_vllanmto := 11.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6065317;
    v_dados(v_dados.last()).vr_nrctremp := 4604018;
    v_dados(v_dados.last()).vr_vllanmto := 11.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8663700;
    v_dados(v_dados.last()).vr_nrctremp := 4604397;
    v_dados(v_dados.last()).vr_vllanmto := 8.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6927289;
    v_dados(v_dados.last()).vr_nrctremp := 4604542;
    v_dados(v_dados.last()).vr_vllanmto := 9.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605498;
    v_dados(v_dados.last()).vr_vllanmto := 9.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8033498;
    v_dados(v_dados.last()).vr_nrctremp := 4606131;
    v_dados(v_dados.last()).vr_vllanmto := 3.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7255195;
    v_dados(v_dados.last()).vr_nrctremp := 4609372;
    v_dados(v_dados.last()).vr_vllanmto := 5.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10785159;
    v_dados(v_dados.last()).vr_nrctremp := 4611211;
    v_dados(v_dados.last()).vr_vllanmto := 5.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10752188;
    v_dados(v_dados.last()).vr_nrctremp := 4616770;
    v_dados(v_dados.last()).vr_vllanmto := 10.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11820004;
    v_dados(v_dados.last()).vr_nrctremp := 4617074;
    v_dados(v_dados.last()).vr_vllanmto := 6.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6635369;
    v_dados(v_dados.last()).vr_nrctremp := 4627413;
    v_dados(v_dados.last()).vr_vllanmto := 6.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12403148;
    v_dados(v_dados.last()).vr_nrctremp := 4605745;
    v_dados(v_dados.last()).vr_vllanmto := 650.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10204547;
    v_dados(v_dados.last()).vr_nrctremp := 4635900;
    v_dados(v_dados.last()).vr_vllanmto := 4.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13389408;
    v_dados(v_dados.last()).vr_nrctremp := 4639193;
    v_dados(v_dados.last()).vr_vllanmto := 11.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10748873;
    v_dados(v_dados.last()).vr_nrctremp := 4640120;
    v_dados(v_dados.last()).vr_vllanmto := 16.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12125237;
    v_dados(v_dados.last()).vr_nrctremp := 4643457;
    v_dados(v_dados.last()).vr_vllanmto := 4.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8273332;
    v_dados(v_dados.last()).vr_nrctremp := 4648247;
    v_dados(v_dados.last()).vr_vllanmto := 7.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875638;
    v_dados(v_dados.last()).vr_nrctremp := 4626907;
    v_dados(v_dados.last()).vr_vllanmto := 468.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6942032;
    v_dados(v_dados.last()).vr_nrctremp := 4649636;
    v_dados(v_dados.last()).vr_vllanmto := 5.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11908637;
    v_dados(v_dados.last()).vr_nrctremp := 4650401;
    v_dados(v_dados.last()).vr_vllanmto := 15.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9564330;
    v_dados(v_dados.last()).vr_nrctremp := 4636021;
    v_dados(v_dados.last()).vr_vllanmto := 1.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13481622;
    v_dados(v_dados.last()).vr_nrctremp := 4650705;
    v_dados(v_dados.last()).vr_vllanmto := 22.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10412697;
    v_dados(v_dados.last()).vr_nrctremp := 4651714;
    v_dados(v_dados.last()).vr_vllanmto := 10.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658244;
    v_dados(v_dados.last()).vr_vllanmto := 1.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13653555;
    v_dados(v_dados.last()).vr_nrctremp := 4659308;
    v_dados(v_dados.last()).vr_vllanmto := .11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10443576;
    v_dados(v_dados.last()).vr_nrctremp := 4660368;
    v_dados(v_dados.last()).vr_vllanmto := 3.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861056;
    v_dados(v_dados.last()).vr_nrctremp := 4660846;
    v_dados(v_dados.last()).vr_vllanmto := 4.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413775;
    v_dados(v_dados.last()).vr_nrctremp := 4665968;
    v_dados(v_dados.last()).vr_vllanmto := 12.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666436;
    v_dados(v_dados.last()).vr_nrctremp := 4668416;
    v_dados(v_dados.last()).vr_vllanmto := 12.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666053;
    v_dados(v_dados.last()).vr_nrctremp := 4675309;
    v_dados(v_dados.last()).vr_vllanmto := 2.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11786345;
    v_dados(v_dados.last()).vr_nrctremp := 4680798;
    v_dados(v_dados.last()).vr_vllanmto := 1.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := .89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10885471;
    v_dados(v_dados.last()).vr_nrctremp := 4712416;
    v_dados(v_dados.last()).vr_vllanmto := 1.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10265651;
    v_dados(v_dados.last()).vr_nrctremp := 4717159;
    v_dados(v_dados.last()).vr_vllanmto := 3.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4077008;
    v_dados(v_dados.last()).vr_nrctremp := 4746811;
    v_dados(v_dados.last()).vr_vllanmto := .31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7204612;
    v_dados(v_dados.last()).vr_nrctremp := 4750120;
    v_dados(v_dados.last()).vr_vllanmto := .58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9064397;
    v_dados(v_dados.last()).vr_nrctremp := 4784897;
    v_dados(v_dados.last()).vr_vllanmto := 5.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80346871;
    v_dados(v_dados.last()).vr_nrctremp := 2024567;
    v_dados(v_dados.last()).vr_vllanmto := 1.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80147194;
    v_dados(v_dados.last()).vr_nrctremp := 2040841;
    v_dados(v_dados.last()).vr_vllanmto := .85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 5.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9990100;
    v_dados(v_dados.last()).vr_nrctremp := 2784147;
    v_dados(v_dados.last()).vr_vllanmto := 79.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10819967;
    v_dados(v_dados.last()).vr_nrctremp := 3159652;
    v_dados(v_dados.last()).vr_vllanmto := 68.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12870307;
    v_dados(v_dados.last()).vr_nrctremp := 4155657;
    v_dados(v_dados.last()).vr_vllanmto := 21.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665464;
    v_dados(v_dados.last()).vr_nrctremp := 4912942;
    v_dados(v_dados.last()).vr_vllanmto := 23.56;
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
