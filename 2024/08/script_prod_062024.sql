DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro cecred.GENE0001.typ_tab_erro;
  vr_historic NUMBER(5);
  vr_lancamen NUMBER(25,2);

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
           ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
    SELECT
        ass.cdagenci,
        epr.inliquid,
        epr.inprejuz,
        CASE
            WHEN epr.inliquid = 1 AND epr.inprejuz = 0 THEN
                credito.obtersaldocontratoliquidadoconsignado(
                    pr_cdcooper => epr.cdcooper,
                    pr_nrdconta => epr.nrdconta,
                    pr_nrctremp => epr.nrctremp
                )
            ELSE
                0
        END AS saldo_contrato 
    FROM
      cecred.crapass ass,
      cecred.crapepr epr
    WHERE
        epr.cdcooper = ass.cdcooper
        AND epr.nrdconta = ass.nrdconta
        AND ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 765295;
  v_dados(v_dados.last()).vr_nrctremp := 7492262;
  v_dados(v_dados.last()).vr_vllanmto := 20209.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1927337;
  v_dados(v_dados.last()).vr_nrctremp := 5139328;
  v_dados(v_dados.last()).vr_vllanmto := 25128.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2314959;
  v_dados(v_dados.last()).vr_nrctremp := 6016390;
  v_dados(v_dados.last()).vr_vllanmto := 70.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2630133;
  v_dados(v_dados.last()).vr_nrctremp := 5645878;
  v_dados(v_dados.last()).vr_vllanmto := 312.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2747200;
  v_dados(v_dados.last()).vr_nrctremp := 5343342;
  v_dados(v_dados.last()).vr_vllanmto := 579.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2944227;
  v_dados(v_dados.last()).vr_nrctremp := 4953363;
  v_dados(v_dados.last()).vr_vllanmto := 2397.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3143880;
  v_dados(v_dados.last()).vr_nrctremp := 6839964;
  v_dados(v_dados.last()).vr_vllanmto := 5866.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3153886;
  v_dados(v_dados.last()).vr_nrctremp := 6748175;
  v_dados(v_dados.last()).vr_vllanmto := 1771.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3595803;
  v_dados(v_dados.last()).vr_nrctremp := 4521182;
  v_dados(v_dados.last()).vr_vllanmto := 177.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3642348;
  v_dados(v_dados.last()).vr_nrctremp := 8142197;
  v_dados(v_dados.last()).vr_vllanmto := 3664.29;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3721124;
  v_dados(v_dados.last()).vr_nrctremp := 4816442;
  v_dados(v_dados.last()).vr_vllanmto := 3764.04;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4045645;
  v_dados(v_dados.last()).vr_nrctremp := 4815888;
  v_dados(v_dados.last()).vr_vllanmto := 4093.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4059646;
  v_dados(v_dados.last()).vr_nrctremp := 6678413;
  v_dados(v_dados.last()).vr_vllanmto := 42.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4077008;
  v_dados(v_dados.last()).vr_nrctremp := 6068501;
  v_dados(v_dados.last()).vr_vllanmto := 25.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7187068;
  v_dados(v_dados.last()).vr_nrctremp := 4810669;
  v_dados(v_dados.last()).vr_vllanmto := 6508.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7206895;
  v_dados(v_dados.last()).vr_nrctremp := 5170845;
  v_dados(v_dados.last()).vr_vllanmto := 476.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7374763;
  v_dados(v_dados.last()).vr_nrctremp := 4178604;
  v_dados(v_dados.last()).vr_vllanmto := 288.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7505272;
  v_dados(v_dados.last()).vr_nrctremp := 7873471;
  v_dados(v_dados.last()).vr_vllanmto := 4699.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7533179;
  v_dados(v_dados.last()).vr_nrctremp := 2439337;
  v_dados(v_dados.last()).vr_vllanmto := 93.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7580592;
  v_dados(v_dados.last()).vr_nrctremp := 7433877;
  v_dados(v_dados.last()).vr_vllanmto := 15.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7695306;
  v_dados(v_dados.last()).vr_nrctremp := 7709609;
  v_dados(v_dados.last()).vr_vllanmto := 252.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7914857;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 1238.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7955260;
  v_dados(v_dados.last()).vr_nrctremp := 6712054;
  v_dados(v_dados.last()).vr_vllanmto := 137.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8111383;
  v_dados(v_dados.last()).vr_nrctremp := 3805450;
  v_dados(v_dados.last()).vr_vllanmto := 33.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8171645;
  v_dados(v_dados.last()).vr_nrctremp := 4644755;
  v_dados(v_dados.last()).vr_vllanmto := 2278.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 4101609;
  v_dados(v_dados.last()).vr_vllanmto := 1399.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 6131009;
  v_dados(v_dados.last()).vr_vllanmto := 2626.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8663700;
  v_dados(v_dados.last()).vr_nrctremp := 4604397;
  v_dados(v_dados.last()).vr_vllanmto := 41.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8727880;
  v_dados(v_dados.last()).vr_nrctremp := 5373802;
  v_dados(v_dados.last()).vr_vllanmto := 357.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9038760;
  v_dados(v_dados.last()).vr_nrctremp := 2985651;
  v_dados(v_dados.last()).vr_vllanmto := 14403.69;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9069887;
  v_dados(v_dados.last()).vr_nrctremp := 6755955;
  v_dados(v_dados.last()).vr_vllanmto := 28.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9070079;
  v_dados(v_dados.last()).vr_nrctremp := 2972625;
  v_dados(v_dados.last()).vr_vllanmto := 90.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9088741;
  v_dados(v_dados.last()).vr_nrctremp := 6016044;
  v_dados(v_dados.last()).vr_vllanmto := 893.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9193081;
  v_dados(v_dados.last()).vr_nrctremp := 6727435;
  v_dados(v_dados.last()).vr_vllanmto := 35.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9346155;
  v_dados(v_dados.last()).vr_nrctremp := 5782934;
  v_dados(v_dados.last()).vr_vllanmto := 138.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9348808;
  v_dados(v_dados.last()).vr_nrctremp := 5959615;
  v_dados(v_dados.last()).vr_vllanmto := 460.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9355146;
  v_dados(v_dados.last()).vr_nrctremp := 2728862;
  v_dados(v_dados.last()).vr_vllanmto := 1044.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9450572;
  v_dados(v_dados.last()).vr_nrctremp := 6930833;
  v_dados(v_dados.last()).vr_vllanmto := 1558.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9475354;
  v_dados(v_dados.last()).vr_nrctremp := 4564343;
  v_dados(v_dados.last()).vr_vllanmto := 141.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9503250;
  v_dados(v_dados.last()).vr_nrctremp := 6238730;
  v_dados(v_dados.last()).vr_vllanmto := 170.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9561200;
  v_dados(v_dados.last()).vr_nrctremp := 6084116;
  v_dados(v_dados.last()).vr_vllanmto := 4087.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9575448;
  v_dados(v_dados.last()).vr_nrctremp := 4535138;
  v_dados(v_dados.last()).vr_vllanmto := 1305.25;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9578560;
  v_dados(v_dados.last()).vr_nrctremp := 5651697;
  v_dados(v_dados.last()).vr_vllanmto := 122.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9633316;
  v_dados(v_dados.last()).vr_nrctremp := 4343361;
  v_dados(v_dados.last()).vr_vllanmto := 3498.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9660143;
  v_dados(v_dados.last()).vr_nrctremp := 4680083;
  v_dados(v_dados.last()).vr_vllanmto := 3532.66;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9688854;
  v_dados(v_dados.last()).vr_nrctremp := 4934407;
  v_dados(v_dados.last()).vr_vllanmto := 39.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9708090;
  v_dados(v_dados.last()).vr_nrctremp := 5199517;
  v_dados(v_dados.last()).vr_vllanmto := 309.1;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 4801045;
  v_dados(v_dados.last()).vr_vllanmto := 877.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 6631120;
  v_dados(v_dados.last()).vr_vllanmto := 486.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9739289;
  v_dados(v_dados.last()).vr_nrctremp := 5378221;
  v_dados(v_dados.last()).vr_vllanmto := 767.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9875638;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 1329.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9942831;
  v_dados(v_dados.last()).vr_nrctremp := 4445492;
  v_dados(v_dados.last()).vr_vllanmto := 4102.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9958070;
  v_dados(v_dados.last()).vr_nrctremp := 5848326;
  v_dados(v_dados.last()).vr_vllanmto := 5103.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10065903;
  v_dados(v_dados.last()).vr_nrctremp := 4529120;
  v_dados(v_dados.last()).vr_vllanmto := 105.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10115218;
  v_dados(v_dados.last()).vr_nrctremp := 6053088;
  v_dados(v_dados.last()).vr_vllanmto := 1555.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10245537;
  v_dados(v_dados.last()).vr_nrctremp := 4193713;
  v_dados(v_dados.last()).vr_vllanmto := 223.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10251138;
  v_dados(v_dados.last()).vr_nrctremp := 5345929;
  v_dados(v_dados.last()).vr_vllanmto := 1801.48;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10256881;
  v_dados(v_dados.last()).vr_nrctremp := 5319811;
  v_dados(v_dados.last()).vr_vllanmto := 47.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10275860;
  v_dados(v_dados.last()).vr_nrctremp := 4241038;
  v_dados(v_dados.last()).vr_vllanmto := 6219.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10293345;
  v_dados(v_dados.last()).vr_nrctremp := 4753411;
  v_dados(v_dados.last()).vr_vllanmto := 736.11;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 4677944;
  v_dados(v_dados.last()).vr_vllanmto := 4980.39;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 5587986;
  v_dados(v_dados.last()).vr_vllanmto := 1632.36;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10373179;
  v_dados(v_dados.last()).vr_nrctremp := 6464042;
  v_dados(v_dados.last()).vr_vllanmto := 499.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10465537;
  v_dados(v_dados.last()).vr_nrctremp := 4476841;
  v_dados(v_dados.last()).vr_vllanmto := 4051.54;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10509631;
  v_dados(v_dados.last()).vr_nrctremp := 6787302;
  v_dados(v_dados.last()).vr_vllanmto := 1141.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10550178;
  v_dados(v_dados.last()).vr_nrctremp := 7064740;
  v_dados(v_dados.last()).vr_vllanmto := 41.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10568980;
  v_dados(v_dados.last()).vr_nrctremp := 7341376;
  v_dados(v_dados.last()).vr_vllanmto := 65.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10576363;
  v_dados(v_dados.last()).vr_nrctremp := 6624901;
  v_dados(v_dados.last()).vr_vllanmto := 52.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10577041;
  v_dados(v_dados.last()).vr_nrctremp := 6363678;
  v_dados(v_dados.last()).vr_vllanmto := 15292.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10637753;
  v_dados(v_dados.last()).vr_nrctremp := 4453483;
  v_dados(v_dados.last()).vr_vllanmto := 5444.41;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10657673;
  v_dados(v_dados.last()).vr_nrctremp := 3167828;
  v_dados(v_dados.last()).vr_vllanmto := 1377.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10657673;
  v_dados(v_dados.last()).vr_nrctremp := 3607632;
  v_dados(v_dados.last()).vr_vllanmto := 913.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10670807;
  v_dados(v_dados.last()).vr_nrctremp := 4692518;
  v_dados(v_dados.last()).vr_vllanmto := 1001.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10727116;
  v_dados(v_dados.last()).vr_nrctremp := 7165449;
  v_dados(v_dados.last()).vr_vllanmto := 30.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10750029;
  v_dados(v_dados.last()).vr_nrctremp := 6135678;
  v_dados(v_dados.last()).vr_vllanmto := 6540.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10845933;
  v_dados(v_dados.last()).vr_nrctremp := 5501714;
  v_dados(v_dados.last()).vr_vllanmto := 1413;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10878211;
  v_dados(v_dados.last()).vr_nrctremp := 7225058;
  v_dados(v_dados.last()).vr_vllanmto := 1395.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10923101;
  v_dados(v_dados.last()).vr_nrctremp := 5661694;
  v_dados(v_dados.last()).vr_vllanmto := 165.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10961887;
  v_dados(v_dados.last()).vr_nrctremp := 5622318;
  v_dados(v_dados.last()).vr_vllanmto := 722;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11075252;
  v_dados(v_dados.last()).vr_nrctremp := 6735712;
  v_dados(v_dados.last()).vr_vllanmto := 344.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11195541;
  v_dados(v_dados.last()).vr_nrctremp := 4604839;
  v_dados(v_dados.last()).vr_vllanmto := 2373.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11223332;
  v_dados(v_dados.last()).vr_nrctremp := 4901463;
  v_dados(v_dados.last()).vr_vllanmto := 9838.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11228083;
  v_dados(v_dados.last()).vr_nrctremp := 4581982;
  v_dados(v_dados.last()).vr_vllanmto := 415.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11254696;
  v_dados(v_dados.last()).vr_nrctremp := 7234406;
  v_dados(v_dados.last()).vr_vllanmto := 170.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11255447;
  v_dados(v_dados.last()).vr_nrctremp := 7978224;
  v_dados(v_dados.last()).vr_vllanmto := 2828.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11262818;
  v_dados(v_dados.last()).vr_nrctremp := 4925150;
  v_dados(v_dados.last()).vr_vllanmto := 4059.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11310480;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 3107.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 1358.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11487631;
  v_dados(v_dados.last()).vr_nrctremp := 6365892;
  v_dados(v_dados.last()).vr_vllanmto := 16.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11576537;
  v_dados(v_dados.last()).vr_nrctremp := 4674681;
  v_dados(v_dados.last()).vr_vllanmto := 2627.89;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11600128;
  v_dados(v_dados.last()).vr_nrctremp := 7935143;
  v_dados(v_dados.last()).vr_vllanmto := 21.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11629410;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 1383.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11657898;
  v_dados(v_dados.last()).vr_nrctremp := 6268477;
  v_dados(v_dados.last()).vr_vllanmto := 27644.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11665300;
  v_dados(v_dados.last()).vr_nrctremp := 6665413;
  v_dados(v_dados.last()).vr_vllanmto := 510.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11780800;
  v_dados(v_dados.last()).vr_nrctremp := 6607613;
  v_dados(v_dados.last()).vr_vllanmto := 70.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11785837;
  v_dados(v_dados.last()).vr_nrctremp := 4974493;
  v_dados(v_dados.last()).vr_vllanmto := 111.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11858001;
  v_dados(v_dados.last()).vr_nrctremp := 3070526;
  v_dados(v_dados.last()).vr_vllanmto := 6565.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11956186;
  v_dados(v_dados.last()).vr_nrctremp := 7047172;
  v_dados(v_dados.last()).vr_vllanmto := 2258.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11957085;
  v_dados(v_dados.last()).vr_nrctremp := 6804628;
  v_dados(v_dados.last()).vr_vllanmto := 195.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11993308;
  v_dados(v_dados.last()).vr_nrctremp := 6570570;
  v_dados(v_dados.last()).vr_vllanmto := 47.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12038083;
  v_dados(v_dados.last()).vr_nrctremp := 7240176;
  v_dados(v_dados.last()).vr_vllanmto := 17863.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12103721;
  v_dados(v_dados.last()).vr_nrctremp := 6277579;
  v_dados(v_dados.last()).vr_vllanmto := 10197.23;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12143200;
  v_dados(v_dados.last()).vr_nrctremp := 4857588;
  v_dados(v_dados.last()).vr_vllanmto := 8668.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12189227;
  v_dados(v_dados.last()).vr_nrctremp := 6289728;
  v_dados(v_dados.last()).vr_vllanmto := 46.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12230448;
  v_dados(v_dados.last()).vr_nrctremp := 3435628;
  v_dados(v_dados.last()).vr_vllanmto := 404.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12292095;
  v_dados(v_dados.last()).vr_nrctremp := 5828078;
  v_dados(v_dados.last()).vr_vllanmto := 2458.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12298450;
  v_dados(v_dados.last()).vr_nrctremp := 7282249;
  v_dados(v_dados.last()).vr_vllanmto := 591.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12316628;
  v_dados(v_dados.last()).vr_nrctremp := 3510982;
  v_dados(v_dados.last()).vr_vllanmto := 165.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12317519;
  v_dados(v_dados.last()).vr_nrctremp := 5783533;
  v_dados(v_dados.last()).vr_vllanmto := 143.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12324841;
  v_dados(v_dados.last()).vr_nrctremp := 6400551;
  v_dados(v_dados.last()).vr_vllanmto := 1061.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12324841;
  v_dados(v_dados.last()).vr_nrctremp := 7073135;
  v_dados(v_dados.last()).vr_vllanmto := 372.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12359980;
  v_dados(v_dados.last()).vr_nrctremp := 5290818;
  v_dados(v_dados.last()).vr_vllanmto := 776.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12397253;
  v_dados(v_dados.last()).vr_nrctremp := 3600273;
  v_dados(v_dados.last()).vr_vllanmto := 4616.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12397253;
  v_dados(v_dados.last()).vr_nrctremp := 6375383;
  v_dados(v_dados.last()).vr_vllanmto := 1017.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12417742;
  v_dados(v_dados.last()).vr_nrctremp := 3614655;
  v_dados(v_dados.last()).vr_vllanmto := 193.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12445959;
  v_dados(v_dados.last()).vr_nrctremp := 5622328;
  v_dados(v_dados.last()).vr_vllanmto := 96.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12462888;
  v_dados(v_dados.last()).vr_nrctremp := 4022402;
  v_dados(v_dados.last()).vr_vllanmto := 986.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 21606.9;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12475815;
  v_dados(v_dados.last()).vr_nrctremp := 5702554;
  v_dados(v_dados.last()).vr_vllanmto := 28.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12540552;
  v_dados(v_dados.last()).vr_nrctremp := 3741052;
  v_dados(v_dados.last()).vr_vllanmto := 199.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12559377;
  v_dados(v_dados.last()).vr_nrctremp := 7237804;
  v_dados(v_dados.last()).vr_vllanmto := 36.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12561762;
  v_dados(v_dados.last()).vr_nrctremp := 4109959;
  v_dados(v_dados.last()).vr_vllanmto := 4043.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12578827;
  v_dados(v_dados.last()).vr_nrctremp := 5665047;
  v_dados(v_dados.last()).vr_vllanmto := 1203.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916683;
  v_dados(v_dados.last()).vr_vllanmto := 19.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916746;
  v_dados(v_dados.last()).vr_vllanmto := 63.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12801658;
  v_dados(v_dados.last()).vr_nrctremp := 5077570;
  v_dados(v_dados.last()).vr_vllanmto := 441.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12810533;
  v_dados(v_dados.last()).vr_nrctremp := 4245483;
  v_dados(v_dados.last()).vr_vllanmto := 1786.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12873632;
  v_dados(v_dados.last()).vr_nrctremp := 4085979;
  v_dados(v_dados.last()).vr_vllanmto := 3177.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12942820;
  v_dados(v_dados.last()).vr_nrctremp := 7251150;
  v_dados(v_dados.last()).vr_vllanmto := 7495.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12976350;
  v_dados(v_dados.last()).vr_nrctremp := 5845377;
  v_dados(v_dados.last()).vr_vllanmto := 830.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12981230;
  v_dados(v_dados.last()).vr_nrctremp := 6400299;
  v_dados(v_dados.last()).vr_vllanmto := 1072.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12981877;
  v_dados(v_dados.last()).vr_nrctremp := 5200658;
  v_dados(v_dados.last()).vr_vllanmto := 438.73;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13011600;
  v_dados(v_dados.last()).vr_nrctremp := 5349520;
  v_dados(v_dados.last()).vr_vllanmto := 17.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13053140;
  v_dados(v_dados.last()).vr_nrctremp := 5779480;
  v_dados(v_dados.last()).vr_vllanmto := 394.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13053140;
  v_dados(v_dados.last()).vr_nrctremp := 5863094;
  v_dados(v_dados.last()).vr_vllanmto := 395.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13167537;
  v_dados(v_dados.last()).vr_nrctremp := 6440873;
  v_dados(v_dados.last()).vr_vllanmto := 892.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13169041;
  v_dados(v_dados.last()).vr_nrctremp := 7600488;
  v_dados(v_dados.last()).vr_vllanmto := 22.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13184270;
  v_dados(v_dados.last()).vr_nrctremp := 4313478;
  v_dados(v_dados.last()).vr_vllanmto := 11136.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13198661;
  v_dados(v_dados.last()).vr_nrctremp := 7472019;
  v_dados(v_dados.last()).vr_vllanmto := 8206.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13262653;
  v_dados(v_dados.last()).vr_nrctremp := 6849048;
  v_dados(v_dados.last()).vr_vllanmto := 29.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13262653;
  v_dados(v_dados.last()).vr_nrctremp := 7210381;
  v_dados(v_dados.last()).vr_vllanmto := 15313.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13305042;
  v_dados(v_dados.last()).vr_nrctremp := 7033593;
  v_dados(v_dados.last()).vr_vllanmto := 15.94;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13407813;
  v_dados(v_dados.last()).vr_nrctremp := 6546199;
  v_dados(v_dados.last()).vr_vllanmto := 53.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13481622;
  v_dados(v_dados.last()).vr_nrctremp := 4650705;
  v_dados(v_dados.last()).vr_vllanmto := 107.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13570811;
  v_dados(v_dados.last()).vr_nrctremp := 7367000;
  v_dados(v_dados.last()).vr_vllanmto := 7492.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13689614;
  v_dados(v_dados.last()).vr_nrctremp := 7377291;
  v_dados(v_dados.last()).vr_vllanmto := 171.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13689614;
  v_dados(v_dados.last()).vr_nrctremp := 7703197;
  v_dados(v_dados.last()).vr_vllanmto := 558.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13702297;
  v_dados(v_dados.last()).vr_nrctremp := 5833525;
  v_dados(v_dados.last()).vr_vllanmto := 15604.66;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13739310;
  v_dados(v_dados.last()).vr_nrctremp := 6682498;
  v_dados(v_dados.last()).vr_vllanmto := 1004.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13739425;
  v_dados(v_dados.last()).vr_nrctremp := 5531174;
  v_dados(v_dados.last()).vr_vllanmto := 3589.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13771663;
  v_dados(v_dados.last()).vr_nrctremp := 7885860;
  v_dados(v_dados.last()).vr_vllanmto := 159.37;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13803107;
  v_dados(v_dados.last()).vr_nrctremp := 6647967;
  v_dados(v_dados.last()).vr_vllanmto := 2927.59;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13939998;
  v_dados(v_dados.last()).vr_nrctremp := 7040222;
  v_dados(v_dados.last()).vr_vllanmto := 1219.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14180774;
  v_dados(v_dados.last()).vr_nrctremp := 7089998;
  v_dados(v_dados.last()).vr_vllanmto := 374.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14191229;
  v_dados(v_dados.last()).vr_nrctremp := 8107367;
  v_dados(v_dados.last()).vr_vllanmto := 45.79;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14221616;
  v_dados(v_dados.last()).vr_nrctremp := 6911986;
  v_dados(v_dados.last()).vr_vllanmto := 280.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14542170;
  v_dados(v_dados.last()).vr_nrctremp := 6443680;
  v_dados(v_dados.last()).vr_vllanmto := 284.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14833468;
  v_dados(v_dados.last()).vr_nrctremp := 6271717;
  v_dados(v_dados.last()).vr_vllanmto := 56.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14949482;
  v_dados(v_dados.last()).vr_nrctremp := 5691194;
  v_dados(v_dados.last()).vr_vllanmto := 625.03;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15171353;
  v_dados(v_dados.last()).vr_nrctremp := 6753807;
  v_dados(v_dados.last()).vr_vllanmto := 1003.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15207536;
  v_dados(v_dados.last()).vr_nrctremp := 7224738;
  v_dados(v_dados.last()).vr_vllanmto := 9731.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15264734;
  v_dados(v_dados.last()).vr_nrctremp := 6627036;
  v_dados(v_dados.last()).vr_vllanmto := 1656.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15280390;
  v_dados(v_dados.last()).vr_nrctremp := 6559399;
  v_dados(v_dados.last()).vr_vllanmto := 21.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15313697;
  v_dados(v_dados.last()).vr_nrctremp := 6891009;
  v_dados(v_dados.last()).vr_vllanmto := 32.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15451720;
  v_dados(v_dados.last()).vr_nrctremp := 7204447;
  v_dados(v_dados.last()).vr_vllanmto := 338.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15579522;
  v_dados(v_dados.last()).vr_nrctremp := 7895220;
  v_dados(v_dados.last()).vr_vllanmto := 32499.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15641627;
  v_dados(v_dados.last()).vr_nrctremp := 6184178;
  v_dados(v_dados.last()).vr_vllanmto := 55.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15733807;
  v_dados(v_dados.last()).vr_nrctremp := 7155786;
  v_dados(v_dados.last()).vr_vllanmto := 4955.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15851761;
  v_dados(v_dados.last()).vr_nrctremp := 6337886;
  v_dados(v_dados.last()).vr_vllanmto := 2745.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15864774;
  v_dados(v_dados.last()).vr_nrctremp := 7801413;
  v_dados(v_dados.last()).vr_vllanmto := 18458.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15864774;
  v_dados(v_dados.last()).vr_nrctremp := 7808362;
  v_dados(v_dados.last()).vr_vllanmto := 26875.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15901670;
  v_dados(v_dados.last()).vr_nrctremp := 7152401;
  v_dados(v_dados.last()).vr_vllanmto := 220.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15949559;
  v_dados(v_dados.last()).vr_nrctremp := 6394083;
  v_dados(v_dados.last()).vr_vllanmto := 547.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16043812;
  v_dados(v_dados.last()).vr_nrctremp := 6468398;
  v_dados(v_dados.last()).vr_vllanmto := 1459.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16056132;
  v_dados(v_dados.last()).vr_nrctremp := 6479186;
  v_dados(v_dados.last()).vr_vllanmto := 93.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16143540;
  v_dados(v_dados.last()).vr_nrctremp := 6537132;
  v_dados(v_dados.last()).vr_vllanmto := 1913.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16178343;
  v_dados(v_dados.last()).vr_nrctremp := 6968793;
  v_dados(v_dados.last()).vr_vllanmto := 399.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16204379;
  v_dados(v_dados.last()).vr_nrctremp := 6973807;
  v_dados(v_dados.last()).vr_vllanmto := 464.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16207807;
  v_dados(v_dados.last()).vr_nrctremp := 7209925;
  v_dados(v_dados.last()).vr_vllanmto := 14.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16654277;
  v_dados(v_dados.last()).vr_nrctremp := 6860528;
  v_dados(v_dados.last()).vr_vllanmto := 1717.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16703006;
  v_dados(v_dados.last()).vr_nrctremp := 6993826;
  v_dados(v_dados.last()).vr_vllanmto := 5584;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16834054;
  v_dados(v_dados.last()).vr_nrctremp := 6974556;
  v_dados(v_dados.last()).vr_vllanmto := 1041.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16944453;
  v_dados(v_dados.last()).vr_nrctremp := 7730157;
  v_dados(v_dados.last()).vr_vllanmto := 464.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17071020;
  v_dados(v_dados.last()).vr_nrctremp := 7762825;
  v_dados(v_dados.last()).vr_vllanmto := 73.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17415098;
  v_dados(v_dados.last()).vr_nrctremp := 7367076;
  v_dados(v_dados.last()).vr_vllanmto := 12.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17417910;
  v_dados(v_dados.last()).vr_nrctremp := 7886095;
  v_dados(v_dados.last()).vr_vllanmto := 38.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80086063;
  v_dados(v_dados.last()).vr_nrctremp := 5789390;
  v_dados(v_dados.last()).vr_vllanmto := 8941.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80334768;
  v_dados(v_dados.last()).vr_nrctremp := 3858963;
  v_dados(v_dados.last()).vr_vllanmto := 6584.51;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80338526;
  v_dados(v_dados.last()).vr_nrctremp := 5672938;
  v_dados(v_dados.last()).vr_vllanmto := 1007.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80476651;
  v_dados(v_dados.last()).vr_nrctremp := 4558023;
  v_dados(v_dados.last()).vr_vllanmto := 1329.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 202398;
  v_dados(v_dados.last()).vr_nrctremp := 466946;
  v_dados(v_dados.last()).vr_vllanmto := 12.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 504181;
  v_dados(v_dados.last()).vr_nrctremp := 313929;
  v_dados(v_dados.last()).vr_vllanmto := 761.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 509094;
  v_dados(v_dados.last()).vr_nrctremp := 395508;
  v_dados(v_dados.last()).vr_vllanmto := 38.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575046;
  v_dados(v_dados.last()).vr_nrctremp := 383395;
  v_dados(v_dados.last()).vr_vllanmto := 508.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 601470;
  v_dados(v_dados.last()).vr_nrctremp := 376735;
  v_dados(v_dados.last()).vr_vllanmto := 251.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 663778;
  v_dados(v_dados.last()).vr_nrctremp := 336241;
  v_dados(v_dados.last()).vr_vllanmto := 26.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 677442;
  v_dados(v_dados.last()).vr_nrctremp := 382071;
  v_dados(v_dados.last()).vr_vllanmto := 2683.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 697370;
  v_dados(v_dados.last()).vr_nrctremp := 352338;
  v_dados(v_dados.last()).vr_vllanmto := 51.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 736767;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 2035.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 757365;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 6316.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 771511;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 2804.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 866547;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 2619.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 886050;
  v_dados(v_dados.last()).vr_nrctremp := 382587;
  v_dados(v_dados.last()).vr_vllanmto := 1924.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 902519;
  v_dados(v_dados.last()).vr_nrctremp := 318129;
  v_dados(v_dados.last()).vr_vllanmto := 199.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 923770;
  v_dados(v_dados.last()).vr_nrctremp := 325369;
  v_dados(v_dados.last()).vr_vllanmto := 16.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 923770;
  v_dados(v_dados.last()).vr_nrctremp := 400915;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931314;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := 3601.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 963143;
  v_dados(v_dados.last()).vr_nrctremp := 330810;
  v_dados(v_dados.last()).vr_vllanmto := 431.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 26632.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 989231;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 2494.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 348292;
  v_dados(v_dados.last()).vr_vllanmto := 5156.5;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 374317;
  v_dados(v_dados.last()).vr_vllanmto := 3512.98;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1026089;
  v_dados(v_dados.last()).vr_nrctremp := 399005;
  v_dados(v_dados.last()).vr_vllanmto := 803.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1121170;
  v_dados(v_dados.last()).vr_nrctremp := 465246;
  v_dados(v_dados.last()).vr_vllanmto := 357.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1156462;
  v_dados(v_dados.last()).vr_nrctremp := 384151;
  v_dados(v_dados.last()).vr_vllanmto := 4483.59;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1174649;
  v_dados(v_dados.last()).vr_nrctremp := 484393;
  v_dados(v_dados.last()).vr_vllanmto := 34.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1181394;
  v_dados(v_dados.last()).vr_nrctremp := 450500;
  v_dados(v_dados.last()).vr_vllanmto := 1147.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14289083;
  v_dados(v_dados.last()).vr_nrctremp := 409576;
  v_dados(v_dados.last()).vr_vllanmto := 5781.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14466244;
  v_dados(v_dados.last()).vr_nrctremp := 363449;
  v_dados(v_dados.last()).vr_vllanmto := 90.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14601168;
  v_dados(v_dados.last()).vr_nrctremp := 378298;
  v_dados(v_dados.last()).vr_vllanmto := 405.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14754983;
  v_dados(v_dados.last()).vr_nrctremp := 472974;
  v_dados(v_dados.last()).vr_vllanmto := 357.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15268527;
  v_dados(v_dados.last()).vr_nrctremp := 500587;
  v_dados(v_dados.last()).vr_vllanmto := 19.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15268799;
  v_dados(v_dados.last()).vr_nrctremp := 474688;
  v_dados(v_dados.last()).vr_vllanmto := 17.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15491242;
  v_dados(v_dados.last()).vr_nrctremp := 410375;
  v_dados(v_dados.last()).vr_vllanmto := 1085.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15623750;
  v_dados(v_dados.last()).vr_nrctremp := 415668;
  v_dados(v_dados.last()).vr_vllanmto := 24707.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15699927;
  v_dados(v_dados.last()).vr_nrctremp := 427146;
  v_dados(v_dados.last()).vr_vllanmto := 1933.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755223;
  v_dados(v_dados.last()).vr_nrctremp := 420713;
  v_dados(v_dados.last()).vr_vllanmto := 1364.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755495;
  v_dados(v_dados.last()).vr_nrctremp := 420674;
  v_dados(v_dados.last()).vr_vllanmto := 384;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755495;
  v_dados(v_dados.last()).vr_nrctremp := 445923;
  v_dados(v_dados.last()).vr_vllanmto := 490.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15776069;
  v_dados(v_dados.last()).vr_nrctremp := 421630;
  v_dados(v_dados.last()).vr_vllanmto := 4477.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15785904;
  v_dados(v_dados.last()).vr_nrctremp := 421960;
  v_dados(v_dados.last()).vr_vllanmto := 1389.97;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15813290;
  v_dados(v_dados.last()).vr_nrctremp := 423196;
  v_dados(v_dados.last()).vr_vllanmto := 272.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15813290;
  v_dados(v_dados.last()).vr_nrctremp := 435418;
  v_dados(v_dados.last()).vr_vllanmto := 36.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15880800;
  v_dados(v_dados.last()).vr_nrctremp := 426071;
  v_dados(v_dados.last()).vr_vllanmto := 997.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15980626;
  v_dados(v_dados.last()).vr_nrctremp := 429868;
  v_dados(v_dados.last()).vr_vllanmto := 650.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15986756;
  v_dados(v_dados.last()).vr_nrctremp := 435801;
  v_dados(v_dados.last()).vr_vllanmto := 817.57;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16265289;
  v_dados(v_dados.last()).vr_nrctremp := 440729;
  v_dados(v_dados.last()).vr_vllanmto := 4010.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16316053;
  v_dados(v_dados.last()).vr_nrctremp := 443018;
  v_dados(v_dados.last()).vr_vllanmto := 43.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16330420;
  v_dados(v_dados.last()).vr_nrctremp := 501616;
  v_dados(v_dados.last()).vr_vllanmto := 44339.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16764196;
  v_dados(v_dados.last()).vr_nrctremp := 458967;
  v_dados(v_dados.last()).vr_vllanmto := 1811.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16965485;
  v_dados(v_dados.last()).vr_nrctremp := 466677;
  v_dados(v_dados.last()).vr_vllanmto := 66.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16965485;
  v_dados(v_dados.last()).vr_nrctremp := 480862;
  v_dados(v_dados.last()).vr_vllanmto := 52.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17317126;
  v_dados(v_dados.last()).vr_nrctremp := 519228;
  v_dados(v_dados.last()).vr_vllanmto := 14.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17381975;
  v_dados(v_dados.last()).vr_nrctremp := 481721;
  v_dados(v_dados.last()).vr_vllanmto := 45.21;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 20010;
  v_dados(v_dados.last()).vr_nrctremp := 78448;
  v_dados(v_dados.last()).vr_vllanmto := 972.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 20010;
  v_dados(v_dados.last()).vr_nrctremp := 81837;
  v_dados(v_dados.last()).vr_vllanmto := 579.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 59544;
  v_dados(v_dados.last()).vr_nrctremp := 106670;
  v_dados(v_dados.last()).vr_vllanmto := 6990.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 147699;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 2214.34;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 150045;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 3647.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 55893;
  v_dados(v_dados.last()).vr_vllanmto := 498.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 63200;
  v_dados(v_dados.last()).vr_vllanmto := 425.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 304174;
  v_dados(v_dados.last()).vr_nrctremp := 99070;
  v_dados(v_dados.last()).vr_vllanmto := 47.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 322571;
  v_dados(v_dados.last()).vr_nrctremp := 79948;
  v_dados(v_dados.last()).vr_vllanmto := 1035.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 323454;
  v_dados(v_dados.last()).vr_nrctremp := 95971;
  v_dados(v_dados.last()).vr_vllanmto := 1843.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 340243;
  v_dados(v_dados.last()).vr_nrctremp := 77563;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348732;
  v_dados(v_dados.last()).vr_nrctremp := 59739;
  v_dados(v_dados.last()).vr_vllanmto := 176.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349372;
  v_dados(v_dados.last()).vr_nrctremp := 98361;
  v_dados(v_dados.last()).vr_vllanmto := 170.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349470;
  v_dados(v_dados.last()).vr_nrctremp := 82924;
  v_dados(v_dados.last()).vr_vllanmto := 63.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 350796;
  v_dados(v_dados.last()).vr_nrctremp := 103907;
  v_dados(v_dados.last()).vr_vllanmto := 1015.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 369861;
  v_dados(v_dados.last()).vr_nrctremp := 133924;
  v_dados(v_dados.last()).vr_vllanmto := 221.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14516950;
  v_dados(v_dados.last()).vr_nrctremp := 71862;
  v_dados(v_dados.last()).vr_vllanmto := 1080.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14629895;
  v_dados(v_dados.last()).vr_nrctremp := 69129;
  v_dados(v_dados.last()).vr_vllanmto := 77.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16182669;
  v_dados(v_dados.last()).vr_nrctremp := 99917;
  v_dados(v_dados.last()).vr_vllanmto := 343.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16245466;
  v_dados(v_dados.last()).vr_nrctremp := 111052;
  v_dados(v_dados.last()).vr_vllanmto := 47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16422147;
  v_dados(v_dados.last()).vr_nrctremp := 143051;
  v_dados(v_dados.last()).vr_vllanmto := 19.35;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17032415;
  v_dados(v_dados.last()).vr_nrctremp := 135661;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 157406;
  v_dados(v_dados.last()).vr_nrctremp := 271650;
  v_dados(v_dados.last()).vr_vllanmto := 102.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 264644;
  v_dados(v_dados.last()).vr_nrctremp := 272600;
  v_dados(v_dados.last()).vr_vllanmto := 45.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 268550;
  v_dados(v_dados.last()).vr_nrctremp := 275647;
  v_dados(v_dados.last()).vr_vllanmto := 33.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17418615;
  v_dados(v_dados.last()).vr_nrctremp := 280632;
  v_dados(v_dados.last()).vr_vllanmto := 1083.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17534615;
  v_dados(v_dados.last()).vr_nrctremp := 278347;
  v_dados(v_dados.last()).vr_vllanmto := 44.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 26409;
  v_dados(v_dados.last()).vr_nrctremp := 41946;
  v_dados(v_dados.last()).vr_vllanmto := 7332.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 265918;
  v_dados(v_dados.last()).vr_nrctremp := 64501;
  v_dados(v_dados.last()).vr_vllanmto := 35.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 285803;
  v_dados(v_dados.last()).vr_nrctremp := 101130;
  v_dados(v_dados.last()).vr_vllanmto := 3142.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 389030;
  v_dados(v_dados.last()).vr_nrctremp := 110729;
  v_dados(v_dados.last()).vr_vllanmto := 28887.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 396257;
  v_dados(v_dados.last()).vr_nrctremp := 90868;
  v_dados(v_dados.last()).vr_vllanmto := 1179.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 414085;
  v_dados(v_dados.last()).vr_nrctremp := 88622;
  v_dados(v_dados.last()).vr_vllanmto := 2471.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 445940;
  v_dados(v_dados.last()).vr_nrctremp := 82037;
  v_dados(v_dados.last()).vr_vllanmto := 2552.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446025;
  v_dados(v_dados.last()).vr_nrctremp := 83056;
  v_dados(v_dados.last()).vr_vllanmto := 1225.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446742;
  v_dados(v_dados.last()).vr_nrctremp := 82971;
  v_dados(v_dados.last()).vr_vllanmto := 24.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14113449;
  v_dados(v_dados.last()).vr_nrctremp := 71178;
  v_dados(v_dados.last()).vr_vllanmto := 765.09;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14140888;
  v_dados(v_dados.last()).vr_nrctremp := 106454;
  v_dados(v_dados.last()).vr_vllanmto := 1761.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14162342;
  v_dados(v_dados.last()).vr_nrctremp := 91960;
  v_dados(v_dados.last()).vr_vllanmto := 35.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203103;
  v_dados(v_dados.last()).vr_nrctremp := 113182;
  v_dados(v_dados.last()).vr_vllanmto := 47.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203324;
  v_dados(v_dados.last()).vr_nrctremp := 72406;
  v_dados(v_dados.last()).vr_vllanmto := 2492.76;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203324;
  v_dados(v_dados.last()).vr_nrctremp := 85135;
  v_dados(v_dados.last()).vr_vllanmto := 2893.77;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14205653;
  v_dados(v_dados.last()).vr_nrctremp := 85268;
  v_dados(v_dados.last()).vr_vllanmto := 888.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14221110;
  v_dados(v_dados.last()).vr_nrctremp := 73484;
  v_dados(v_dados.last()).vr_vllanmto := 70.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14270706;
  v_dados(v_dados.last()).vr_nrctremp := 72996;
  v_dados(v_dados.last()).vr_vllanmto := 368.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14285703;
  v_dados(v_dados.last()).vr_nrctremp := 74338;
  v_dados(v_dados.last()).vr_vllanmto := 5767.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14299534;
  v_dados(v_dados.last()).vr_nrctremp := 97212;
  v_dados(v_dados.last()).vr_vllanmto := 7557.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14300133;
  v_dados(v_dados.last()).vr_nrctremp := 74775;
  v_dados(v_dados.last()).vr_vllanmto := 177.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14418940;
  v_dados(v_dados.last()).vr_nrctremp := 75101;
  v_dados(v_dados.last()).vr_vllanmto := 3256.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14505827;
  v_dados(v_dados.last()).vr_nrctremp := 101114;
  v_dados(v_dados.last()).vr_vllanmto := 31.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14507749;
  v_dados(v_dados.last()).vr_nrctremp := 77826;
  v_dados(v_dados.last()).vr_vllanmto := 438.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14562766;
  v_dados(v_dados.last()).vr_nrctremp := 105220;
  v_dados(v_dados.last()).vr_vllanmto := 38.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14788616;
  v_dados(v_dados.last()).vr_nrctremp := 82634;
  v_dados(v_dados.last()).vr_vllanmto := 124.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14999064;
  v_dados(v_dados.last()).vr_nrctremp := 83702;
  v_dados(v_dados.last()).vr_vllanmto := 1887.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85491;
  v_dados(v_dados.last()).vr_vllanmto := 67.48;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85493;
  v_dados(v_dados.last()).vr_vllanmto := 105.15;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85494;
  v_dados(v_dados.last()).vr_vllanmto := 174.8;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85495;
  v_dados(v_dados.last()).vr_vllanmto := 143.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15047806;
  v_dados(v_dados.last()).vr_nrctremp := 84306;
  v_dados(v_dados.last()).vr_vllanmto := 185.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 87201;
  v_dados(v_dados.last()).vr_vllanmto := 5233.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 87202;
  v_dados(v_dados.last()).vr_vllanmto := 2379.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 91962;
  v_dados(v_dados.last()).vr_vllanmto := 4762.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15295974;
  v_dados(v_dados.last()).vr_nrctremp := 91837;
  v_dados(v_dados.last()).vr_vllanmto := 113.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15563197;
  v_dados(v_dados.last()).vr_nrctremp := 93355;
  v_dados(v_dados.last()).vr_vllanmto := 1264.78;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15622290;
  v_dados(v_dados.last()).vr_nrctremp := 93079;
  v_dados(v_dados.last()).vr_vllanmto := 15.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15622290;
  v_dados(v_dados.last()).vr_nrctremp := 98109;
  v_dados(v_dados.last()).vr_vllanmto := 38.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15738116;
  v_dados(v_dados.last()).vr_nrctremp := 93183;
  v_dados(v_dados.last()).vr_vllanmto := 847.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862720;
  v_dados(v_dados.last()).vr_nrctremp := 94655;
  v_dados(v_dados.last()).vr_vllanmto := 40.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 94656;
  v_dados(v_dados.last()).vr_vllanmto := 1172.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 95863;
  v_dados(v_dados.last()).vr_vllanmto := 469.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15863328;
  v_dados(v_dados.last()).vr_nrctremp := 94670;
  v_dados(v_dados.last()).vr_vllanmto := 47.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864065;
  v_dados(v_dados.last()).vr_nrctremp := 97094;
  v_dados(v_dados.last()).vr_vllanmto := 3713.76;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864499;
  v_dados(v_dados.last()).vr_nrctremp := 94675;
  v_dados(v_dados.last()).vr_vllanmto := 88.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864529;
  v_dados(v_dados.last()).vr_nrctremp := 94677;
  v_dados(v_dados.last()).vr_vllanmto := 954.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15894304;
  v_dados(v_dados.last()).vr_nrctremp := 95254;
  v_dados(v_dados.last()).vr_vllanmto := 13.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15903915;
  v_dados(v_dados.last()).vr_nrctremp := 97640;
  v_dados(v_dados.last()).vr_vllanmto := 158.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15914151;
  v_dados(v_dados.last()).vr_nrctremp := 96719;
  v_dados(v_dados.last()).vr_vllanmto := 82.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15916391;
  v_dados(v_dados.last()).vr_nrctremp := 101061;
  v_dados(v_dados.last()).vr_vllanmto := 3811.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15926265;
  v_dados(v_dados.last()).vr_nrctremp := 118556;
  v_dados(v_dados.last()).vr_vllanmto := 22.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15935167;
  v_dados(v_dados.last()).vr_nrctremp := 96527;
  v_dados(v_dados.last()).vr_vllanmto := 74321.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15935167;
  v_dados(v_dados.last()).vr_nrctremp := 126376;
  v_dados(v_dados.last()).vr_vllanmto := 30994.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15989291;
  v_dados(v_dados.last()).vr_nrctremp := 97016;
  v_dados(v_dados.last()).vr_vllanmto := 1800.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16160363;
  v_dados(v_dados.last()).vr_nrctremp := 101364;
  v_dados(v_dados.last()).vr_vllanmto := 2377.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16283716;
  v_dados(v_dados.last()).vr_nrctremp := 101132;
  v_dados(v_dados.last()).vr_vllanmto := 157.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16283716;
  v_dados(v_dados.last()).vr_nrctremp := 101137;
  v_dados(v_dados.last()).vr_vllanmto := 310.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16478320;
  v_dados(v_dados.last()).vr_nrctremp := 102406;
  v_dados(v_dados.last()).vr_vllanmto := 2809.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16549414;
  v_dados(v_dados.last()).vr_nrctremp := 109334;
  v_dados(v_dados.last()).vr_vllanmto := 792;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16695020;
  v_dados(v_dados.last()).vr_nrctremp := 111561;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16788788;
  v_dados(v_dados.last()).vr_nrctremp := 106618;
  v_dados(v_dados.last()).vr_vllanmto := 56.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16814991;
  v_dados(v_dados.last()).vr_nrctremp := 118234;
  v_dados(v_dados.last()).vr_vllanmto := 6340.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17012368;
  v_dados(v_dados.last()).vr_nrctremp := 109058;
  v_dados(v_dados.last()).vr_vllanmto := 2247.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17849667;
  v_dados(v_dados.last()).vr_nrctremp := 120232;
  v_dados(v_dados.last()).vr_vllanmto := 32.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18216870;
  v_dados(v_dados.last()).vr_nrctremp := 125095;
  v_dados(v_dados.last()).vr_vllanmto := 18.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18264182;
  v_dados(v_dados.last()).vr_nrctremp := 125852;
  v_dados(v_dados.last()).vr_vllanmto := 62.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 8;
  v_dados(v_dados.last()).vr_nrdconta := 57347;
  v_dados(v_dados.last()).vr_nrctremp := 14695;
  v_dados(v_dados.last()).vr_vllanmto := 1313.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 8;
  v_dados(v_dados.last()).vr_nrdconta := 14684462;
  v_dados(v_dados.last()).vr_nrctremp := 15346;
  v_dados(v_dados.last()).vr_vllanmto := 73.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 252255;
  v_dados(v_dados.last()).vr_nrctremp := 67082;
  v_dados(v_dados.last()).vr_vllanmto := 500.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 363030;
  v_dados(v_dados.last()).vr_nrctremp := 55689;
  v_dados(v_dados.last()).vr_vllanmto := 27.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 387770;
  v_dados(v_dados.last()).vr_nrctremp := 85855;
  v_dados(v_dados.last()).vr_vllanmto := 1224.88;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501778;
  v_dados(v_dados.last()).vr_nrctremp := 91224;
  v_dados(v_dados.last()).vr_vllanmto := 5022.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 549460;
  v_dados(v_dados.last()).vr_nrctremp := 81619;
  v_dados(v_dados.last()).vr_vllanmto := 2667.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 587672;
  v_dados(v_dados.last()).vr_nrctremp := 98363;
  v_dados(v_dados.last()).vr_vllanmto := 372.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15242617;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 2586.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15375641;
  v_dados(v_dados.last()).vr_nrctremp := 86265;
  v_dados(v_dados.last()).vr_vllanmto := 21571.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15633870;
  v_dados(v_dados.last()).vr_nrctremp := 91922;
  v_dados(v_dados.last()).vr_vllanmto := 161.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16528336;
  v_dados(v_dados.last()).vr_nrctremp := 100365;
  v_dados(v_dados.last()).vr_vllanmto := 45.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16542088;
  v_dados(v_dados.last()).vr_nrctremp := 92191;
  v_dados(v_dados.last()).vr_vllanmto := 62.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17107393;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 229.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17239184;
  v_dados(v_dados.last()).vr_nrctremp := 90531;
  v_dados(v_dados.last()).vr_vllanmto := 656.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17569257;
  v_dados(v_dados.last()).vr_nrctremp := 99645;
  v_dados(v_dados.last()).vr_vllanmto := 18.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17682282;
  v_dados(v_dados.last()).vr_nrctremp := 95649;
  v_dados(v_dados.last()).vr_vllanmto := 865.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 20290;
  v_dados(v_dados.last()).vr_nrctremp := 11604;
  v_dados(v_dados.last()).vr_vllanmto := 604.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 21288;
  v_dados(v_dados.last()).vr_nrctremp := 41053;
  v_dados(v_dados.last()).vr_vllanmto := 2211.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 70645;
  v_dados(v_dados.last()).vr_nrctremp := 46659;
  v_dados(v_dados.last()).vr_vllanmto := 6667.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73130;
  v_dados(v_dados.last()).vr_nrctremp := 20750;
  v_dados(v_dados.last()).vr_vllanmto := 172.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 74454;
  v_dados(v_dados.last()).vr_nrctremp := 43673;
  v_dados(v_dados.last()).vr_vllanmto := 333.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84298;
  v_dados(v_dados.last()).vr_nrctremp := 41926;
  v_dados(v_dados.last()).vr_vllanmto := 779.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 125873;
  v_dados(v_dados.last()).vr_nrctremp := 24290;
  v_dados(v_dados.last()).vr_vllanmto := 56.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128481;
  v_dados(v_dados.last()).vr_nrctremp := 43540;
  v_dados(v_dados.last()).vr_vllanmto := 890.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 136280;
  v_dados(v_dados.last()).vr_nrctremp := 39751;
  v_dados(v_dados.last()).vr_vllanmto := 1183.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 164291;
  v_dados(v_dados.last()).vr_nrctremp := 20796;
  v_dados(v_dados.last()).vr_vllanmto := 833.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 168572;
  v_dados(v_dados.last()).vr_nrctremp := 40256;
  v_dados(v_dados.last()).vr_vllanmto := 5944.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 186449;
  v_dados(v_dados.last()).vr_nrctremp := 33515;
  v_dados(v_dados.last()).vr_vllanmto := 228.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187160;
  v_dados(v_dados.last()).vr_nrctremp := 39403;
  v_dados(v_dados.last()).vr_vllanmto := 6257.33;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 48543;
  v_dados(v_dados.last()).vr_vllanmto := 44.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 189995;
  v_dados(v_dados.last()).vr_nrctremp := 45413;
  v_dados(v_dados.last()).vr_vllanmto := 1850.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 190039;
  v_dados(v_dados.last()).vr_nrctremp := 38452;
  v_dados(v_dados.last()).vr_vllanmto := 123.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 194352;
  v_dados(v_dados.last()).vr_nrctremp := 50689;
  v_dados(v_dados.last()).vr_vllanmto := 70.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 200255;
  v_dados(v_dados.last()).vr_nrctremp := 52529;
  v_dados(v_dados.last()).vr_vllanmto := 56.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 220124;
  v_dados(v_dados.last()).vr_nrctremp := 40724;
  v_dados(v_dados.last()).vr_vllanmto := 953.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 227838;
  v_dados(v_dados.last()).vr_nrctremp := 41623;
  v_dados(v_dados.last()).vr_vllanmto := 584.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 229237;
  v_dados(v_dados.last()).vr_nrctremp := 49768;
  v_dados(v_dados.last()).vr_vllanmto := 87.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 239445;
  v_dados(v_dados.last()).vr_nrctremp := 45326;
  v_dados(v_dados.last()).vr_vllanmto := 542.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15001156;
  v_dados(v_dados.last()).vr_nrctremp := 49842;
  v_dados(v_dados.last()).vr_vllanmto := 2819.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15029379;
  v_dados(v_dados.last()).vr_nrctremp := 50899;
  v_dados(v_dados.last()).vr_vllanmto := 513.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15065537;
  v_dados(v_dados.last()).vr_nrctremp := 49900;
  v_dados(v_dados.last()).vr_vllanmto := 263.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15105113;
  v_dados(v_dados.last()).vr_nrctremp := 51578;
  v_dados(v_dados.last()).vr_vllanmto := 22.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15123081;
  v_dados(v_dados.last()).vr_nrctremp := 45697;
  v_dados(v_dados.last()).vr_vllanmto := 584.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15126510;
  v_dados(v_dados.last()).vr_nrctremp := 43499;
  v_dados(v_dados.last()).vr_vllanmto := 2123.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15193136;
  v_dados(v_dados.last()).vr_nrctremp := 43934;
  v_dados(v_dados.last()).vr_vllanmto := 727.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15235726;
  v_dados(v_dados.last()).vr_nrctremp := 48019;
  v_dados(v_dados.last()).vr_vllanmto := 15.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15278328;
  v_dados(v_dados.last()).vr_nrctremp := 49498;
  v_dados(v_dados.last()).vr_vllanmto := 482.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15300080;
  v_dados(v_dados.last()).vr_nrctremp := 46800;
  v_dados(v_dados.last()).vr_vllanmto := 43.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15300145;
  v_dados(v_dados.last()).vr_nrctremp := 43959;
  v_dados(v_dados.last()).vr_vllanmto := 374.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15409651;
  v_dados(v_dados.last()).vr_nrctremp := 45337;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15913570;
  v_dados(v_dados.last()).vr_nrctremp := 47997;
  v_dados(v_dados.last()).vr_vllanmto := 356.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15927954;
  v_dados(v_dados.last()).vr_nrctremp := 48107;
  v_dados(v_dados.last()).vr_vllanmto := 659.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15951421;
  v_dados(v_dados.last()).vr_nrctremp := 48271;
  v_dados(v_dados.last()).vr_vllanmto := 636.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15991865;
  v_dados(v_dados.last()).vr_nrctremp := 45879;
  v_dados(v_dados.last()).vr_vllanmto := 9272.8;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16248708;
  v_dados(v_dados.last()).vr_nrctremp := 45263;
  v_dados(v_dados.last()).vr_vllanmto := 673.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16292324;
  v_dados(v_dados.last()).vr_nrctremp := 45683;
  v_dados(v_dados.last()).vr_vllanmto := 5138.98;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16488105;
  v_dados(v_dados.last()).vr_nrctremp := 46153;
  v_dados(v_dados.last()).vr_vllanmto := 45.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16692080;
  v_dados(v_dados.last()).vr_nrctremp := 50974;
  v_dados(v_dados.last()).vr_vllanmto := 209.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16769759;
  v_dados(v_dados.last()).vr_nrctremp := 47314;
  v_dados(v_dados.last()).vr_vllanmto := 387.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 17316316;
  v_dados(v_dados.last()).vr_nrctremp := 51211;
  v_dados(v_dados.last()).vr_vllanmto := 29.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 17492769;
  v_dados(v_dados.last()).vr_nrctremp := 50282;
  v_dados(v_dados.last()).vr_vllanmto := 351.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 17621690;
  v_dados(v_dados.last()).vr_nrctremp := 50788;
  v_dados(v_dados.last()).vr_vllanmto := 484.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 371912;
  v_dados(v_dados.last()).vr_nrctremp := 424607;
  v_dados(v_dados.last()).vr_vllanmto := 19057.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 406325;
  v_dados(v_dados.last()).vr_nrctremp := 376966;
  v_dados(v_dados.last()).vr_vllanmto := 27984.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 406325;
  v_dados(v_dados.last()).vr_nrctremp := 446333;
  v_dados(v_dados.last()).vr_vllanmto := 5134.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 498050;
  v_dados(v_dados.last()).vr_nrctremp := 340569;
  v_dados(v_dados.last()).vr_vllanmto := 6508.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 581216;
  v_dados(v_dados.last()).vr_nrctremp := 214762;
  v_dados(v_dados.last()).vr_vllanmto := 1210.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 611999;
  v_dados(v_dados.last()).vr_nrctremp := 192831;
  v_dados(v_dados.last()).vr_vllanmto := 6508.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 626376;
  v_dados(v_dados.last()).vr_nrctremp := 263358;
  v_dados(v_dados.last()).vr_vllanmto := 222.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729205;
  v_dados(v_dados.last()).vr_nrctremp := 309697;
  v_dados(v_dados.last()).vr_vllanmto := 703.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729582;
  v_dados(v_dados.last()).vr_nrctremp := 237608;
  v_dados(v_dados.last()).vr_vllanmto := 4119.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 782513;
  v_dados(v_dados.last()).vr_nrctremp := 393030;
  v_dados(v_dados.last()).vr_vllanmto := 65.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 901644;
  v_dados(v_dados.last()).vr_nrctremp := 312327;
  v_dados(v_dados.last()).vr_vllanmto := 65.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 920185;
  v_dados(v_dados.last()).vr_nrctremp := 416025;
  v_dados(v_dados.last()).vr_vllanmto := 807.93;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 934615;
  v_dados(v_dados.last()).vr_nrctremp := 269482;
  v_dados(v_dados.last()).vr_vllanmto := 2265.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 956139;
  v_dados(v_dados.last()).vr_nrctremp := 348788;
  v_dados(v_dados.last()).vr_vllanmto := 578.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 972355;
  v_dados(v_dados.last()).vr_nrctremp := 423960;
  v_dados(v_dados.last()).vr_vllanmto := 39.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 987581;
  v_dados(v_dados.last()).vr_nrctremp := 359973;
  v_dados(v_dados.last()).vr_vllanmto := 511.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 996955;
  v_dados(v_dados.last()).vr_nrctremp := 418958;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14090880;
  v_dados(v_dados.last()).vr_nrctremp := 356668;
  v_dados(v_dados.last()).vr_vllanmto := 82.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14240149;
  v_dados(v_dados.last()).vr_nrctremp := 381166;
  v_dados(v_dados.last()).vr_vllanmto := 6259.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15128792;
  v_dados(v_dados.last()).vr_nrctremp := 398471;
  v_dados(v_dados.last()).vr_vllanmto := 61.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15316734;
  v_dados(v_dados.last()).vr_nrctremp := 317120;
  v_dados(v_dados.last()).vr_vllanmto := 2108.72;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15335267;
  v_dados(v_dados.last()).vr_nrctremp := 325333;
  v_dados(v_dados.last()).vr_vllanmto := 80.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16169964;
  v_dados(v_dados.last()).vr_nrctremp := 354858;
  v_dados(v_dados.last()).vr_vllanmto := 133.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16202066;
  v_dados(v_dados.last()).vr_nrctremp := 312420;
  v_dados(v_dados.last()).vr_vllanmto := 550.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16251865;
  v_dados(v_dados.last()).vr_nrctremp := 314665;
  v_dados(v_dados.last()).vr_vllanmto := 5778.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16251865;
  v_dados(v_dados.last()).vr_nrctremp := 329198;
  v_dados(v_dados.last()).vr_vllanmto := 17602.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16265980;
  v_dados(v_dados.last()).vr_nrctremp := 315190;
  v_dados(v_dados.last()).vr_vllanmto := 139.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 326663;
  v_dados(v_dados.last()).vr_vllanmto := 2319.34;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 360983;
  v_dados(v_dados.last()).vr_vllanmto := 17.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 396174;
  v_dados(v_dados.last()).vr_vllanmto := 42.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 423103;
  v_dados(v_dados.last()).vr_vllanmto := 1371.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16444256;
  v_dados(v_dados.last()).vr_nrctremp := 324902;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16609387;
  v_dados(v_dados.last()).vr_nrctremp := 332548;
  v_dados(v_dados.last()).vr_vllanmto := 1518.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16635744;
  v_dados(v_dados.last()).vr_nrctremp := 333757;
  v_dados(v_dados.last()).vr_vllanmto := 284.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16709616;
  v_dados(v_dados.last()).vr_nrctremp := 341925;
  v_dados(v_dados.last()).vr_vllanmto := 193.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16901428;
  v_dados(v_dados.last()).vr_nrctremp := 347163;
  v_dados(v_dados.last()).vr_vllanmto := 98.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17148502;
  v_dados(v_dados.last()).vr_nrctremp := 424366;
  v_dados(v_dados.last()).vr_vllanmto := 128913.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17206103;
  v_dados(v_dados.last()).vr_nrctremp := 361318;
  v_dados(v_dados.last()).vr_vllanmto := 221.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17539110;
  v_dados(v_dados.last()).vr_nrctremp := 378482;
  v_dados(v_dados.last()).vr_vllanmto := 51114.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17593824;
  v_dados(v_dados.last()).vr_nrctremp := 382549;
  v_dados(v_dados.last()).vr_vllanmto := 1016.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17759498;
  v_dados(v_dados.last()).vr_nrctremp := 390238;
  v_dados(v_dados.last()).vr_vllanmto := 293.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17759498;
  v_dados(v_dados.last()).vr_nrctremp := 390735;
  v_dados(v_dados.last()).vr_vllanmto := 40.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17801222;
  v_dados(v_dados.last()).vr_nrctremp := 392202;
  v_dados(v_dados.last()).vr_vllanmto := 78.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17835577;
  v_dados(v_dados.last()).vr_nrctremp := 394131;
  v_dados(v_dados.last()).vr_vllanmto := 172.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17959764;
  v_dados(v_dados.last()).vr_nrctremp := 400394;
  v_dados(v_dados.last()).vr_vllanmto := 9845.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17985692;
  v_dados(v_dados.last()).vr_nrctremp := 401982;
  v_dados(v_dados.last()).vr_vllanmto := 86.03;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 197394;
  v_dados(v_dados.last()).vr_nrctremp := 86002;
  v_dados(v_dados.last()).vr_vllanmto := 146.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 6308.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 3905;
  v_dados(v_dados.last()).vr_nrctremp := 300931;
  v_dados(v_dados.last()).vr_vllanmto := 1532.67;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 9773.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 23388;
  v_dados(v_dados.last()).vr_nrctremp := 259182;
  v_dados(v_dados.last()).vr_vllanmto := 11296.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 35599;
  v_dados(v_dados.last()).vr_nrctremp := 303991;
  v_dados(v_dados.last()).vr_vllanmto := 502.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61751;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 4653.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 77763;
  v_dados(v_dados.last()).vr_nrctremp := 247455;
  v_dados(v_dados.last()).vr_vllanmto := 135.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78638;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 196.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 79448;
  v_dados(v_dados.last()).vr_nrctremp := 314754;
  v_dados(v_dados.last()).vr_vllanmto := 270.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 90360;
  v_dados(v_dados.last()).vr_nrctremp := 71345;
  v_dados(v_dados.last()).vr_vllanmto := 1361.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 94730;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 2178.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116491;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 3828.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 67611;
  v_dados(v_dados.last()).vr_vllanmto := 3206.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 247445;
  v_dados(v_dados.last()).vr_vllanmto := 140.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 298187;
  v_dados(v_dados.last()).vr_vllanmto := 446.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 128333;
  v_dados(v_dados.last()).vr_nrctremp := 174807;
  v_dados(v_dados.last()).vr_vllanmto := 3233.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 139904;
  v_dados(v_dados.last()).vr_nrctremp := 269510;
  v_dados(v_dados.last()).vr_vllanmto := 41.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 140902;
  v_dados(v_dados.last()).vr_nrctremp := 78237;
  v_dados(v_dados.last()).vr_vllanmto := 33.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141496;
  v_dados(v_dados.last()).vr_nrctremp := 255202;
  v_dados(v_dados.last()).vr_vllanmto := 1126.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 148253;
  v_dados(v_dados.last()).vr_nrctremp := 236630;
  v_dados(v_dados.last()).vr_vllanmto := 53.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 148318;
  v_dados(v_dados.last()).vr_nrctremp := 67246;
  v_dados(v_dados.last()).vr_vllanmto := 4132.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160644;
  v_dados(v_dados.last()).vr_nrctremp := 65833;
  v_dados(v_dados.last()).vr_vllanmto := 1880.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 169757;
  v_dados(v_dados.last()).vr_nrctremp := 303664;
  v_dados(v_dados.last()).vr_vllanmto := 36.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170488;
  v_dados(v_dados.last()).vr_nrctremp := 252797;
  v_dados(v_dados.last()).vr_vllanmto := 3220.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 230666;
  v_dados(v_dados.last()).vr_vllanmto := 351.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 248810;
  v_dados(v_dados.last()).vr_vllanmto := 92.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 254372;
  v_dados(v_dados.last()).vr_vllanmto := 2754.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 273151;
  v_dados(v_dados.last()).vr_vllanmto := 112;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 287913;
  v_dados(v_dados.last()).vr_vllanmto := 142.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 309165;
  v_dados(v_dados.last()).vr_vllanmto := 185.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172979;
  v_dados(v_dados.last()).vr_nrctremp := 70406;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172979;
  v_dados(v_dados.last()).vr_nrctremp := 259772;
  v_dados(v_dados.last()).vr_vllanmto := 22.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172979;
  v_dados(v_dados.last()).vr_nrctremp := 272288;
  v_dados(v_dados.last()).vr_vllanmto := 32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184349;
  v_dados(v_dados.last()).vr_nrctremp := 302724;
  v_dados(v_dados.last()).vr_vllanmto := 158.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 247626;
  v_dados(v_dados.last()).vr_vllanmto := 829.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 299304;
  v_dados(v_dados.last()).vr_vllanmto := 198.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184390;
  v_dados(v_dados.last()).vr_nrctremp := 286467;
  v_dados(v_dados.last()).vr_vllanmto := 310.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185531;
  v_dados(v_dados.last()).vr_nrctremp := 205263;
  v_dados(v_dados.last()).vr_vllanmto := 1346.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 114018;
  v_dados(v_dados.last()).vr_vllanmto := 539.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 130951;
  v_dados(v_dados.last()).vr_vllanmto := 319.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 174443;
  v_dados(v_dados.last()).vr_vllanmto := 6508.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 283372;
  v_dados(v_dados.last()).vr_vllanmto := 6508.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186139;
  v_dados(v_dados.last()).vr_nrctremp := 79508;
  v_dados(v_dados.last()).vr_vllanmto := 642.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186201;
  v_dados(v_dados.last()).vr_nrctremp := 68975;
  v_dados(v_dados.last()).vr_vllanmto := 193.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186740;
  v_dados(v_dados.last()).vr_nrctremp := 308515;
  v_dados(v_dados.last()).vr_vllanmto := 12912.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187348;
  v_dados(v_dados.last()).vr_nrctremp := 199528;
  v_dados(v_dados.last()).vr_vllanmto := 389.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 184919;
  v_dados(v_dados.last()).vr_vllanmto := 203.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 274702;
  v_dados(v_dados.last()).vr_vllanmto := 182.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187615;
  v_dados(v_dados.last()).vr_nrctremp := 172942;
  v_dados(v_dados.last()).vr_vllanmto := 10216.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187704;
  v_dados(v_dados.last()).vr_nrctremp := 295630;
  v_dados(v_dados.last()).vr_vllanmto := 6577.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 238369;
  v_dados(v_dados.last()).vr_vllanmto := 97.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 268418;
  v_dados(v_dados.last()).vr_vllanmto := 1038.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 1108.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139845;
  v_dados(v_dados.last()).vr_vllanmto := 391.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 148826;
  v_dados(v_dados.last()).vr_vllanmto := 331.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 187546;
  v_dados(v_dados.last()).vr_vllanmto := 817.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 202660;
  v_dados(v_dados.last()).vr_vllanmto := 321.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 284704;
  v_dados(v_dados.last()).vr_vllanmto := 534.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188336;
  v_dados(v_dados.last()).vr_nrctremp := 192883;
  v_dados(v_dados.last()).vr_vllanmto := 389.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188336;
  v_dados(v_dados.last()).vr_nrctremp := 249723;
  v_dados(v_dados.last()).vr_vllanmto := 357.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188433;
  v_dados(v_dados.last()).vr_nrctremp := 268186;
  v_dados(v_dados.last()).vr_vllanmto := 30.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188719;
  v_dados(v_dados.last()).vr_nrctremp := 254965;
  v_dados(v_dados.last()).vr_vllanmto := 520.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189790;
  v_dados(v_dados.last()).vr_nrctremp := 212748;
  v_dados(v_dados.last()).vr_vllanmto := 942.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189790;
  v_dados(v_dados.last()).vr_nrctremp := 231817;
  v_dados(v_dados.last()).vr_vllanmto := 153.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192902;
  v_dados(v_dados.last()).vr_nrctremp := 87507;
  v_dados(v_dados.last()).vr_vllanmto := 5429.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 196584;
  v_dados(v_dados.last()).vr_nrctremp := 302114;
  v_dados(v_dados.last()).vr_vllanmto := 1015.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 204803;
  v_dados(v_dados.last()).vr_nrctremp := 300046;
  v_dados(v_dados.last()).vr_vllanmto := 48.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 215902;
  v_dados(v_dados.last()).vr_nrctremp := 340858;
  v_dados(v_dados.last()).vr_vllanmto := 23106.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 218065;
  v_dados(v_dados.last()).vr_nrctremp := 268132;
  v_dados(v_dados.last()).vr_vllanmto := 363.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 221872;
  v_dados(v_dados.last()).vr_nrctremp := 201862;
  v_dados(v_dados.last()).vr_vllanmto := 12794.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 222046;
  v_dados(v_dados.last()).vr_nrctremp := 292342;
  v_dados(v_dados.last()).vr_vllanmto := 2113.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 223859;
  v_dados(v_dados.last()).vr_nrctremp := 313667;
  v_dados(v_dados.last()).vr_vllanmto := 11.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 229083;
  v_dados(v_dados.last()).vr_nrctremp := 288206;
  v_dados(v_dados.last()).vr_vllanmto := 1189.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 1758.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141760;
  v_dados(v_dados.last()).vr_vllanmto := 391.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 105884;
  v_dados(v_dados.last()).vr_vllanmto := 4096.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 2385.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 249475;
  v_dados(v_dados.last()).vr_nrctremp := 291676;
  v_dados(v_dados.last()).vr_vllanmto := 269.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 253057;
  v_dados(v_dados.last()).vr_nrctremp := 94143;
  v_dados(v_dados.last()).vr_vllanmto := 2279.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261122;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 5681.24;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 50935;
  v_dados(v_dados.last()).vr_vllanmto := 68.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 192919;
  v_dados(v_dados.last()).vr_vllanmto := 2243.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 238468;
  v_dados(v_dados.last()).vr_vllanmto := 2228.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 198.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 42.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 153126;
  v_dados(v_dados.last()).vr_vllanmto := 1026.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 192497;
  v_dados(v_dados.last()).vr_vllanmto := 750.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272116;
  v_dados(v_dados.last()).vr_nrctremp := 252189;
  v_dados(v_dados.last()).vr_vllanmto := 1412.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 222053;
  v_dados(v_dados.last()).vr_vllanmto := 58.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 279838;
  v_dados(v_dados.last()).vr_nrctremp := 264923;
  v_dados(v_dados.last()).vr_vllanmto := 54.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 2754.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 282189;
  v_dados(v_dados.last()).vr_nrctremp := 244509;
  v_dados(v_dados.last()).vr_vllanmto := 50.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289094;
  v_dados(v_dados.last()).vr_nrctremp := 227800;
  v_dados(v_dados.last()).vr_vllanmto := 2928.09;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289485;
  v_dados(v_dados.last()).vr_nrctremp := 234346;
  v_dados(v_dados.last()).vr_vllanmto := 106.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 291854;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 4435.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 297453;
  v_dados(v_dados.last()).vr_nrctremp := 285312;
  v_dados(v_dados.last()).vr_vllanmto := 2365.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299596;
  v_dados(v_dados.last()).vr_nrctremp := 266459;
  v_dados(v_dados.last()).vr_vllanmto := 278.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299979;
  v_dados(v_dados.last()).vr_nrctremp := 224042;
  v_dados(v_dados.last()).vr_vllanmto := 58.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 303771;
  v_dados(v_dados.last()).vr_nrctremp := 128054;
  v_dados(v_dados.last()).vr_vllanmto := 20.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 76421;
  v_dados(v_dados.last()).vr_vllanmto := 1180.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 77074;
  v_dados(v_dados.last()).vr_vllanmto := 679.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 319260;
  v_dados(v_dados.last()).vr_nrctremp := 82744;
  v_dados(v_dados.last()).vr_vllanmto := 1478.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 327832;
  v_dados(v_dados.last()).vr_nrctremp := 290267;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328014;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 1676.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 334685;
  v_dados(v_dados.last()).vr_nrctremp := 111025;
  v_dados(v_dados.last()).vr_vllanmto := 363.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 334685;
  v_dados(v_dados.last()).vr_nrctremp := 275058;
  v_dados(v_dados.last()).vr_vllanmto := 73.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 339067;
  v_dados(v_dados.last()).vr_nrctremp := 67555;
  v_dados(v_dados.last()).vr_vllanmto := 24.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 344192;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 16922.39;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 360961;
  v_dados(v_dados.last()).vr_nrctremp := 151569;
  v_dados(v_dados.last()).vr_vllanmto := 22.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 163160;
  v_dados(v_dados.last()).vr_vllanmto := 259.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 300625;
  v_dados(v_dados.last()).vr_vllanmto := 709.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 383007;
  v_dados(v_dados.last()).vr_nrctremp := 104758;
  v_dados(v_dados.last()).vr_vllanmto := 21677.19;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 387282;
  v_dados(v_dados.last()).vr_nrctremp := 355408;
  v_dados(v_dados.last()).vr_vllanmto := 50.34;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 410977;
  v_dados(v_dados.last()).vr_nrctremp := 307659;
  v_dados(v_dados.last()).vr_vllanmto := 209.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 416606;
  v_dados(v_dados.last()).vr_nrctremp := 179261;
  v_dados(v_dados.last()).vr_vllanmto := 696.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 4122.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 1541.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 427420;
  v_dados(v_dados.last()).vr_nrctremp := 167789;
  v_dados(v_dados.last()).vr_vllanmto := 220.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 427420;
  v_dados(v_dados.last()).vr_nrctremp := 336549;
  v_dados(v_dados.last()).vr_vllanmto := 239.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 435090;
  v_dados(v_dados.last()).vr_nrctremp := 305094;
  v_dados(v_dados.last()).vr_vllanmto := 305.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 436569;
  v_dados(v_dados.last()).vr_nrctremp := 263881;
  v_dados(v_dados.last()).vr_vllanmto := 144.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445100;
  v_dados(v_dados.last()).vr_nrctremp := 63764;
  v_dados(v_dados.last()).vr_vllanmto := 530.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 11182.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 253030;
  v_dados(v_dados.last()).vr_vllanmto := 1801.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 451088;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 2045.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 451088;
  v_dados(v_dados.last()).vr_nrctremp := 290521;
  v_dados(v_dados.last()).vr_vllanmto := 28.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 452211;
  v_dados(v_dados.last()).vr_nrctremp := 66716;
  v_dados(v_dados.last()).vr_vllanmto := 497.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 906.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480517;
  v_dados(v_dados.last()).vr_nrctremp := 209089;
  v_dados(v_dados.last()).vr_vllanmto := 1807.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 498211;
  v_dados(v_dados.last()).vr_nrctremp := 319203;
  v_dados(v_dados.last()).vr_vllanmto := 206.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 141142;
  v_dados(v_dados.last()).vr_vllanmto := 645.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 150785;
  v_dados(v_dados.last()).vr_vllanmto := 1697.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 165366;
  v_dados(v_dados.last()).vr_vllanmto := 1206.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 185908;
  v_dados(v_dados.last()).vr_vllanmto := 2454.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 194673;
  v_dados(v_dados.last()).vr_vllanmto := 2443.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 230274;
  v_dados(v_dados.last()).vr_vllanmto := 2696.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 517399;
  v_dados(v_dados.last()).vr_nrctremp := 262464;
  v_dados(v_dados.last()).vr_vllanmto := 8176.05;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 10364.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 145861;
  v_dados(v_dados.last()).vr_vllanmto := 1622.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 253534;
  v_dados(v_dados.last()).vr_vllanmto := 398.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 290708;
  v_dados(v_dados.last()).vr_vllanmto := 903.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 535710;
  v_dados(v_dados.last()).vr_nrctremp := 283864;
  v_dados(v_dados.last()).vr_vllanmto := 13.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 539899;
  v_dados(v_dados.last()).vr_nrctremp := 250086;
  v_dados(v_dados.last()).vr_vllanmto := 2222.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 543144;
  v_dados(v_dados.last()).vr_nrctremp := 210362;
  v_dados(v_dados.last()).vr_vllanmto := 1480.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 544396;
  v_dados(v_dados.last()).vr_nrctremp := 349801;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 551058;
  v_dados(v_dados.last()).vr_nrctremp := 300648;
  v_dados(v_dados.last()).vr_vllanmto := 974.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 551538;
  v_dados(v_dados.last()).vr_nrctremp := 261412;
  v_dados(v_dados.last()).vr_vllanmto := 1071.72;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 553964;
  v_dados(v_dados.last()).vr_nrctremp := 340506;
  v_dados(v_dados.last()).vr_vllanmto := 37.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 554871;
  v_dados(v_dados.last()).vr_nrctremp := 195850;
  v_dados(v_dados.last()).vr_vllanmto := 98.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 554871;
  v_dados(v_dados.last()).vr_nrctremp := 309453;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 559865;
  v_dados(v_dados.last()).vr_nrctremp := 220482;
  v_dados(v_dados.last()).vr_vllanmto := 340.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 563498;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 1537.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565849;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 920.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572497;
  v_dados(v_dados.last()).vr_nrctremp := 272741;
  v_dados(v_dados.last()).vr_vllanmto := 19432.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572497;
  v_dados(v_dados.last()).vr_nrctremp := 326092;
  v_dados(v_dados.last()).vr_vllanmto := 8676.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572497;
  v_dados(v_dados.last()).vr_nrctremp := 342184;
  v_dados(v_dados.last()).vr_vllanmto := 4998.21;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 577090;
  v_dados(v_dados.last()).vr_nrctremp := 198976;
  v_dados(v_dados.last()).vr_vllanmto := 519.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 582042;
  v_dados(v_dados.last()).vr_nrctremp := 166819;
  v_dados(v_dados.last()).vr_vllanmto := 4688.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 592757;
  v_dados(v_dados.last()).vr_nrctremp := 289207;
  v_dados(v_dados.last()).vr_vllanmto := 31.65;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 592781;
  v_dados(v_dados.last()).vr_nrctremp := 271052;
  v_dados(v_dados.last()).vr_vllanmto := 2465.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 594024;
  v_dados(v_dados.last()).vr_nrctremp := 283088;
  v_dados(v_dados.last()).vr_vllanmto := 79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 610895;
  v_dados(v_dados.last()).vr_nrctremp := 227415;
  v_dados(v_dados.last()).vr_vllanmto := 5459;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 611301;
  v_dados(v_dados.last()).vr_nrctremp := 318423;
  v_dados(v_dados.last()).vr_vllanmto := 208.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 612073;
  v_dados(v_dados.last()).vr_nrctremp := 303387;
  v_dados(v_dados.last()).vr_vllanmto := 36.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 2172.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 615366;
  v_dados(v_dados.last()).vr_nrctremp := 295571;
  v_dados(v_dados.last()).vr_vllanmto := 292.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 629154;
  v_dados(v_dados.last()).vr_nrctremp := 275238;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638579;
  v_dados(v_dados.last()).vr_nrctremp := 250085;
  v_dados(v_dados.last()).vr_vllanmto := 698.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 639958;
  v_dados(v_dados.last()).vr_nrctremp := 240582;
  v_dados(v_dados.last()).vr_vllanmto := 293.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647527;
  v_dados(v_dados.last()).vr_nrctremp := 152360;
  v_dados(v_dados.last()).vr_vllanmto := 1127.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647527;
  v_dados(v_dados.last()).vr_nrctremp := 191578;
  v_dados(v_dados.last()).vr_vllanmto := 508.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647845;
  v_dados(v_dados.last()).vr_nrctremp := 192882;
  v_dados(v_dados.last()).vr_vllanmto := 1911.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 652610;
  v_dados(v_dados.last()).vr_nrctremp := 212819;
  v_dados(v_dados.last()).vr_vllanmto := 1264.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 653829;
  v_dados(v_dados.last()).vr_nrctremp := 295939;
  v_dados(v_dados.last()).vr_vllanmto := 73.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 662569;
  v_dados(v_dados.last()).vr_nrctremp := 160854;
  v_dados(v_dados.last()).vr_vllanmto := 140.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663930;
  v_dados(v_dados.last()).vr_nrctremp := 304608;
  v_dados(v_dados.last()).vr_vllanmto := 1493.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 666114;
  v_dados(v_dados.last()).vr_nrctremp := 297874;
  v_dados(v_dados.last()).vr_vllanmto := 218.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 669946;
  v_dados(v_dados.last()).vr_nrctremp := 316370;
  v_dados(v_dados.last()).vr_vllanmto := 17.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 678856;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 7137.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 679666;
  v_dados(v_dados.last()).vr_nrctremp := 322767;
  v_dados(v_dados.last()).vr_vllanmto := 25.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 692328;
  v_dados(v_dados.last()).vr_nrctremp := 315004;
  v_dados(v_dados.last()).vr_vllanmto := 7501.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 1769.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 292212;
  v_dados(v_dados.last()).vr_vllanmto := 899.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 705926;
  v_dados(v_dados.last()).vr_nrctremp := 245304;
  v_dados(v_dados.last()).vr_vllanmto := 2190.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 735345;
  v_dados(v_dados.last()).vr_nrctremp := 310009;
  v_dados(v_dados.last()).vr_vllanmto := 83.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 754528;
  v_dados(v_dados.last()).vr_nrctremp := 261384;
  v_dados(v_dados.last()).vr_vllanmto := 1601.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14135043;
  v_dados(v_dados.last()).vr_nrctremp := 303642;
  v_dados(v_dados.last()).vr_vllanmto := 794.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14154080;
  v_dados(v_dados.last()).vr_nrctremp := 291115;
  v_dados(v_dados.last()).vr_vllanmto := 489.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14224259;
  v_dados(v_dados.last()).vr_nrctremp := 176904;
  v_dados(v_dados.last()).vr_vllanmto := 2265.12;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14224259;
  v_dados(v_dados.last()).vr_nrctremp := 176905;
  v_dados(v_dados.last()).vr_vllanmto := 2265.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14545810;
  v_dados(v_dados.last()).vr_nrctremp := 280690;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 241295;
  v_dados(v_dados.last()).vr_vllanmto := 2449.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 290158;
  v_dados(v_dados.last()).vr_vllanmto := 215.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14601524;
  v_dados(v_dados.last()).vr_nrctremp := 201815;
  v_dados(v_dados.last()).vr_vllanmto := 824.38;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14602733;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 1257.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14616084;
  v_dados(v_dados.last()).vr_nrctremp := 294867;
  v_dados(v_dados.last()).vr_vllanmto := 624.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14682206;
  v_dados(v_dados.last()).vr_nrctremp := 286780;
  v_dados(v_dados.last()).vr_vllanmto := 271.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14722720;
  v_dados(v_dados.last()).vr_nrctremp := 200765;
  v_dados(v_dados.last()).vr_vllanmto := 3491.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14775085;
  v_dados(v_dados.last()).vr_nrctremp := 236934;
  v_dados(v_dados.last()).vr_vllanmto := 166.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14775085;
  v_dados(v_dados.last()).vr_nrctremp := 294034;
  v_dados(v_dados.last()).vr_vllanmto := 28.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14792656;
  v_dados(v_dados.last()).vr_nrctremp := 234156;
  v_dados(v_dados.last()).vr_vllanmto := 1974.96;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14820900;
  v_dados(v_dados.last()).vr_nrctremp := 307322;
  v_dados(v_dados.last()).vr_vllanmto := 229.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14840324;
  v_dados(v_dados.last()).vr_nrctremp := 278852;
  v_dados(v_dados.last()).vr_vllanmto := 388.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 209246;
  v_dados(v_dados.last()).vr_vllanmto := 5002.16;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 238463;
  v_dados(v_dados.last()).vr_vllanmto := 6363.36;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 267064;
  v_dados(v_dados.last()).vr_vllanmto := 9104.79;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14984857;
  v_dados(v_dados.last()).vr_nrctremp := 268140;
  v_dados(v_dados.last()).vr_vllanmto := 18.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 215815;
  v_dados(v_dados.last()).vr_vllanmto := 1776.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 219069;
  v_dados(v_dados.last()).vr_vllanmto := 2129;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 247863;
  v_dados(v_dados.last()).vr_vllanmto := 581.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 274680;
  v_dados(v_dados.last()).vr_vllanmto := 576.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15072320;
  v_dados(v_dados.last()).vr_nrctremp := 304380;
  v_dados(v_dados.last()).vr_vllanmto := 323.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15377660;
  v_dados(v_dados.last()).vr_nrctremp := 280792;
  v_dados(v_dados.last()).vr_vllanmto := 2335.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 230219;
  v_dados(v_dados.last()).vr_vllanmto := 441.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 275871;
  v_dados(v_dados.last()).vr_vllanmto := 136.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 306655;
  v_dados(v_dados.last()).vr_vllanmto := 42.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15404331;
  v_dados(v_dados.last()).vr_nrctremp := 234752;
  v_dados(v_dados.last()).vr_vllanmto := 21.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15409007;
  v_dados(v_dados.last()).vr_nrctremp := 230711;
  v_dados(v_dados.last()).vr_vllanmto := 433.2;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15409007;
  v_dados(v_dados.last()).vr_nrctremp := 273783;
  v_dados(v_dados.last()).vr_vllanmto := 168.85;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15501710;
  v_dados(v_dados.last()).vr_nrctremp := 265084;
  v_dados(v_dados.last()).vr_vllanmto := 3813.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15541010;
  v_dados(v_dados.last()).vr_nrctremp := 314150;
  v_dados(v_dados.last()).vr_vllanmto := 990.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15577791;
  v_dados(v_dados.last()).vr_nrctremp := 238348;
  v_dados(v_dados.last()).vr_vllanmto := 27960.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15710530;
  v_dados(v_dados.last()).vr_nrctremp := 288622;
  v_dados(v_dados.last()).vr_vllanmto := 5844.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15718670;
  v_dados(v_dados.last()).vr_nrctremp := 329301;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 245466;
  v_dados(v_dados.last()).vr_vllanmto := 1542.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 262208;
  v_dados(v_dados.last()).vr_vllanmto := 48.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 276541;
  v_dados(v_dados.last()).vr_vllanmto := 66.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 295195;
  v_dados(v_dados.last()).vr_vllanmto := 481.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 298678;
  v_dados(v_dados.last()).vr_vllanmto := 352.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15823822;
  v_dados(v_dados.last()).vr_nrctremp := 350345;
  v_dados(v_dados.last()).vr_vllanmto := 30.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15881270;
  v_dados(v_dados.last()).vr_nrctremp := 292500;
  v_dados(v_dados.last()).vr_vllanmto := 13.12;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16018311;
  v_dados(v_dados.last()).vr_nrctremp := 258541;
  v_dados(v_dados.last()).vr_vllanmto := 67.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16118790;
  v_dados(v_dados.last()).vr_nrctremp := 264780;
  v_dados(v_dados.last()).vr_vllanmto := 1773.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16210107;
  v_dados(v_dados.last()).vr_nrctremp := 276225;
  v_dados(v_dados.last()).vr_vllanmto := 175.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16250559;
  v_dados(v_dados.last()).vr_nrctremp := 281788;
  v_dados(v_dados.last()).vr_vllanmto := 12893.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16257324;
  v_dados(v_dados.last()).vr_nrctremp := 268640;
  v_dados(v_dados.last()).vr_vllanmto := 1865.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16337743;
  v_dados(v_dados.last()).vr_nrctremp := 286588;
  v_dados(v_dados.last()).vr_vllanmto := 135.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16337760;
  v_dados(v_dados.last()).vr_nrctremp := 286889;
  v_dados(v_dados.last()).vr_vllanmto := 932.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 6169.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16530667;
  v_dados(v_dados.last()).vr_nrctremp := 279611;
  v_dados(v_dados.last()).vr_vllanmto := 1574.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16744349;
  v_dados(v_dados.last()).vr_nrctremp := 288036;
  v_dados(v_dados.last()).vr_vllanmto := 414.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16744349;
  v_dados(v_dados.last()).vr_nrctremp := 302386;
  v_dados(v_dados.last()).vr_vllanmto := 408.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16984919;
  v_dados(v_dados.last()).vr_nrctremp := 297126;
  v_dados(v_dados.last()).vr_vllanmto := 256.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17035856;
  v_dados(v_dados.last()).vr_nrctremp := 312550;
  v_dados(v_dados.last()).vr_vllanmto := 12.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17048958;
  v_dados(v_dados.last()).vr_nrctremp := 318419;
  v_dados(v_dados.last()).vr_vllanmto := 429.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17136733;
  v_dados(v_dados.last()).vr_nrctremp := 302270;
  v_dados(v_dados.last()).vr_vllanmto := 1655.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17146780;
  v_dados(v_dados.last()).vr_nrctremp := 326978;
  v_dados(v_dados.last()).vr_vllanmto := 45652.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17345880;
  v_dados(v_dados.last()).vr_nrctremp := 309336;
  v_dados(v_dados.last()).vr_vllanmto := 1026.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17477824;
  v_dados(v_dados.last()).vr_nrctremp := 350847;
  v_dados(v_dados.last()).vr_vllanmto := 875.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18443354;
  v_dados(v_dados.last()).vr_nrctremp := 356983;
  v_dados(v_dados.last()).vr_vllanmto := 104185.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18535917;
  v_dados(v_dados.last()).vr_nrctremp := 352527;
  v_dados(v_dados.last()).vr_vllanmto := 1926.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18535917;
  v_dados(v_dados.last()).vr_nrctremp := 355045;
  v_dados(v_dados.last()).vr_vllanmto := 1893.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18535917;
  v_dados(v_dados.last()).vr_nrctremp := 355046;
  v_dados(v_dados.last()).vr_vllanmto := 7719.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18535917;
  v_dados(v_dados.last()).vr_nrctremp := 361594;
  v_dados(v_dados.last()).vr_vllanmto := 12844.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18620230;
  v_dados(v_dados.last()).vr_nrctremp := 355656;
  v_dados(v_dados.last()).vr_vllanmto := 72953.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18620230;
  v_dados(v_dados.last()).vr_nrctremp := 355894;
  v_dados(v_dados.last()).vr_vllanmto := 185896;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18874843;
  v_dados(v_dados.last()).vr_nrctremp := 364272;
  v_dados(v_dados.last()).vr_vllanmto := 4180.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP

    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;

    OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta, pr_nrctremp => v_dados(x).vr_nrctremp);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;

    IF rw_crapass.inliquid = 1 AND rw_crapass.inprejuz = 0 THEN

      IF rw_crapass.saldo_contrato <> 0 THEN

          vr_lancamen := 0;
          vr_historic := 0;

          IF nvl(rw_crapass.saldo_contrato, 0) < 0 THEN
              vr_historic := 3918;
              vr_lancamen := rw_crapass.saldo_contrato * -1;
            ELSIF nvl(rw_crapass.saldo_contrato, 0) > 0 THEN
              vr_historic := 3919;
              vr_lancamen := rw_crapass.saldo_contrato;
          END IF;


            cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => v_dados(x).vr_cdcooper,
                                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                   pr_cdagenci => rw_crapass.cdagenci,
                                                   pr_cdbccxlt => 100,
                                                   pr_cdoperad => 1,
                                                   pr_cdpactra => rw_crapass.cdagenci,
                                                   pr_tplotmov => 5,
                                                   pr_nrdolote => 600031,
                                                   pr_nrdconta => v_dados(x).vr_nrdconta,
                                                   pr_cdhistor => vr_historic,
                                                   pr_nrctremp => v_dados(x).vr_nrctremp,
                                                   pr_vllanmto => vr_lancamen,
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

        END IF;
    ELSE
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
