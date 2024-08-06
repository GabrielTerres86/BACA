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
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
           ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
    SELECT
        ass.cdagenci,
        CASE
            WHEN epr.inliquid = 1 AND epr.inprejuz = 0 THEN
                credito.obtersaldocontratoliquidadoconsignado(
                    pr_cdcooper => epr.cdcooper,
                    pr_nrdconta => epr.nrdconta,
                    pr_nrctremp => epr.nrctremp
                )
            ELSE
                1
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
  v_dados(v_dados.last()).vr_nrdconta := 493;
  v_dados(v_dados.last()).vr_nrctremp := 7716533;
  v_dados(v_dados.last()).vr_vllanmto := 447.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1996;
  v_dados(v_dados.last()).vr_nrctremp := 6261793;
  v_dados(v_dados.last()).vr_vllanmto := 164.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8826;
  v_dados(v_dados.last()).vr_nrctremp := 6788141;
  v_dados(v_dados.last()).vr_vllanmto := 39.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8826;
  v_dados(v_dados.last()).vr_nrctremp := 8163414;
  v_dados(v_dados.last()).vr_vllanmto := 335.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 23086;
  v_dados(v_dados.last()).vr_nrctremp := 5943455;
  v_dados(v_dados.last()).vr_vllanmto := 150.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 453080;
  v_dados(v_dados.last()).vr_nrctremp := 7295553;
  v_dados(v_dados.last()).vr_vllanmto := 40.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 626007;
  v_dados(v_dados.last()).vr_nrctremp := 6856446;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 765295;
  v_dados(v_dados.last()).vr_nrctremp := 7492262;
  v_dados(v_dados.last()).vr_vllanmto := 20209.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 773565;
  v_dados(v_dados.last()).vr_nrctremp := 4922540;
  v_dados(v_dados.last()).vr_vllanmto := 121.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 869961;
  v_dados(v_dados.last()).vr_nrctremp := 7992211;
  v_dados(v_dados.last()).vr_vllanmto := 13.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1505394;
  v_dados(v_dados.last()).vr_nrctremp := 5366514;
  v_dados(v_dados.last()).vr_vllanmto := 85.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1833413;
  v_dados(v_dados.last()).vr_nrctremp := 7229630;
  v_dados(v_dados.last()).vr_vllanmto := 12.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1923846;
  v_dados(v_dados.last()).vr_nrctremp := 8045092;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1927337;
  v_dados(v_dados.last()).vr_nrctremp := 5139328;
  v_dados(v_dados.last()).vr_vllanmto := 25128.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1953214;
  v_dados(v_dados.last()).vr_nrctremp := 7509178;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1970976;
  v_dados(v_dados.last()).vr_nrctremp := 8009812;
  v_dados(v_dados.last()).vr_vllanmto := 19.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2001748;
  v_dados(v_dados.last()).vr_nrctremp := 7965959;
  v_dados(v_dados.last()).vr_vllanmto := 35.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2017202;
  v_dados(v_dados.last()).vr_nrctremp := 8161698;
  v_dados(v_dados.last()).vr_vllanmto := 17.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2017695;
  v_dados(v_dados.last()).vr_nrctremp := 7654661;
  v_dados(v_dados.last()).vr_vllanmto := 11.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2019558;
  v_dados(v_dados.last()).vr_nrctremp := 7351781;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2038650;
  v_dados(v_dados.last()).vr_nrctremp := 3664319;
  v_dados(v_dados.last()).vr_vllanmto := 16.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2066670;
  v_dados(v_dados.last()).vr_nrctremp := 7074929;
  v_dados(v_dados.last()).vr_vllanmto := 12.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2128969;
  v_dados(v_dados.last()).vr_nrctremp := 7410061;
  v_dados(v_dados.last()).vr_vllanmto := 16.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2151707;
  v_dados(v_dados.last()).vr_nrctremp := 7930270;
  v_dados(v_dados.last()).vr_vllanmto := 24.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2182955;
  v_dados(v_dados.last()).vr_nrctremp := 4076508;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2195399;
  v_dados(v_dados.last()).vr_nrctremp := 6809716;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2195399;
  v_dados(v_dados.last()).vr_nrctremp := 7493988;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2203774;
  v_dados(v_dados.last()).vr_nrctremp := 6380322;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2237180;
  v_dados(v_dados.last()).vr_nrctremp := 7164271;
  v_dados(v_dados.last()).vr_vllanmto := 22.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2296667;
  v_dados(v_dados.last()).vr_nrctremp := 4423623;
  v_dados(v_dados.last()).vr_vllanmto := 15.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2306786;
  v_dados(v_dados.last()).vr_nrctremp := 8072790;
  v_dados(v_dados.last()).vr_vllanmto := 20.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2312220;
  v_dados(v_dados.last()).vr_nrctremp := 7059873;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2342863;
  v_dados(v_dados.last()).vr_nrctremp := 6692582;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2342863;
  v_dados(v_dados.last()).vr_nrctremp := 6973498;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2351366;
  v_dados(v_dados.last()).vr_nrctremp := 7685825;
  v_dados(v_dados.last()).vr_vllanmto := 20.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2352427;
  v_dados(v_dados.last()).vr_nrctremp := 6540635;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2366452;
  v_dados(v_dados.last()).vr_nrctremp := 7354171;
  v_dados(v_dados.last()).vr_vllanmto := 31.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2388952;
  v_dados(v_dados.last()).vr_nrctremp := 8123308;
  v_dados(v_dados.last()).vr_vllanmto := 19.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2393077;
  v_dados(v_dados.last()).vr_nrctremp := 6832100;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2415119;
  v_dados(v_dados.last()).vr_nrctremp := 4440402;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2442876;
  v_dados(v_dados.last()).vr_nrctremp := 6947306;
  v_dados(v_dados.last()).vr_vllanmto := 21.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2512637;
  v_dados(v_dados.last()).vr_nrctremp := 7649248;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2513234;
  v_dados(v_dados.last()).vr_nrctremp := 6646862;
  v_dados(v_dados.last()).vr_vllanmto := 25.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2515938;
  v_dados(v_dados.last()).vr_nrctremp := 3969605;
  v_dados(v_dados.last()).vr_vllanmto := 20.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2537982;
  v_dados(v_dados.last()).vr_nrctremp := 7807476;
  v_dados(v_dados.last()).vr_vllanmto := 12.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2547562;
  v_dados(v_dados.last()).vr_nrctremp := 7971361;
  v_dados(v_dados.last()).vr_vllanmto := 20.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2570670;
  v_dados(v_dados.last()).vr_nrctremp := 7821098;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2604116;
  v_dados(v_dados.last()).vr_nrctremp := 6119888;
  v_dados(v_dados.last()).vr_vllanmto := 19.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2604990;
  v_dados(v_dados.last()).vr_nrctremp := 8057847;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2631040;
  v_dados(v_dados.last()).vr_nrctremp := 7024737;
  v_dados(v_dados.last()).vr_vllanmto := 40.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2660776;
  v_dados(v_dados.last()).vr_nrctremp := 7537904;
  v_dados(v_dados.last()).vr_vllanmto := 31.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2667053;
  v_dados(v_dados.last()).vr_nrctremp := 6217026;
  v_dados(v_dados.last()).vr_vllanmto := 10.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2676184;
  v_dados(v_dados.last()).vr_nrctremp := 8124812;
  v_dados(v_dados.last()).vr_vllanmto := 28.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2710374;
  v_dados(v_dados.last()).vr_nrctremp := 7966136;
  v_dados(v_dados.last()).vr_vllanmto := 70.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2713381;
  v_dados(v_dados.last()).vr_nrctremp := 6017285;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2747200;
  v_dados(v_dados.last()).vr_nrctremp := 5343342;
  v_dados(v_dados.last()).vr_vllanmto := 565.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2844591;
  v_dados(v_dados.last()).vr_nrctremp := 7196567;
  v_dados(v_dados.last()).vr_vllanmto := 26.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2846500;
  v_dados(v_dados.last()).vr_nrctremp := 7091891;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2944227;
  v_dados(v_dados.last()).vr_nrctremp := 4953363;
  v_dados(v_dados.last()).vr_vllanmto := 4857.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2953722;
  v_dados(v_dados.last()).vr_nrctremp := 7838944;
  v_dados(v_dados.last()).vr_vllanmto := 24.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2968177;
  v_dados(v_dados.last()).vr_nrctremp := 7996986;
  v_dados(v_dados.last()).vr_vllanmto := 22.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3005356;
  v_dados(v_dados.last()).vr_nrctremp := 6912519;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3076997;
  v_dados(v_dados.last()).vr_nrctremp := 7822538;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3077446;
  v_dados(v_dados.last()).vr_nrctremp := 3619639;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3083454;
  v_dados(v_dados.last()).vr_nrctremp := 7912580;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3127664;
  v_dados(v_dados.last()).vr_nrctremp := 8161141;
  v_dados(v_dados.last()).vr_vllanmto := 16.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3131440;
  v_dados(v_dados.last()).vr_nrctremp := 6781425;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3137589;
  v_dados(v_dados.last()).vr_nrctremp := 5625472;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3139255;
  v_dados(v_dados.last()).vr_nrctremp := 5545964;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3143880;
  v_dados(v_dados.last()).vr_nrctremp := 6839964;
  v_dados(v_dados.last()).vr_vllanmto := 5866.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3145727;
  v_dados(v_dados.last()).vr_nrctremp := 8038899;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3150631;
  v_dados(v_dados.last()).vr_nrctremp := 8121270;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3153886;
  v_dados(v_dados.last()).vr_nrctremp := 6748175;
  v_dados(v_dados.last()).vr_vllanmto := 1417.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3521109;
  v_dados(v_dados.last()).vr_nrctremp := 5592146;
  v_dados(v_dados.last()).vr_vllanmto := 15.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3522881;
  v_dados(v_dados.last()).vr_nrctremp := 7791921;
  v_dados(v_dados.last()).vr_vllanmto := 29.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3524833;
  v_dados(v_dados.last()).vr_nrctremp := 6906293;
  v_dados(v_dados.last()).vr_vllanmto := 34.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3524833;
  v_dados(v_dados.last()).vr_nrctremp := 7519418;
  v_dados(v_dados.last()).vr_vllanmto := 13.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3592294;
  v_dados(v_dados.last()).vr_nrctremp := 8147004;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3595803;
  v_dados(v_dados.last()).vr_nrctremp := 4521182;
  v_dados(v_dados.last()).vr_vllanmto := 1984.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3626180;
  v_dados(v_dados.last()).vr_nrctremp := 6695451;
  v_dados(v_dados.last()).vr_vllanmto := 20.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3626628;
  v_dados(v_dados.last()).vr_nrctremp := 7940509;
  v_dados(v_dados.last()).vr_vllanmto := 25.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3671151;
  v_dados(v_dados.last()).vr_nrctremp := 8060978;
  v_dados(v_dados.last()).vr_vllanmto := 17.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3709515;
  v_dados(v_dados.last()).vr_nrctremp := 7964200;
  v_dados(v_dados.last()).vr_vllanmto := 22.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3721124;
  v_dados(v_dados.last()).vr_nrctremp := 4816442;
  v_dados(v_dados.last()).vr_vllanmto := 6743.55;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3761240;
  v_dados(v_dados.last()).vr_nrctremp := 6864662;
  v_dados(v_dados.last()).vr_vllanmto := 24.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3784185;
  v_dados(v_dados.last()).vr_nrctremp := 8045712;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3789683;
  v_dados(v_dados.last()).vr_nrctremp := 8062195;
  v_dados(v_dados.last()).vr_vllanmto := 22.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3815382;
  v_dados(v_dados.last()).vr_nrctremp := 7380652;
  v_dados(v_dados.last()).vr_vllanmto := 21.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3820408;
  v_dados(v_dados.last()).vr_nrctremp := 8110756;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3829626;
  v_dados(v_dados.last()).vr_nrctremp := 8039087;
  v_dados(v_dados.last()).vr_vllanmto := 16.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3840972;
  v_dados(v_dados.last()).vr_nrctremp := 7955031;
  v_dados(v_dados.last()).vr_vllanmto := 31.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3864626;
  v_dados(v_dados.last()).vr_nrctremp := 3730749;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3870227;
  v_dados(v_dados.last()).vr_nrctremp := 7930804;
  v_dados(v_dados.last()).vr_vllanmto := 36.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3877787;
  v_dados(v_dados.last()).vr_nrctremp := 7815986;
  v_dados(v_dados.last()).vr_vllanmto := 12.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3886883;
  v_dados(v_dados.last()).vr_nrctremp := 6828075;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3892107;
  v_dados(v_dados.last()).vr_nrctremp := 8134609;
  v_dados(v_dados.last()).vr_vllanmto := 16.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3904202;
  v_dados(v_dados.last()).vr_nrctremp := 6071851;
  v_dados(v_dados.last()).vr_vllanmto := 15.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3916634;
  v_dados(v_dados.last()).vr_nrctremp := 6916215;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3920399;
  v_dados(v_dados.last()).vr_nrctremp := 5552101;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3961630;
  v_dados(v_dados.last()).vr_nrctremp := 4984115;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3966364;
  v_dados(v_dados.last()).vr_nrctremp := 6814009;
  v_dados(v_dados.last()).vr_vllanmto := 20.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3968944;
  v_dados(v_dados.last()).vr_nrctremp := 4606072;
  v_dados(v_dados.last()).vr_vllanmto := 12.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3981541;
  v_dados(v_dados.last()).vr_nrctremp := 7120866;
  v_dados(v_dados.last()).vr_vllanmto := 22.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4045645;
  v_dados(v_dados.last()).vr_nrctremp := 4815888;
  v_dados(v_dados.last()).vr_vllanmto := 8156.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4060768;
  v_dados(v_dados.last()).vr_nrctremp := 8099385;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6000355;
  v_dados(v_dados.last()).vr_nrctremp := 7499050;
  v_dados(v_dados.last()).vr_vllanmto := 22.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6005675;
  v_dados(v_dados.last()).vr_nrctremp := 6858385;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6010580;
  v_dados(v_dados.last()).vr_nrctremp := 8116304;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6020569;
  v_dados(v_dados.last()).vr_nrctremp := 7347472;
  v_dados(v_dados.last()).vr_vllanmto := 12.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6020569;
  v_dados(v_dados.last()).vr_nrctremp := 7934000;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6020585;
  v_dados(v_dados.last()).vr_nrctremp := 7353486;
  v_dados(v_dados.last()).vr_vllanmto := 12.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6029698;
  v_dados(v_dados.last()).vr_nrctremp := 6272562;
  v_dados(v_dados.last()).vr_vllanmto := 21.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6072720;
  v_dados(v_dados.last()).vr_nrctremp := 7584106;
  v_dados(v_dados.last()).vr_vllanmto := 19.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6084206;
  v_dados(v_dados.last()).vr_nrctremp := 7356718;
  v_dados(v_dados.last()).vr_vllanmto := 29.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6087370;
  v_dados(v_dados.last()).vr_nrctremp := 4428207;
  v_dados(v_dados.last()).vr_vllanmto := 15.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6087370;
  v_dados(v_dados.last()).vr_nrctremp := 7988418;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6137032;
  v_dados(v_dados.last()).vr_nrctremp := 7169579;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6137601;
  v_dados(v_dados.last()).vr_nrctremp := 7387011;
  v_dados(v_dados.last()).vr_vllanmto := 20.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6154301;
  v_dados(v_dados.last()).vr_nrctremp := 7939803;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6159745;
  v_dados(v_dados.last()).vr_nrctremp := 8147855;
  v_dados(v_dados.last()).vr_vllanmto := 20.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6175503;
  v_dados(v_dados.last()).vr_nrctremp := 8171747;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6193994;
  v_dados(v_dados.last()).vr_nrctremp := 5963471;
  v_dados(v_dados.last()).vr_vllanmto := 12.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6196543;
  v_dados(v_dados.last()).vr_nrctremp := 6816723;
  v_dados(v_dados.last()).vr_vllanmto := 20.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6237169;
  v_dados(v_dados.last()).vr_nrctremp := 7862598;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6304451;
  v_dados(v_dados.last()).vr_nrctremp := 8000830;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6309585;
  v_dados(v_dados.last()).vr_nrctremp := 6506789;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6341918;
  v_dados(v_dados.last()).vr_nrctremp := 8112105;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6341918;
  v_dados(v_dados.last()).vr_nrctremp := 8112130;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6368123;
  v_dados(v_dados.last()).vr_nrctremp := 7257531;
  v_dados(v_dados.last()).vr_vllanmto := 11.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6376312;
  v_dados(v_dados.last()).vr_nrctremp := 7524195;
  v_dados(v_dados.last()).vr_vllanmto := 30.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6385850;
  v_dados(v_dados.last()).vr_nrctremp := 8002334;
  v_dados(v_dados.last()).vr_vllanmto := 20.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6417418;
  v_dados(v_dados.last()).vr_nrctremp := 6907395;
  v_dados(v_dados.last()).vr_vllanmto := 27146.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6438857;
  v_dados(v_dados.last()).vr_nrctremp := 7951169;
  v_dados(v_dados.last()).vr_vllanmto := 16.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6516130;
  v_dados(v_dados.last()).vr_nrctremp := 7932571;
  v_dados(v_dados.last()).vr_vllanmto := 14.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6516645;
  v_dados(v_dados.last()).vr_nrctremp := 7873099;
  v_dados(v_dados.last()).vr_vllanmto := 15.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6518974;
  v_dados(v_dados.last()).vr_nrctremp := 5539306;
  v_dados(v_dados.last()).vr_vllanmto := 12.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6524583;
  v_dados(v_dados.last()).vr_nrctremp := 7955345;
  v_dados(v_dados.last()).vr_vllanmto := 17.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6538380;
  v_dados(v_dados.last()).vr_nrctremp := 7375350;
  v_dados(v_dados.last()).vr_vllanmto := 23.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6549152;
  v_dados(v_dados.last()).vr_nrctremp := 7820345;
  v_dados(v_dados.last()).vr_vllanmto := 20.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6578560;
  v_dados(v_dados.last()).vr_nrctremp := 7353975;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6614620;
  v_dados(v_dados.last()).vr_nrctremp := 8146715;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6675522;
  v_dados(v_dados.last()).vr_nrctremp := 7524850;
  v_dados(v_dados.last()).vr_vllanmto := 22.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6715273;
  v_dados(v_dados.last()).vr_nrctremp := 8076928;
  v_dados(v_dados.last()).vr_vllanmto := 34.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6720463;
  v_dados(v_dados.last()).vr_nrctremp := 6507300;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6721141;
  v_dados(v_dados.last()).vr_nrctremp := 5743491;
  v_dados(v_dados.last()).vr_vllanmto := 373.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6730574;
  v_dados(v_dados.last()).vr_nrctremp := 7619314;
  v_dados(v_dados.last()).vr_vllanmto := 21.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6757782;
  v_dados(v_dados.last()).vr_nrctremp := 7529126;
  v_dados(v_dados.last()).vr_vllanmto := 30.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6762948;
  v_dados(v_dados.last()).vr_nrctremp := 7891446;
  v_dados(v_dados.last()).vr_vllanmto := 22.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6766870;
  v_dados(v_dados.last()).vr_nrctremp := 7990127;
  v_dados(v_dados.last()).vr_vllanmto := 15.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6788580;
  v_dados(v_dados.last()).vr_nrctremp := 4802898;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6797792;
  v_dados(v_dados.last()).vr_nrctremp := 6695236;
  v_dados(v_dados.last()).vr_vllanmto := 13.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6813151;
  v_dados(v_dados.last()).vr_nrctremp := 6522055;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6845525;
  v_dados(v_dados.last()).vr_nrctremp := 8155385;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6866131;
  v_dados(v_dados.last()).vr_nrctremp := 5432971;
  v_dados(v_dados.last()).vr_vllanmto := 13.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6870732;
  v_dados(v_dados.last()).vr_nrctremp := 7915347;
  v_dados(v_dados.last()).vr_vllanmto := 27.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6904360;
  v_dados(v_dados.last()).vr_nrctremp := 4469248;
  v_dados(v_dados.last()).vr_vllanmto := 10.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6958095;
  v_dados(v_dados.last()).vr_nrctremp := 5661497;
  v_dados(v_dados.last()).vr_vllanmto := 21.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6973191;
  v_dados(v_dados.last()).vr_nrctremp := 7462502;
  v_dados(v_dados.last()).vr_vllanmto := 26.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6996027;
  v_dados(v_dados.last()).vr_nrctremp := 7780254;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6997635;
  v_dados(v_dados.last()).vr_nrctremp := 7498559;
  v_dados(v_dados.last()).vr_vllanmto := 14.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7011598;
  v_dados(v_dados.last()).vr_nrctremp := 7458013;
  v_dados(v_dados.last()).vr_vllanmto := 35.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7015160;
  v_dados(v_dados.last()).vr_nrctremp := 7912106;
  v_dados(v_dados.last()).vr_vllanmto := 48.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7078099;
  v_dados(v_dados.last()).vr_nrctremp := 7309388;
  v_dados(v_dados.last()).vr_vllanmto := 17.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7100515;
  v_dados(v_dados.last()).vr_nrctremp := 7539142;
  v_dados(v_dados.last()).vr_vllanmto := 16.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7131690;
  v_dados(v_dados.last()).vr_nrctremp := 7053526;
  v_dados(v_dados.last()).vr_vllanmto := 11.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7140363;
  v_dados(v_dados.last()).vr_nrctremp := 7791721;
  v_dados(v_dados.last()).vr_vllanmto := 15.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7184972;
  v_dados(v_dados.last()).vr_nrctremp := 6588897;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7206895;
  v_dados(v_dados.last()).vr_nrctremp := 5170845;
  v_dados(v_dados.last()).vr_vllanmto := 55.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7223897;
  v_dados(v_dados.last()).vr_nrctremp := 6245675;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7284675;
  v_dados(v_dados.last()).vr_nrctremp := 8079942;
  v_dados(v_dados.last()).vr_vllanmto := 29.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7313144;
  v_dados(v_dados.last()).vr_nrctremp := 6250804;
  v_dados(v_dados.last()).vr_vllanmto := 36.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7317875;
  v_dados(v_dados.last()).vr_nrctremp := 7452294;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7372183;
  v_dados(v_dados.last()).vr_nrctremp := 7368505;
  v_dados(v_dados.last()).vr_vllanmto := 125.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7374763;
  v_dados(v_dados.last()).vr_nrctremp := 4178604;
  v_dados(v_dados.last()).vr_vllanmto := 280.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7378815;
  v_dados(v_dados.last()).vr_nrctremp := 7881054;
  v_dados(v_dados.last()).vr_vllanmto := 52.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7391447;
  v_dados(v_dados.last()).vr_nrctremp := 7368857;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7449348;
  v_dados(v_dados.last()).vr_nrctremp := 2655988;
  v_dados(v_dados.last()).vr_vllanmto := 1197.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7471955;
  v_dados(v_dados.last()).vr_nrctremp := 7658114;
  v_dados(v_dados.last()).vr_vllanmto := 15.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7502613;
  v_dados(v_dados.last()).vr_nrctremp := 6625085;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7505272;
  v_dados(v_dados.last()).vr_nrctremp := 8177033;
  v_dados(v_dados.last()).vr_vllanmto := 30.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7556420;
  v_dados(v_dados.last()).vr_nrctremp := 7095762;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7565356;
  v_dados(v_dados.last()).vr_nrctremp := 6212102;
  v_dados(v_dados.last()).vr_vllanmto := 16.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7580592;
  v_dados(v_dados.last()).vr_nrctremp := 7433877;
  v_dados(v_dados.last()).vr_vllanmto := 15.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7583001;
  v_dados(v_dados.last()).vr_nrctremp := 7518679;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7652771;
  v_dados(v_dados.last()).vr_nrctremp := 6573772;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7695306;
  v_dados(v_dados.last()).vr_nrctremp := 7709609;
  v_dados(v_dados.last()).vr_vllanmto := 55.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7834110;
  v_dados(v_dados.last()).vr_nrctremp := 6700712;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7914857;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 2193.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7923368;
  v_dados(v_dados.last()).vr_nrctremp := 6695190;
  v_dados(v_dados.last()).vr_vllanmto := 15.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7928106;
  v_dados(v_dados.last()).vr_nrctremp := 7918071;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7955260;
  v_dados(v_dados.last()).vr_nrctremp := 6712054;
  v_dados(v_dados.last()).vr_vllanmto := 13.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7978987;
  v_dados(v_dados.last()).vr_nrctremp := 7644729;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8025380;
  v_dados(v_dados.last()).vr_nrctremp := 7599513;
  v_dados(v_dados.last()).vr_vllanmto := 15.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8040168;
  v_dados(v_dados.last()).vr_nrctremp := 7962578;
  v_dados(v_dados.last()).vr_vllanmto := 18.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8051526;
  v_dados(v_dados.last()).vr_nrctremp := 7128556;
  v_dados(v_dados.last()).vr_vllanmto := 13.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8058466;
  v_dados(v_dados.last()).vr_nrctremp := 8016547;
  v_dados(v_dados.last()).vr_vllanmto := 18.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8058717;
  v_dados(v_dados.last()).vr_nrctremp := 3990688;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8060266;
  v_dados(v_dados.last()).vr_nrctremp := 4800878;
  v_dados(v_dados.last()).vr_vllanmto := 33.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8064970;
  v_dados(v_dados.last()).vr_nrctremp := 8159348;
  v_dados(v_dados.last()).vr_vllanmto := 28273.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8065012;
  v_dados(v_dados.last()).vr_nrctremp := 8027942;
  v_dados(v_dados.last()).vr_vllanmto := 18.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8103160;
  v_dados(v_dados.last()).vr_nrctremp := 7948180;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8126720;
  v_dados(v_dados.last()).vr_nrctremp := 7554412;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8141606;
  v_dados(v_dados.last()).vr_nrctremp := 6636405;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8153159;
  v_dados(v_dados.last()).vr_nrctremp := 6104579;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8164509;
  v_dados(v_dados.last()).vr_nrctremp := 7327691;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8171645;
  v_dados(v_dados.last()).vr_nrctremp := 4644755;
  v_dados(v_dados.last()).vr_vllanmto := 3272.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8198934;
  v_dados(v_dados.last()).vr_nrctremp := 7571035;
  v_dados(v_dados.last()).vr_vllanmto := 13.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8273316;
  v_dados(v_dados.last()).vr_nrctremp := 7994967;
  v_dados(v_dados.last()).vr_vllanmto := 13.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8273332;
  v_dados(v_dados.last()).vr_nrctremp := 4648247;
  v_dados(v_dados.last()).vr_vllanmto := 370.01;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8304440;
  v_dados(v_dados.last()).vr_nrctremp := 4879513;
  v_dados(v_dados.last()).vr_vllanmto := 5494.22;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8327068;
  v_dados(v_dados.last()).vr_nrctremp := 8072053;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8337357;
  v_dados(v_dados.last()).vr_nrctremp := 7469939;
  v_dados(v_dados.last()).vr_vllanmto := 18.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8354316;
  v_dados(v_dados.last()).vr_nrctremp := 8151585;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8357854;
  v_dados(v_dados.last()).vr_nrctremp := 8011078;
  v_dados(v_dados.last()).vr_vllanmto := 16.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8374619;
  v_dados(v_dados.last()).vr_nrctremp := 8005723;
  v_dados(v_dados.last()).vr_vllanmto := 13.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8451133;
  v_dados(v_dados.last()).vr_nrctremp := 7727910;
  v_dados(v_dados.last()).vr_vllanmto := 17.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8465886;
  v_dados(v_dados.last()).vr_nrctremp := 8140798;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8478589;
  v_dados(v_dados.last()).vr_nrctremp := 7837357;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8489939;
  v_dados(v_dados.last()).vr_nrctremp := 7857963;
  v_dados(v_dados.last()).vr_vllanmto := 12.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8535337;
  v_dados(v_dados.last()).vr_nrctremp := 7235321;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8542244;
  v_dados(v_dados.last()).vr_nrctremp := 7462549;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8544891;
  v_dados(v_dados.last()).vr_nrctremp := 8070754;
  v_dados(v_dados.last()).vr_vllanmto := 21.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8568847;
  v_dados(v_dados.last()).vr_nrctremp := 8077152;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8590168;
  v_dados(v_dados.last()).vr_nrctremp := 5611665;
  v_dados(v_dados.last()).vr_vllanmto := 12.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 4101609;
  v_dados(v_dados.last()).vr_vllanmto := 2173.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 6131009;
  v_dados(v_dados.last()).vr_vllanmto := 4481.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8638047;
  v_dados(v_dados.last()).vr_nrctremp := 7068406;
  v_dados(v_dados.last()).vr_vllanmto := 19.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8655588;
  v_dados(v_dados.last()).vr_nrctremp := 7832495;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8663700;
  v_dados(v_dados.last()).vr_nrctremp := 4604397;
  v_dados(v_dados.last()).vr_vllanmto := 3783.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8704201;
  v_dados(v_dados.last()).vr_nrctremp := 7631224;
  v_dados(v_dados.last()).vr_vllanmto := 25.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8746028;
  v_dados(v_dados.last()).vr_nrctremp := 7207889;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8759839;
  v_dados(v_dados.last()).vr_nrctremp := 7722138;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8765065;
  v_dados(v_dados.last()).vr_nrctremp := 7168193;
  v_dados(v_dados.last()).vr_vllanmto := 12.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8790094;
  v_dados(v_dados.last()).vr_nrctremp := 6038794;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8837813;
  v_dados(v_dados.last()).vr_nrctremp := 7377030;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8857580;
  v_dados(v_dados.last()).vr_nrctremp := 8059311;
  v_dados(v_dados.last()).vr_vllanmto := 21.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8857946;
  v_dados(v_dados.last()).vr_nrctremp := 7840966;
  v_dados(v_dados.last()).vr_vllanmto := 56.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8904375;
  v_dados(v_dados.last()).vr_nrctremp := 7392255;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8907315;
  v_dados(v_dados.last()).vr_nrctremp := 3627786;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8927596;
  v_dados(v_dados.last()).vr_nrctremp := 7980777;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8958203;
  v_dados(v_dados.last()).vr_nrctremp := 6205911;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9025014;
  v_dados(v_dados.last()).vr_nrctremp := 6170404;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9038760;
  v_dados(v_dados.last()).vr_nrctremp := 2985651;
  v_dados(v_dados.last()).vr_vllanmto := 1822.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9049185;
  v_dados(v_dados.last()).vr_nrctremp := 6712895;
  v_dados(v_dados.last()).vr_vllanmto := 22.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9055185;
  v_dados(v_dados.last()).vr_nrctremp := 7514846;
  v_dados(v_dados.last()).vr_vllanmto := 46.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9061177;
  v_dados(v_dados.last()).vr_nrctremp := 7574052;
  v_dados(v_dados.last()).vr_vllanmto := 13.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9073183;
  v_dados(v_dados.last()).vr_nrctremp := 8107984;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9084720;
  v_dados(v_dados.last()).vr_nrctremp := 5566176;
  v_dados(v_dados.last()).vr_vllanmto := 236.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9088741;
  v_dados(v_dados.last()).vr_nrctremp := 6016044;
  v_dados(v_dados.last()).vr_vllanmto := 1033.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9119825;
  v_dados(v_dados.last()).vr_nrctremp := 7785397;
  v_dados(v_dados.last()).vr_vllanmto := 22.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9121854;
  v_dados(v_dados.last()).vr_nrctremp := 8043950;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9134921;
  v_dados(v_dados.last()).vr_nrctremp := 7488239;
  v_dados(v_dados.last()).vr_vllanmto := 69.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9153055;
  v_dados(v_dados.last()).vr_nrctremp := 8118845;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9182330;
  v_dados(v_dados.last()).vr_nrctremp := 7564142;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9190635;
  v_dados(v_dados.last()).vr_nrctremp := 6779377;
  v_dados(v_dados.last()).vr_vllanmto := 11.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9191143;
  v_dados(v_dados.last()).vr_nrctremp := 5286369;
  v_dados(v_dados.last()).vr_vllanmto := 32.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9194037;
  v_dados(v_dados.last()).vr_nrctremp := 7281254;
  v_dados(v_dados.last()).vr_vllanmto := 30.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9194371;
  v_dados(v_dados.last()).vr_nrctremp := 3700170;
  v_dados(v_dados.last()).vr_vllanmto := 120.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9233318;
  v_dados(v_dados.last()).vr_nrctremp := 5621986;
  v_dados(v_dados.last()).vr_vllanmto := 19.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9236490;
  v_dados(v_dados.last()).vr_nrctremp := 6905588;
  v_dados(v_dados.last()).vr_vllanmto := 14.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9279032;
  v_dados(v_dados.last()).vr_nrctremp := 3481207;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9314784;
  v_dados(v_dados.last()).vr_nrctremp := 6190218;
  v_dados(v_dados.last()).vr_vllanmto := 19.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9314784;
  v_dados(v_dados.last()).vr_nrctremp := 6916842;
  v_dados(v_dados.last()).vr_vllanmto := 12.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9314784;
  v_dados(v_dados.last()).vr_nrctremp := 7993010;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9323791;
  v_dados(v_dados.last()).vr_nrctremp := 6001285;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9343431;
  v_dados(v_dados.last()).vr_nrctremp := 7633185;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9348808;
  v_dados(v_dados.last()).vr_nrctremp := 5959615;
  v_dados(v_dados.last()).vr_vllanmto := 224.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9352562;
  v_dados(v_dados.last()).vr_nrctremp := 5027319;
  v_dados(v_dados.last()).vr_vllanmto := 169.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9391207;
  v_dados(v_dados.last()).vr_nrctremp := 6916649;
  v_dados(v_dados.last()).vr_vllanmto := 14.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9404635;
  v_dados(v_dados.last()).vr_nrctremp := 7703048;
  v_dados(v_dados.last()).vr_vllanmto := 10.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9420550;
  v_dados(v_dados.last()).vr_nrctremp := 6926912;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9433171;
  v_dados(v_dados.last()).vr_nrctremp := 4559377;
  v_dados(v_dados.last()).vr_vllanmto := 232.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9439560;
  v_dados(v_dados.last()).vr_nrctremp := 7238783;
  v_dados(v_dados.last()).vr_vllanmto := 26.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9444718;
  v_dados(v_dados.last()).vr_nrctremp := 7264443;
  v_dados(v_dados.last()).vr_vllanmto := 116.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9444718;
  v_dados(v_dados.last()).vr_nrctremp := 7461434;
  v_dados(v_dados.last()).vr_vllanmto := 60.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9444718;
  v_dados(v_dados.last()).vr_nrctremp := 8051077;
  v_dados(v_dados.last()).vr_vllanmto := 18.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9450572;
  v_dados(v_dados.last()).vr_nrctremp := 6930833;
  v_dados(v_dados.last()).vr_vllanmto := 1558.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9484540;
  v_dados(v_dados.last()).vr_nrctremp := 8073086;
  v_dados(v_dados.last()).vr_vllanmto := 16.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9501096;
  v_dados(v_dados.last()).vr_nrctremp := 4531209;
  v_dados(v_dados.last()).vr_vllanmto := 12.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9501096;
  v_dados(v_dados.last()).vr_nrctremp := 7620929;
  v_dados(v_dados.last()).vr_vllanmto := 28.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9503250;
  v_dados(v_dados.last()).vr_nrctremp := 6238730;
  v_dados(v_dados.last()).vr_vllanmto := 11.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9510141;
  v_dados(v_dados.last()).vr_nrctremp := 8008048;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9519947;
  v_dados(v_dados.last()).vr_nrctremp := 7369622;
  v_dados(v_dados.last()).vr_vllanmto := 228.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9519947;
  v_dados(v_dados.last()).vr_nrctremp := 7950495;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9523332;
  v_dados(v_dados.last()).vr_nrctremp := 7259026;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9526889;
  v_dados(v_dados.last()).vr_nrctremp := 7417213;
  v_dados(v_dados.last()).vr_vllanmto := 551.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9543490;
  v_dados(v_dados.last()).vr_nrctremp := 4391966;
  v_dados(v_dados.last()).vr_vllanmto := 120.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9557504;
  v_dados(v_dados.last()).vr_nrctremp := 7570898;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9561200;
  v_dados(v_dados.last()).vr_nrctremp := 6084116;
  v_dados(v_dados.last()).vr_vllanmto := 241.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9564330;
  v_dados(v_dados.last()).vr_nrctremp := 6731340;
  v_dados(v_dados.last()).vr_vllanmto := 11.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9575448;
  v_dados(v_dados.last()).vr_nrctremp := 4535138;
  v_dados(v_dados.last()).vr_vllanmto := 1009.1;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9618430;
  v_dados(v_dados.last()).vr_nrctremp := 6738554;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9633316;
  v_dados(v_dados.last()).vr_nrctremp := 4343361;
  v_dados(v_dados.last()).vr_vllanmto := 3054.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9660143;
  v_dados(v_dados.last()).vr_nrctremp := 4680083;
  v_dados(v_dados.last()).vr_vllanmto := 7110.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9664076;
  v_dados(v_dados.last()).vr_nrctremp := 6731023;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9687645;
  v_dados(v_dados.last()).vr_nrctremp := 7009169;
  v_dados(v_dados.last()).vr_vllanmto := 20.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9700676;
  v_dados(v_dados.last()).vr_nrctremp := 7483770;
  v_dados(v_dados.last()).vr_vllanmto := 10.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9708090;
  v_dados(v_dados.last()).vr_nrctremp := 5199517;
  v_dados(v_dados.last()).vr_vllanmto := 202.6;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 4801045;
  v_dados(v_dados.last()).vr_vllanmto := 1275.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9712666;
  v_dados(v_dados.last()).vr_nrctremp := 6631120;
  v_dados(v_dados.last()).vr_vllanmto := 324.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9739289;
  v_dados(v_dados.last()).vr_nrctremp := 5378221;
  v_dados(v_dados.last()).vr_vllanmto := 1108.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9744711;
  v_dados(v_dados.last()).vr_nrctremp := 4046030;
  v_dados(v_dados.last()).vr_vllanmto := 8667.05;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9818081;
  v_dados(v_dados.last()).vr_nrctremp := 7922740;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9818251;
  v_dados(v_dados.last()).vr_nrctremp := 8167834;
  v_dados(v_dados.last()).vr_vllanmto := 12.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9820159;
  v_dados(v_dados.last()).vr_nrctremp := 7387037;
  v_dados(v_dados.last()).vr_vllanmto := 52.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9875638;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 2081.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9898646;
  v_dados(v_dados.last()).vr_nrctremp := 6478546;
  v_dados(v_dados.last()).vr_vllanmto := 29.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9905260;
  v_dados(v_dados.last()).vr_nrctremp := 7722113;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9923055;
  v_dados(v_dados.last()).vr_nrctremp := 7422521;
  v_dados(v_dados.last()).vr_vllanmto := 18.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9942831;
  v_dados(v_dados.last()).vr_nrctremp := 4445492;
  v_dados(v_dados.last()).vr_vllanmto := 3418.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9946985;
  v_dados(v_dados.last()).vr_nrctremp := 7306990;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9957707;
  v_dados(v_dados.last()).vr_nrctremp := 7814459;
  v_dados(v_dados.last()).vr_vllanmto := 23.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9958070;
  v_dados(v_dados.last()).vr_nrctremp := 5848326;
  v_dados(v_dados.last()).vr_vllanmto := 10486.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9995552;
  v_dados(v_dados.last()).vr_nrctremp := 7685027;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10024913;
  v_dados(v_dados.last()).vr_nrctremp := 7279592;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10034889;
  v_dados(v_dados.last()).vr_nrctremp := 5717931;
  v_dados(v_dados.last()).vr_vllanmto := 15.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10040447;
  v_dados(v_dados.last()).vr_nrctremp := 7499386;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10065067;
  v_dados(v_dados.last()).vr_nrctremp := 5120902;
  v_dados(v_dados.last()).vr_vllanmto := 128.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10066497;
  v_dados(v_dados.last()).vr_nrctremp := 6300813;
  v_dados(v_dados.last()).vr_vllanmto := 13.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10086536;
  v_dados(v_dados.last()).vr_nrctremp := 7626161;
  v_dados(v_dados.last()).vr_vllanmto := 15982.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10106383;
  v_dados(v_dados.last()).vr_nrctremp := 7068455;
  v_dados(v_dados.last()).vr_vllanmto := 18.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10115218;
  v_dados(v_dados.last()).vr_nrctremp := 6053088;
  v_dados(v_dados.last()).vr_vllanmto := 2023.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10179666;
  v_dados(v_dados.last()).vr_nrctremp := 7966889;
  v_dados(v_dados.last()).vr_vllanmto := 17.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10210342;
  v_dados(v_dados.last()).vr_nrctremp := 5803332;
  v_dados(v_dados.last()).vr_vllanmto := 11.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10236970;
  v_dados(v_dados.last()).vr_nrctremp := 6750565;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10245537;
  v_dados(v_dados.last()).vr_nrctremp := 4193713;
  v_dados(v_dados.last()).vr_vllanmto := 314.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10249168;
  v_dados(v_dados.last()).vr_nrctremp := 5311587;
  v_dados(v_dados.last()).vr_vllanmto := 11.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10251138;
  v_dados(v_dados.last()).vr_nrctremp := 5345929;
  v_dados(v_dados.last()).vr_vllanmto := 1801.46;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10253181;
  v_dados(v_dados.last()).vr_nrctremp := 8008988;
  v_dados(v_dados.last()).vr_vllanmto := 16.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10257543;
  v_dados(v_dados.last()).vr_nrctremp := 8103018;
  v_dados(v_dados.last()).vr_vllanmto := 12.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10273557;
  v_dados(v_dados.last()).vr_nrctremp := 4889176;
  v_dados(v_dados.last()).vr_vllanmto := 55.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10293345;
  v_dados(v_dados.last()).vr_nrctremp := 4753411;
  v_dados(v_dados.last()).vr_vllanmto := 1007;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10294295;
  v_dados(v_dados.last()).vr_nrctremp := 6687664;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10294295;
  v_dados(v_dados.last()).vr_nrctremp := 7982185;
  v_dados(v_dados.last()).vr_vllanmto := 19.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10306749;
  v_dados(v_dados.last()).vr_nrctremp := 6066950;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10307133;
  v_dados(v_dados.last()).vr_nrctremp := 7376916;
  v_dados(v_dados.last()).vr_vllanmto := 23.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10314580;
  v_dados(v_dados.last()).vr_nrctremp := 7761086;
  v_dados(v_dados.last()).vr_vllanmto := 31.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 4677944;
  v_dados(v_dados.last()).vr_vllanmto := 8872.38;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 5587986;
  v_dados(v_dados.last()).vr_vllanmto := 2887.82;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10337938;
  v_dados(v_dados.last()).vr_nrctremp := 6988050;
  v_dados(v_dados.last()).vr_vllanmto := 21.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10360581;
  v_dados(v_dados.last()).vr_nrctremp := 4521812;
  v_dados(v_dados.last()).vr_vllanmto := 13.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10368817;
  v_dados(v_dados.last()).vr_nrctremp := 8140909;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10373179;
  v_dados(v_dados.last()).vr_nrctremp := 6464042;
  v_dados(v_dados.last()).vr_vllanmto := 249.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10400133;
  v_dados(v_dados.last()).vr_nrctremp := 8067075;
  v_dados(v_dados.last()).vr_vllanmto := 31.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10405976;
  v_dados(v_dados.last()).vr_nrctremp := 7613818;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10424377;
  v_dados(v_dados.last()).vr_nrctremp := 5801922;
  v_dados(v_dados.last()).vr_vllanmto := 127.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10432515;
  v_dados(v_dados.last()).vr_nrctremp := 4783814;
  v_dados(v_dados.last()).vr_vllanmto := 192.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10440240;
  v_dados(v_dados.last()).vr_nrctremp := 6037634;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10465537;
  v_dados(v_dados.last()).vr_nrctremp := 4476841;
  v_dados(v_dados.last()).vr_vllanmto := 737.91;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10468307;
  v_dados(v_dados.last()).vr_nrctremp := 7562825;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10487662;
  v_dados(v_dados.last()).vr_nrctremp := 3932268;
  v_dados(v_dados.last()).vr_vllanmto := 67.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10492399;
  v_dados(v_dados.last()).vr_nrctremp := 8051773;
  v_dados(v_dados.last()).vr_vllanmto := 16.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10509631;
  v_dados(v_dados.last()).vr_nrctremp := 6787302;
  v_dados(v_dados.last()).vr_vllanmto := 853.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10528300;
  v_dados(v_dados.last()).vr_nrctremp := 7550298;
  v_dados(v_dados.last()).vr_vllanmto := 407.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10534083;
  v_dados(v_dados.last()).vr_nrctremp := 7451816;
  v_dados(v_dados.last()).vr_vllanmto := 20.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10544682;
  v_dados(v_dados.last()).vr_nrctremp := 6181433;
  v_dados(v_dados.last()).vr_vllanmto := 17.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10571760;
  v_dados(v_dados.last()).vr_nrctremp := 4167462;
  v_dados(v_dados.last()).vr_vllanmto := 22.7;
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
  v_dados(v_dados.last()).vr_vllanmto := 1809.64;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10640380;
  v_dados(v_dados.last()).vr_nrctremp := 6489392;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10646990;
  v_dados(v_dados.last()).vr_nrctremp := 8023329;
  v_dados(v_dados.last()).vr_vllanmto := 19.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10657673;
  v_dados(v_dados.last()).vr_nrctremp := 3167828;
  v_dados(v_dados.last()).vr_vllanmto := 78.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10661158;
  v_dados(v_dados.last()).vr_nrctremp := 7977707;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10663452;
  v_dados(v_dados.last()).vr_nrctremp := 5158755;
  v_dados(v_dados.last()).vr_vllanmto := 28.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10666478;
  v_dados(v_dados.last()).vr_nrctremp := 6804037;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10666737;
  v_dados(v_dados.last()).vr_nrctremp := 6317870;
  v_dados(v_dados.last()).vr_vllanmto := 13.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10670807;
  v_dados(v_dados.last()).vr_nrctremp := 4692518;
  v_dados(v_dados.last()).vr_vllanmto := 1376.99;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10675515;
  v_dados(v_dados.last()).vr_nrctremp := 6524795;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10695419;
  v_dados(v_dados.last()).vr_nrctremp := 8030440;
  v_dados(v_dados.last()).vr_vllanmto := 19.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10707794;
  v_dados(v_dados.last()).vr_nrctremp := 6443733;
  v_dados(v_dados.last()).vr_vllanmto := 23.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10727116;
  v_dados(v_dados.last()).vr_nrctremp := 7165449;
  v_dados(v_dados.last()).vr_vllanmto := 577.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10728821;
  v_dados(v_dados.last()).vr_nrctremp := 6695578;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10731881;
  v_dados(v_dados.last()).vr_nrctremp := 7795351;
  v_dados(v_dados.last()).vr_vllanmto := 38.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10735224;
  v_dados(v_dados.last()).vr_nrctremp := 3701725;
  v_dados(v_dados.last()).vr_vllanmto := 130.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10748873;
  v_dados(v_dados.last()).vr_nrctremp := 4640120;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10750029;
  v_dados(v_dados.last()).vr_nrctremp := 6135678;
  v_dados(v_dados.last()).vr_vllanmto := 68.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10785442;
  v_dados(v_dados.last()).vr_nrctremp := 7398774;
  v_dados(v_dados.last()).vr_vllanmto := 16.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10815562;
  v_dados(v_dados.last()).vr_nrctremp := 7808537;
  v_dados(v_dados.last()).vr_vllanmto := 11.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10816186;
  v_dados(v_dados.last()).vr_nrctremp := 5216299;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10845933;
  v_dados(v_dados.last()).vr_nrctremp := 5501714;
  v_dados(v_dados.last()).vr_vllanmto := 2525.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10851925;
  v_dados(v_dados.last()).vr_nrctremp := 5141026;
  v_dados(v_dados.last()).vr_vllanmto := 22.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10878211;
  v_dados(v_dados.last()).vr_nrctremp := 7225058;
  v_dados(v_dados.last()).vr_vllanmto := 1395.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10883398;
  v_dados(v_dados.last()).vr_nrctremp := 7464609;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10899421;
  v_dados(v_dados.last()).vr_nrctremp := 7216349;
  v_dados(v_dados.last()).vr_vllanmto := 15.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10899448;
  v_dados(v_dados.last()).vr_nrctremp := 8085738;
  v_dados(v_dados.last()).vr_vllanmto := 15.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10919678;
  v_dados(v_dados.last()).vr_nrctremp := 5972513;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10961062;
  v_dados(v_dados.last()).vr_nrctremp := 7688221;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10967583;
  v_dados(v_dados.last()).vr_nrctremp := 7987602;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10968393;
  v_dados(v_dados.last()).vr_nrctremp := 7312034;
  v_dados(v_dados.last()).vr_vllanmto := 10.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11016990;
  v_dados(v_dados.last()).vr_nrctremp := 7851299;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11044039;
  v_dados(v_dados.last()).vr_nrctremp := 4344288;
  v_dados(v_dados.last()).vr_vllanmto := 105.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11075252;
  v_dados(v_dados.last()).vr_nrctremp := 6735712;
  v_dados(v_dados.last()).vr_vllanmto := 207.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11100664;
  v_dados(v_dados.last()).vr_nrctremp := 6132418;
  v_dados(v_dados.last()).vr_vllanmto := 24.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11100664;
  v_dados(v_dados.last()).vr_nrctremp := 7762118;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11102950;
  v_dados(v_dados.last()).vr_nrctremp := 6608081;
  v_dados(v_dados.last()).vr_vllanmto := 13.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11115289;
  v_dados(v_dados.last()).vr_nrctremp := 7041334;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11150793;
  v_dados(v_dados.last()).vr_nrctremp := 7991498;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11155213;
  v_dados(v_dados.last()).vr_nrctremp := 7841499;
  v_dados(v_dados.last()).vr_vllanmto := 14.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11189363;
  v_dados(v_dados.last()).vr_nrctremp := 7360616;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11189797;
  v_dados(v_dados.last()).vr_nrctremp := 7195356;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11191945;
  v_dados(v_dados.last()).vr_nrctremp := 8058873;
  v_dados(v_dados.last()).vr_vllanmto := 24.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11195541;
  v_dados(v_dados.last()).vr_nrctremp := 4604839;
  v_dados(v_dados.last()).vr_vllanmto := 410.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11206624;
  v_dados(v_dados.last()).vr_nrctremp := 7580570;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11208201;
  v_dados(v_dados.last()).vr_nrctremp := 7293592;
  v_dados(v_dados.last()).vr_vllanmto := 38.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11223332;
  v_dados(v_dados.last()).vr_nrctremp := 4901463;
  v_dados(v_dados.last()).vr_vllanmto := 20062.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11228083;
  v_dados(v_dados.last()).vr_nrctremp := 4581982;
  v_dados(v_dados.last()).vr_vllanmto := 64.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11251891;
  v_dados(v_dados.last()).vr_nrctremp := 7726372;
  v_dados(v_dados.last()).vr_vllanmto := 24.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11254696;
  v_dados(v_dados.last()).vr_nrctremp := 7182185;
  v_dados(v_dados.last()).vr_vllanmto := 366.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11254696;
  v_dados(v_dados.last()).vr_nrctremp := 7234406;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11255447;
  v_dados(v_dados.last()).vr_nrctremp := 7978224;
  v_dados(v_dados.last()).vr_vllanmto := 2828.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11260580;
  v_dados(v_dados.last()).vr_nrctremp := 8061227;
  v_dados(v_dados.last()).vr_vllanmto := 28.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11289848;
  v_dados(v_dados.last()).vr_nrctremp := 4556448;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11307510;
  v_dados(v_dados.last()).vr_nrctremp := 5897742;
  v_dados(v_dados.last()).vr_vllanmto := 2098.3;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11310480;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 5230.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11340851;
  v_dados(v_dados.last()).vr_nrctremp := 7971217;
  v_dados(v_dados.last()).vr_vllanmto := 27.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11358700;
  v_dados(v_dados.last()).vr_nrctremp := 6080438;
  v_dados(v_dados.last()).vr_vllanmto := 33.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11367296;
  v_dados(v_dados.last()).vr_nrctremp := 8029204;
  v_dados(v_dados.last()).vr_vllanmto := 14.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 1087.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11370408;
  v_dados(v_dados.last()).vr_nrctremp := 7919589;
  v_dados(v_dados.last()).vr_vllanmto := 16.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11379014;
  v_dados(v_dados.last()).vr_nrctremp := 5061942;
  v_dados(v_dados.last()).vr_vllanmto := 27.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11417625;
  v_dados(v_dados.last()).vr_nrctremp := 7217875;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11433779;
  v_dados(v_dados.last()).vr_nrctremp := 5257224;
  v_dados(v_dados.last()).vr_vllanmto := 98.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11443120;
  v_dados(v_dados.last()).vr_nrctremp := 7649400;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11560142;
  v_dados(v_dados.last()).vr_nrctremp := 8057163;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11568828;
  v_dados(v_dados.last()).vr_nrctremp := 7672718;
  v_dados(v_dados.last()).vr_vllanmto := 38380.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11576537;
  v_dados(v_dados.last()).vr_nrctremp := 4674681;
  v_dados(v_dados.last()).vr_vllanmto := 2440.24;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11593059;
  v_dados(v_dados.last()).vr_nrctremp := 8138705;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11600128;
  v_dados(v_dados.last()).vr_nrctremp := 7935143;
  v_dados(v_dados.last()).vr_vllanmto := 21.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11600187;
  v_dados(v_dados.last()).vr_nrctremp := 6956820;
  v_dados(v_dados.last()).vr_vllanmto := 12.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11615770;
  v_dados(v_dados.last()).vr_nrctremp := 4589257;
  v_dados(v_dados.last()).vr_vllanmto := 2944.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11629410;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 2611.78;
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
  v_dados(v_dados.last()).vr_vllanmto := 330.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11691700;
  v_dados(v_dados.last()).vr_nrctremp := 3235912;
  v_dados(v_dados.last()).vr_vllanmto := 12.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11703458;
  v_dados(v_dados.last()).vr_nrctremp := 6186099;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11706988;
  v_dados(v_dados.last()).vr_nrctremp := 6556949;
  v_dados(v_dados.last()).vr_vllanmto := 23.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11712643;
  v_dados(v_dados.last()).vr_nrctremp := 3098270;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11717947;
  v_dados(v_dados.last()).vr_nrctremp := 3005429;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11747820;
  v_dados(v_dados.last()).vr_nrctremp := 3604371;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11759631;
  v_dados(v_dados.last()).vr_nrctremp := 3170921;
  v_dados(v_dados.last()).vr_vllanmto := 12.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11761350;
  v_dados(v_dados.last()).vr_nrctremp := 4490149;
  v_dados(v_dados.last()).vr_vllanmto := 17.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11763744;
  v_dados(v_dados.last()).vr_nrctremp := 4513090;
  v_dados(v_dados.last()).vr_vllanmto := 24.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11766522;
  v_dados(v_dados.last()).vr_nrctremp := 5500927;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11768614;
  v_dados(v_dados.last()).vr_nrctremp := 3305760;
  v_dados(v_dados.last()).vr_vllanmto := 14.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11773367;
  v_dados(v_dados.last()).vr_nrctremp := 3170781;
  v_dados(v_dados.last()).vr_vllanmto := 19.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11773715;
  v_dados(v_dados.last()).vr_nrctremp := 7631219;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11773766;
  v_dados(v_dados.last()).vr_nrctremp := 4350017;
  v_dados(v_dados.last()).vr_vllanmto := 18.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11778148;
  v_dados(v_dados.last()).vr_nrctremp := 7765537;
  v_dados(v_dados.last()).vr_vllanmto := 21.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11778598;
  v_dados(v_dados.last()).vr_nrctremp := 5233294;
  v_dados(v_dados.last()).vr_vllanmto := 125.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11785837;
  v_dados(v_dados.last()).vr_nrctremp := 4974493;
  v_dados(v_dados.last()).vr_vllanmto := 202;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11798769;
  v_dados(v_dados.last()).vr_nrctremp := 6323677;
  v_dados(v_dados.last()).vr_vllanmto := 10.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11845295;
  v_dados(v_dados.last()).vr_nrctremp := 7972504;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11866730;
  v_dados(v_dados.last()).vr_nrctremp := 7878561;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11873647;
  v_dados(v_dados.last()).vr_nrctremp := 6990572;
  v_dados(v_dados.last()).vr_vllanmto := 12.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11887745;
  v_dados(v_dados.last()).vr_nrctremp := 3941325;
  v_dados(v_dados.last()).vr_vllanmto := 14.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11889195;
  v_dados(v_dados.last()).vr_nrctremp := 3521680;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11910992;
  v_dados(v_dados.last()).vr_nrctremp := 8061030;
  v_dados(v_dados.last()).vr_vllanmto := 18.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11928310;
  v_dados(v_dados.last()).vr_nrctremp := 6913717;
  v_dados(v_dados.last()).vr_vllanmto := 16.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11953039;
  v_dados(v_dados.last()).vr_nrctremp := 7502019;
  v_dados(v_dados.last()).vr_vllanmto := 58.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11956186;
  v_dados(v_dados.last()).vr_nrctremp := 7047172;
  v_dados(v_dados.last()).vr_vllanmto := 1596.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11980435;
  v_dados(v_dados.last()).vr_nrctremp := 3404776;
  v_dados(v_dados.last()).vr_vllanmto := 10.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12004073;
  v_dados(v_dados.last()).vr_nrctremp := 7647300;
  v_dados(v_dados.last()).vr_vllanmto := 13.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12009423;
  v_dados(v_dados.last()).vr_nrctremp := 7471425;
  v_dados(v_dados.last()).vr_vllanmto := 16.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12019178;
  v_dados(v_dados.last()).vr_nrctremp := 3430704;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12020192;
  v_dados(v_dados.last()).vr_nrctremp := 4452101;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 3421230;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 3421257;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12038083;
  v_dados(v_dados.last()).vr_nrctremp := 7240176;
  v_dados(v_dados.last()).vr_vllanmto := 17863.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12055042;
  v_dados(v_dados.last()).vr_nrctremp := 3238779;
  v_dados(v_dados.last()).vr_vllanmto := 15.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12071110;
  v_dados(v_dados.last()).vr_nrctremp := 6538142;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12074233;
  v_dados(v_dados.last()).vr_nrctremp := 3255681;
  v_dados(v_dados.last()).vr_vllanmto := 10.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12082139;
  v_dados(v_dados.last()).vr_nrctremp := 7624609;
  v_dados(v_dados.last()).vr_vllanmto := 26.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12096741;
  v_dados(v_dados.last()).vr_nrctremp := 7281104;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12103721;
  v_dados(v_dados.last()).vr_nrctremp := 6277579;
  v_dados(v_dados.last()).vr_vllanmto := 7235.43;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12109282;
  v_dados(v_dados.last()).vr_nrctremp := 3297031;
  v_dados(v_dados.last()).vr_vllanmto := 14.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12113743;
  v_dados(v_dados.last()).vr_nrctremp := 4221205;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12113743;
  v_dados(v_dados.last()).vr_nrctremp := 6164373;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12123730;
  v_dados(v_dados.last()).vr_nrctremp := 3315152;
  v_dados(v_dados.last()).vr_vllanmto := 23.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12143200;
  v_dados(v_dados.last()).vr_nrctremp := 4857588;
  v_dados(v_dados.last()).vr_vllanmto := 8668.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12143200;
  v_dados(v_dados.last()).vr_nrctremp := 8171723;
  v_dados(v_dados.last()).vr_vllanmto := 16.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 3383461;
  v_dados(v_dados.last()).vr_vllanmto := 10801.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 4251082;
  v_dados(v_dados.last()).vr_vllanmto := 2418.64;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12148652;
  v_dados(v_dados.last()).vr_nrctremp := 7631064;
  v_dados(v_dados.last()).vr_vllanmto := 18.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12182249;
  v_dados(v_dados.last()).vr_nrctremp := 3389755;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12183890;
  v_dados(v_dados.last()).vr_nrctremp := 3393615;
  v_dados(v_dados.last()).vr_vllanmto := 12.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12212202;
  v_dados(v_dados.last()).vr_nrctremp := 3420248;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12238082;
  v_dados(v_dados.last()).vr_nrctremp := 7106507;
  v_dados(v_dados.last()).vr_vllanmto := 21.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12241059;
  v_dados(v_dados.last()).vr_nrctremp := 6769405;
  v_dados(v_dados.last()).vr_vllanmto := 10.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12245321;
  v_dados(v_dados.last()).vr_nrctremp := 7534433;
  v_dados(v_dados.last()).vr_vllanmto := 10.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12258431;
  v_dados(v_dados.last()).vr_nrctremp := 3455167;
  v_dados(v_dados.last()).vr_vllanmto := 13.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12263990;
  v_dados(v_dados.last()).vr_nrctremp := 6320282;
  v_dados(v_dados.last()).vr_vllanmto := 6404.91;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12274135;
  v_dados(v_dados.last()).vr_nrctremp := 3706648;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12278653;
  v_dados(v_dados.last()).vr_nrctremp := 4912772;
  v_dados(v_dados.last()).vr_vllanmto := 12.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12283754;
  v_dados(v_dados.last()).vr_nrctremp := 7648443;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12290742;
  v_dados(v_dados.last()).vr_nrctremp := 8092130;
  v_dados(v_dados.last()).vr_vllanmto := 16.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12292095;
  v_dados(v_dados.last()).vr_nrctremp := 5828078;
  v_dados(v_dados.last()).vr_vllanmto := 3694.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12293407;
  v_dados(v_dados.last()).vr_nrctremp := 3938066;
  v_dados(v_dados.last()).vr_vllanmto := 17.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12296570;
  v_dados(v_dados.last()).vr_nrctremp := 6824521;
  v_dados(v_dados.last()).vr_vllanmto := 15.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12298450;
  v_dados(v_dados.last()).vr_nrctremp := 7282249;
  v_dados(v_dados.last()).vr_vllanmto := 295.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12316628;
  v_dados(v_dados.last()).vr_nrctremp := 3510982;
  v_dados(v_dados.last()).vr_vllanmto := 172.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12316628;
  v_dados(v_dados.last()).vr_nrctremp := 3845592;
  v_dados(v_dados.last()).vr_vllanmto := 1260.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12317519;
  v_dados(v_dados.last()).vr_nrctremp := 5783533;
  v_dados(v_dados.last()).vr_vllanmto := 57.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12324841;
  v_dados(v_dados.last()).vr_nrctremp := 6400551;
  v_dados(v_dados.last()).vr_vllanmto := 530.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12324841;
  v_dados(v_dados.last()).vr_nrctremp := 7073135;
  v_dados(v_dados.last()).vr_vllanmto := 3848.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12325570;
  v_dados(v_dados.last()).vr_nrctremp := 3599984;
  v_dados(v_dados.last()).vr_vllanmto := 10.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12340871;
  v_dados(v_dados.last()).vr_nrctremp := 7940162;
  v_dados(v_dados.last()).vr_vllanmto := 22.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12359980;
  v_dados(v_dados.last()).vr_nrctremp := 5290818;
  v_dados(v_dados.last()).vr_vllanmto := 694.12;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12362778;
  v_dados(v_dados.last()).vr_nrctremp := 3742862;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12364690;
  v_dados(v_dados.last()).vr_nrctremp := 3572209;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12397253;
  v_dados(v_dados.last()).vr_nrctremp := 3600273;
  v_dados(v_dados.last()).vr_vllanmto := 3970.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12397253;
  v_dados(v_dados.last()).vr_nrctremp := 6375383;
  v_dados(v_dados.last()).vr_vllanmto := 890.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12405060;
  v_dados(v_dados.last()).vr_nrctremp := 3602629;
  v_dados(v_dados.last()).vr_vllanmto := 12.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12417742;
  v_dados(v_dados.last()).vr_nrctremp := 3614655;
  v_dados(v_dados.last()).vr_vllanmto := 2913.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12419940;
  v_dados(v_dados.last()).vr_nrctremp := 3618344;
  v_dados(v_dados.last()).vr_vllanmto := 15.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12439592;
  v_dados(v_dados.last()).vr_nrctremp := 4760725;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12455180;
  v_dados(v_dados.last()).vr_nrctremp := 3655624;
  v_dados(v_dados.last()).vr_vllanmto := 11.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12462888;
  v_dados(v_dados.last()).vr_nrctremp := 4022402;
  v_dados(v_dados.last()).vr_vllanmto := 948.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 7040.78;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12472778;
  v_dados(v_dados.last()).vr_nrctremp := 6732213;
  v_dados(v_dados.last()).vr_vllanmto := 17.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12475815;
  v_dados(v_dados.last()).vr_nrctremp := 5702554;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12501247;
  v_dados(v_dados.last()).vr_nrctremp := 7505459;
  v_dados(v_dados.last()).vr_vllanmto := 12.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12515701;
  v_dados(v_dados.last()).vr_nrctremp := 7531580;
  v_dados(v_dados.last()).vr_vllanmto := 13.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12519421;
  v_dados(v_dados.last()).vr_nrctremp := 3726006;
  v_dados(v_dados.last()).vr_vllanmto := 142.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12519421;
  v_dados(v_dados.last()).vr_nrctremp := 4059743;
  v_dados(v_dados.last()).vr_vllanmto := 20.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12520365;
  v_dados(v_dados.last()).vr_nrctremp := 3726902;
  v_dados(v_dados.last()).vr_vllanmto := 22.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12540552;
  v_dados(v_dados.last()).vr_nrctremp := 3741052;
  v_dados(v_dados.last()).vr_vllanmto := 397.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12543004;
  v_dados(v_dados.last()).vr_nrctremp := 3869309;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12548650;
  v_dados(v_dados.last()).vr_nrctremp := 3753649;
  v_dados(v_dados.last()).vr_vllanmto := 15.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12553913;
  v_dados(v_dados.last()).vr_nrctremp := 3758627;
  v_dados(v_dados.last()).vr_vllanmto := 11.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12557889;
  v_dados(v_dados.last()).vr_nrctremp := 3762595;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12561762;
  v_dados(v_dados.last()).vr_nrctremp := 4109959;
  v_dados(v_dados.last()).vr_vllanmto := 6894.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12568457;
  v_dados(v_dados.last()).vr_nrctremp := 3774764;
  v_dados(v_dados.last()).vr_vllanmto := 14.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12572713;
  v_dados(v_dados.last()).vr_nrctremp := 3795640;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12582565;
  v_dados(v_dados.last()).vr_nrctremp := 3986201;
  v_dados(v_dados.last()).vr_vllanmto := 13.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12584541;
  v_dados(v_dados.last()).vr_nrctremp := 6245755;
  v_dados(v_dados.last()).vr_vllanmto := 11.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12590487;
  v_dados(v_dados.last()).vr_nrctremp := 7387886;
  v_dados(v_dados.last()).vr_vllanmto := 25.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12595373;
  v_dados(v_dados.last()).vr_nrctremp := 8121940;
  v_dados(v_dados.last()).vr_vllanmto := 16.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12601977;
  v_dados(v_dados.last()).vr_nrctremp := 4029953;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12603210;
  v_dados(v_dados.last()).vr_nrctremp := 7317080;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12617008;
  v_dados(v_dados.last()).vr_nrctremp := 3827456;
  v_dados(v_dados.last()).vr_vllanmto := 148.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12620394;
  v_dados(v_dados.last()).vr_nrctremp := 3830750;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12627550;
  v_dados(v_dados.last()).vr_nrctremp := 7880925;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12673161;
  v_dados(v_dados.last()).vr_nrctremp := 4052613;
  v_dados(v_dados.last()).vr_vllanmto := 18.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12682780;
  v_dados(v_dados.last()).vr_nrctremp := 6402310;
  v_dados(v_dados.last()).vr_vllanmto := 23.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12694541;
  v_dados(v_dados.last()).vr_nrctremp := 4133615;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916683;
  v_dados(v_dados.last()).vr_vllanmto := 196.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916746;
  v_dados(v_dados.last()).vr_vllanmto := 68.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12701521;
  v_dados(v_dados.last()).vr_nrctremp := 3997739;
  v_dados(v_dados.last()).vr_vllanmto := 13.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12705276;
  v_dados(v_dados.last()).vr_nrctremp := 7552138;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12706477;
  v_dados(v_dados.last()).vr_nrctremp := 4016118;
  v_dados(v_dados.last()).vr_vllanmto := 14.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12706523;
  v_dados(v_dados.last()).vr_nrctremp := 4160235;
  v_dados(v_dados.last()).vr_vllanmto := 18.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12710091;
  v_dados(v_dados.last()).vr_nrctremp := 3935842;
  v_dados(v_dados.last()).vr_vllanmto := 17.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12710563;
  v_dados(v_dados.last()).vr_nrctremp := 4075169;
  v_dados(v_dados.last()).vr_vllanmto := 12.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12725480;
  v_dados(v_dados.last()).vr_nrctremp := 4202145;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12726486;
  v_dados(v_dados.last()).vr_nrctremp := 5493045;
  v_dados(v_dados.last()).vr_vllanmto := 14.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12737640;
  v_dados(v_dados.last()).vr_nrctremp := 4038250;
  v_dados(v_dados.last()).vr_vllanmto := 22.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739090;
  v_dados(v_dados.last()).vr_nrctremp := 4102671;
  v_dados(v_dados.last()).vr_vllanmto := 27.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739090;
  v_dados(v_dados.last()).vr_nrctremp := 5545715;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12755583;
  v_dados(v_dados.last()).vr_nrctremp := 8076864;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12756466;
  v_dados(v_dados.last()).vr_nrctremp := 4210230;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12763802;
  v_dados(v_dados.last()).vr_nrctremp := 5898980;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12784630;
  v_dados(v_dados.last()).vr_nrctremp := 5782397;
  v_dados(v_dados.last()).vr_vllanmto := 14.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12785369;
  v_dados(v_dados.last()).vr_nrctremp := 4083531;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12786675;
  v_dados(v_dados.last()).vr_nrctremp := 4243736;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12790079;
  v_dados(v_dados.last()).vr_nrctremp := 4349720;
  v_dados(v_dados.last()).vr_vllanmto := 18.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12801658;
  v_dados(v_dados.last()).vr_nrctremp := 5077570;
  v_dados(v_dados.last()).vr_vllanmto := 82.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12810533;
  v_dados(v_dados.last()).vr_nrctremp := 4245483;
  v_dados(v_dados.last()).vr_vllanmto := 1416.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12817678;
  v_dados(v_dados.last()).vr_nrctremp := 4256682;
  v_dados(v_dados.last()).vr_vllanmto := 15.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12825212;
  v_dados(v_dados.last()).vr_nrctremp := 4576380;
  v_dados(v_dados.last()).vr_vllanmto := 14.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12833797;
  v_dados(v_dados.last()).vr_nrctremp := 4181782;
  v_dados(v_dados.last()).vr_vllanmto := 11.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12873632;
  v_dados(v_dados.last()).vr_nrctremp := 4085979;
  v_dados(v_dados.last()).vr_vllanmto := 5046.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12893293;
  v_dados(v_dados.last()).vr_nrctremp := 7142175;
  v_dados(v_dados.last()).vr_vllanmto := 11.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12898651;
  v_dados(v_dados.last()).vr_nrctremp := 4188743;
  v_dados(v_dados.last()).vr_vllanmto := 14.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12942820;
  v_dados(v_dados.last()).vr_nrctremp := 7251150;
  v_dados(v_dados.last()).vr_vllanmto := 342.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12943924;
  v_dados(v_dados.last()).vr_nrctremp := 5246245;
  v_dados(v_dados.last()).vr_vllanmto := 5676.71;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12957461;
  v_dados(v_dados.last()).vr_nrctremp := 4349766;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12958387;
  v_dados(v_dados.last()).vr_nrctremp := 7057088;
  v_dados(v_dados.last()).vr_vllanmto := 32.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12963941;
  v_dados(v_dados.last()).vr_nrctremp := 4232365;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12967955;
  v_dados(v_dados.last()).vr_nrctremp := 6942688;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12976350;
  v_dados(v_dados.last()).vr_nrctremp := 5845377;
  v_dados(v_dados.last()).vr_vllanmto := 1263.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12981230;
  v_dados(v_dados.last()).vr_nrctremp := 6400299;
  v_dados(v_dados.last()).vr_vllanmto := 511.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12981877;
  v_dados(v_dados.last()).vr_nrctremp := 5200658;
  v_dados(v_dados.last()).vr_vllanmto := 250.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12982806;
  v_dados(v_dados.last()).vr_nrctremp := 7920561;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12998478;
  v_dados(v_dados.last()).vr_nrctremp := 7533612;
  v_dados(v_dados.last()).vr_vllanmto := 48.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13009389;
  v_dados(v_dados.last()).vr_nrctremp := 4348153;
  v_dados(v_dados.last()).vr_vllanmto := 17.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13009389;
  v_dados(v_dados.last()).vr_nrctremp := 7885529;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13011600;
  v_dados(v_dados.last()).vr_nrctremp := 5349520;
  v_dados(v_dados.last()).vr_vllanmto := 445.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13018809;
  v_dados(v_dados.last()).vr_nrctremp := 8058389;
  v_dados(v_dados.last()).vr_vllanmto := 15.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13022318;
  v_dados(v_dados.last()).vr_nrctremp := 6759409;
  v_dados(v_dados.last()).vr_vllanmto := 20420.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13028243;
  v_dados(v_dados.last()).vr_nrctremp := 6919014;
  v_dados(v_dados.last()).vr_vllanmto := 16.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13028847;
  v_dados(v_dados.last()).vr_nrctremp := 4256265;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13045806;
  v_dados(v_dados.last()).vr_nrctremp := 7452804;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13053140;
  v_dados(v_dados.last()).vr_nrctremp := 5779480;
  v_dados(v_dados.last()).vr_vllanmto := 629.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13053140;
  v_dados(v_dados.last()).vr_nrctremp := 5863094;
  v_dados(v_dados.last()).vr_vllanmto := 526.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13087525;
  v_dados(v_dados.last()).vr_nrctremp := 4375284;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13092839;
  v_dados(v_dados.last()).vr_nrctremp := 7923959;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13096702;
  v_dados(v_dados.last()).vr_nrctremp := 4346981;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13110519;
  v_dados(v_dados.last()).vr_nrctremp := 4375141;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13124129;
  v_dados(v_dados.last()).vr_nrctremp := 4502808;
  v_dados(v_dados.last()).vr_vllanmto := 14.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13151088;
  v_dados(v_dados.last()).vr_nrctremp := 4375227;
  v_dados(v_dados.last()).vr_vllanmto := 19.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13184270;
  v_dados(v_dados.last()).vr_nrctremp := 4313478;
  v_dados(v_dados.last()).vr_vllanmto := 11136.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13197967;
  v_dados(v_dados.last()).vr_nrctremp := 4536802;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13217526;
  v_dados(v_dados.last()).vr_nrctremp := 4692786;
  v_dados(v_dados.last()).vr_vllanmto := 23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13223127;
  v_dados(v_dados.last()).vr_nrctremp := 4499370;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13225146;
  v_dados(v_dados.last()).vr_nrctremp := 4950218;
  v_dados(v_dados.last()).vr_vllanmto := 17.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13249088;
  v_dados(v_dados.last()).vr_nrctremp := 7940412;
  v_dados(v_dados.last()).vr_vllanmto := 15.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13253131;
  v_dados(v_dados.last()).vr_nrctremp := 4434759;
  v_dados(v_dados.last()).vr_vllanmto := 14.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13262653;
  v_dados(v_dados.last()).vr_nrctremp := 7210381;
  v_dados(v_dados.last()).vr_vllanmto := 15313.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13266578;
  v_dados(v_dados.last()).vr_nrctremp := 4829270;
  v_dados(v_dados.last()).vr_vllanmto := 14.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13298216;
  v_dados(v_dados.last()).vr_nrctremp := 4662710;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13305280;
  v_dados(v_dados.last()).vr_nrctremp := 4407480;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13306138;
  v_dados(v_dados.last()).vr_nrctremp := 4901939;
  v_dados(v_dados.last()).vr_vllanmto := 13.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13309323;
  v_dados(v_dados.last()).vr_nrctremp := 7792894;
  v_dados(v_dados.last()).vr_vllanmto := 19.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13316419;
  v_dados(v_dados.last()).vr_nrctremp := 4575351;
  v_dados(v_dados.last()).vr_vllanmto := 12.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13335464;
  v_dados(v_dados.last()).vr_nrctremp := 4617398;
  v_dados(v_dados.last()).vr_vllanmto := 13.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13342509;
  v_dados(v_dados.last()).vr_nrctremp := 4463416;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13344048;
  v_dados(v_dados.last()).vr_nrctremp := 4462768;
  v_dados(v_dados.last()).vr_vllanmto := 16.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13352881;
  v_dados(v_dados.last()).vr_nrctremp := 4602620;
  v_dados(v_dados.last()).vr_vllanmto := 14.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13389408;
  v_dados(v_dados.last()).vr_nrctremp := 4639193;
  v_dados(v_dados.last()).vr_vllanmto := 18.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13413775;
  v_dados(v_dados.last()).vr_nrctremp := 4665968;
  v_dados(v_dados.last()).vr_vllanmto := 20.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13425072;
  v_dados(v_dados.last()).vr_nrctremp := 7954097;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13440241;
  v_dados(v_dados.last()).vr_nrctremp := 4672702;
  v_dados(v_dados.last()).vr_vllanmto := 13.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13455435;
  v_dados(v_dados.last()).vr_nrctremp := 4674078;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13481622;
  v_dados(v_dados.last()).vr_nrctremp := 4650705;
  v_dados(v_dados.last()).vr_vllanmto := 13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13536290;
  v_dados(v_dados.last()).vr_nrctremp := 4708727;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13570811;
  v_dados(v_dados.last()).vr_nrctremp := 7367000;
  v_dados(v_dados.last()).vr_vllanmto := 143.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13572148;
  v_dados(v_dados.last()).vr_nrctremp := 8029878;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13581155;
  v_dados(v_dados.last()).vr_nrctremp := 4921029;
  v_dados(v_dados.last()).vr_vllanmto := 16.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13582607;
  v_dados(v_dados.last()).vr_nrctremp := 6485397;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13582933;
  v_dados(v_dados.last()).vr_nrctremp := 4605327;
  v_dados(v_dados.last()).vr_vllanmto := 11.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13582933;
  v_dados(v_dados.last()).vr_nrctremp := 4605658;
  v_dados(v_dados.last()).vr_vllanmto := 13.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13584227;
  v_dados(v_dados.last()).vr_nrctremp := 4658343;
  v_dados(v_dados.last()).vr_vllanmto := 13.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13584227;
  v_dados(v_dados.last()).vr_nrctremp := 7486662;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13639080;
  v_dados(v_dados.last()).vr_nrctremp := 7721530;
  v_dados(v_dados.last()).vr_vllanmto := 14.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13647989;
  v_dados(v_dados.last()).vr_nrctremp := 5547013;
  v_dados(v_dados.last()).vr_vllanmto := 54.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13647989;
  v_dados(v_dados.last()).vr_nrctremp := 6791618;
  v_dados(v_dados.last()).vr_vllanmto := 56.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13659030;
  v_dados(v_dados.last()).vr_nrctremp := 6994301;
  v_dados(v_dados.last()).vr_vllanmto := 16.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13689380;
  v_dados(v_dados.last()).vr_nrctremp := 6931608;
  v_dados(v_dados.last()).vr_vllanmto := 17.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13689614;
  v_dados(v_dados.last()).vr_nrctremp := 7377291;
  v_dados(v_dados.last()).vr_vllanmto := 85.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13689614;
  v_dados(v_dados.last()).vr_nrctremp := 7703197;
  v_dados(v_dados.last()).vr_vllanmto := 728.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13702297;
  v_dados(v_dados.last()).vr_nrctremp := 5833525;
  v_dados(v_dados.last()).vr_vllanmto := 8950.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13709020;
  v_dados(v_dados.last()).vr_nrctremp := 5222855;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13718517;
  v_dados(v_dados.last()).vr_nrctremp := 7392446;
  v_dados(v_dados.last()).vr_vllanmto := 25.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13725580;
  v_dados(v_dados.last()).vr_nrctremp := 4885820;
  v_dados(v_dados.last()).vr_vllanmto := 13.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13739310;
  v_dados(v_dados.last()).vr_nrctremp := 6682498;
  v_dados(v_dados.last()).vr_vllanmto := 592.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13739425;
  v_dados(v_dados.last()).vr_nrctremp := 5531174;
  v_dados(v_dados.last()).vr_vllanmto := 6340.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13768514;
  v_dados(v_dados.last()).vr_nrctremp := 7238642;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13771663;
  v_dados(v_dados.last()).vr_nrctremp := 7885860;
  v_dados(v_dados.last()).vr_vllanmto := 153.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13794027;
  v_dados(v_dados.last()).vr_nrctremp := 7795288;
  v_dados(v_dados.last()).vr_vllanmto := 31.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13803107;
  v_dados(v_dados.last()).vr_nrctremp := 6647967;
  v_dados(v_dados.last()).vr_vllanmto := 2927.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13813471;
  v_dados(v_dados.last()).vr_nrctremp := 7526659;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13855549;
  v_dados(v_dados.last()).vr_nrctremp := 4814043;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13858769;
  v_dados(v_dados.last()).vr_nrctremp := 6422136;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13890964;
  v_dados(v_dados.last()).vr_nrctremp := 6274076;
  v_dados(v_dados.last()).vr_vllanmto := 100.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13904868;
  v_dados(v_dados.last()).vr_nrctremp := 6697017;
  v_dados(v_dados.last()).vr_vllanmto := 12.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13922050;
  v_dados(v_dados.last()).vr_nrctremp := 7396221;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13939998;
  v_dados(v_dados.last()).vr_nrctremp := 7040222;
  v_dados(v_dados.last()).vr_vllanmto := 1219.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13961497;
  v_dados(v_dados.last()).vr_nrctremp := 7361397;
  v_dados(v_dados.last()).vr_vllanmto := 14.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13979655;
  v_dados(v_dados.last()).vr_nrctremp := 7790313;
  v_dados(v_dados.last()).vr_vllanmto := 16.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14017083;
  v_dados(v_dados.last()).vr_nrctremp := 8084845;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14043505;
  v_dados(v_dados.last()).vr_nrctremp := 8109903;
  v_dados(v_dados.last()).vr_vllanmto := 11.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14070014;
  v_dados(v_dados.last()).vr_nrctremp := 8170736;
  v_dados(v_dados.last()).vr_vllanmto := 39.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14133660;
  v_dados(v_dados.last()).vr_nrctremp := 7581591;
  v_dados(v_dados.last()).vr_vllanmto := 21.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14142350;
  v_dados(v_dados.last()).vr_nrctremp := 5611560;
  v_dados(v_dados.last()).vr_vllanmto := 19.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14146258;
  v_dados(v_dados.last()).vr_nrctremp := 7373926;
  v_dados(v_dados.last()).vr_vllanmto := 13.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14180774;
  v_dados(v_dados.last()).vr_nrctremp := 7089998;
  v_dados(v_dados.last()).vr_vllanmto := 287.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14221616;
  v_dados(v_dados.last()).vr_nrctremp := 6911986;
  v_dados(v_dados.last()).vr_vllanmto := 96.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14238861;
  v_dados(v_dados.last()).vr_nrctremp := 6019047;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14282372;
  v_dados(v_dados.last()).vr_nrctremp := 7547854;
  v_dados(v_dados.last()).vr_vllanmto := 10.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14395606;
  v_dados(v_dados.last()).vr_nrctremp := 7153809;
  v_dados(v_dados.last()).vr_vllanmto := 10.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14397552;
  v_dados(v_dados.last()).vr_nrctremp := 7376637;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14422395;
  v_dados(v_dados.last()).vr_nrctremp := 7333609;
  v_dados(v_dados.last()).vr_vllanmto := 13.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14472023;
  v_dados(v_dados.last()).vr_nrctremp := 6756532;
  v_dados(v_dados.last()).vr_vllanmto := 12.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14481618;
  v_dados(v_dados.last()).vr_nrctremp := 5341434;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14504448;
  v_dados(v_dados.last()).vr_nrctremp := 7254507;
  v_dados(v_dados.last()).vr_vllanmto := 31.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14542170;
  v_dados(v_dados.last()).vr_nrctremp := 6443680;
  v_dados(v_dados.last()).vr_vllanmto := 141.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14542374;
  v_dados(v_dados.last()).vr_nrctremp := 8012058;
  v_dados(v_dados.last()).vr_vllanmto := 11.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14574985;
  v_dados(v_dados.last()).vr_nrctremp := 8016886;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14581744;
  v_dados(v_dados.last()).vr_nrctremp := 6585401;
  v_dados(v_dados.last()).vr_vllanmto := 18.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14590379;
  v_dados(v_dados.last()).vr_nrctremp := 8163055;
  v_dados(v_dados.last()).vr_vllanmto := 14.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14598345;
  v_dados(v_dados.last()).vr_nrctremp := 6520485;
  v_dados(v_dados.last()).vr_vllanmto := 1413.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14685701;
  v_dados(v_dados.last()).vr_nrctremp := 7867240;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14793121;
  v_dados(v_dados.last()).vr_nrctremp := 6608071;
  v_dados(v_dados.last()).vr_vllanmto := 29.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14810212;
  v_dados(v_dados.last()).vr_nrctremp := 7089569;
  v_dados(v_dados.last()).vr_vllanmto := 21.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14823802;
  v_dados(v_dados.last()).vr_nrctremp := 7389599;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14884674;
  v_dados(v_dados.last()).vr_nrctremp := 6635487;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14907224;
  v_dados(v_dados.last()).vr_nrctremp := 6406922;
  v_dados(v_dados.last()).vr_vllanmto := 102.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14925567;
  v_dados(v_dados.last()).vr_nrctremp := 7987822;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14949482;
  v_dados(v_dados.last()).vr_nrctremp := 5691194;
  v_dados(v_dados.last()).vr_vllanmto := 845.2;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14972930;
  v_dados(v_dados.last()).vr_nrctremp := 6257310;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15015033;
  v_dados(v_dados.last()).vr_nrctremp := 7488065;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15171353;
  v_dados(v_dados.last()).vr_nrctremp := 6753807;
  v_dados(v_dados.last()).vr_vllanmto := 1313.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15191044;
  v_dados(v_dados.last()).vr_nrctremp := 7584686;
  v_dados(v_dados.last()).vr_vllanmto := 10906.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15207536;
  v_dados(v_dados.last()).vr_nrctremp := 7224738;
  v_dados(v_dados.last()).vr_vllanmto := 29.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15214800;
  v_dados(v_dados.last()).vr_nrctremp := 7841256;
  v_dados(v_dados.last()).vr_vllanmto := 28.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15215997;
  v_dados(v_dados.last()).vr_nrctremp := 6679265;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15232743;
  v_dados(v_dados.last()).vr_nrctremp := 7179211;
  v_dados(v_dados.last()).vr_vllanmto := 19.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15261980;
  v_dados(v_dados.last()).vr_nrctremp := 7068082;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15261980;
  v_dados(v_dados.last()).vr_nrctremp := 7395511;
  v_dados(v_dados.last()).vr_vllanmto := 16.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15262057;
  v_dados(v_dados.last()).vr_nrctremp := 6646599;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15264734;
  v_dados(v_dados.last()).vr_nrctremp := 6627036;
  v_dados(v_dados.last()).vr_vllanmto := 755.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15266354;
  v_dados(v_dados.last()).vr_nrctremp := 6921135;
  v_dados(v_dados.last()).vr_vllanmto := 14.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15278620;
  v_dados(v_dados.last()).vr_nrctremp := 7710583;
  v_dados(v_dados.last()).vr_vllanmto := 64.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15316947;
  v_dados(v_dados.last()).vr_nrctremp := 6699401;
  v_dados(v_dados.last()).vr_vllanmto := 19.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15349608;
  v_dados(v_dados.last()).vr_nrctremp := 7097777;
  v_dados(v_dados.last()).vr_vllanmto := 29.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15424952;
  v_dados(v_dados.last()).vr_nrctremp := 7781429;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15451720;
  v_dados(v_dados.last()).vr_nrctremp := 7204447;
  v_dados(v_dados.last()).vr_vllanmto := 3447.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15455289;
  v_dados(v_dados.last()).vr_nrctremp := 7935480;
  v_dados(v_dados.last()).vr_vllanmto := 19.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15465810;
  v_dados(v_dados.last()).vr_nrctremp := 7850513;
  v_dados(v_dados.last()).vr_vllanmto := 14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15470016;
  v_dados(v_dados.last()).vr_nrctremp := 6317891;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15474550;
  v_dados(v_dados.last()).vr_nrctremp := 7773189;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15579522;
  v_dados(v_dados.last()).vr_nrctremp := 7895220;
  v_dados(v_dados.last()).vr_vllanmto := 32499.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15653803;
  v_dados(v_dados.last()).vr_nrctremp := 6191815;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15733807;
  v_dados(v_dados.last()).vr_nrctremp := 7155786;
  v_dados(v_dados.last()).vr_vllanmto := 3470.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15752224;
  v_dados(v_dados.last()).vr_nrctremp := 8067640;
  v_dados(v_dados.last()).vr_vllanmto := 23.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15765954;
  v_dados(v_dados.last()).vr_nrctremp := 7008494;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15767124;
  v_dados(v_dados.last()).vr_nrctremp := 6267194;
  v_dados(v_dados.last()).vr_vllanmto := 25.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15790258;
  v_dados(v_dados.last()).vr_nrctremp := 6707637;
  v_dados(v_dados.last()).vr_vllanmto := 20.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15851761;
  v_dados(v_dados.last()).vr_nrctremp := 6337886;
  v_dados(v_dados.last()).vr_vllanmto := 4925.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15857174;
  v_dados(v_dados.last()).vr_nrctremp := 7304942;
  v_dados(v_dados.last()).vr_vllanmto := 12.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

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
  v_dados(v_dados.last()).vr_nrdconta := 15869954;
  v_dados(v_dados.last()).vr_nrctremp := 7020060;
  v_dados(v_dados.last()).vr_vllanmto := 24.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15923860;
  v_dados(v_dados.last()).vr_nrctremp := 7098131;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15936007;
  v_dados(v_dados.last()).vr_nrctremp := 6677713;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15949559;
  v_dados(v_dados.last()).vr_nrctremp := 6394083;
  v_dados(v_dados.last()).vr_vllanmto := 5145.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15982750;
  v_dados(v_dados.last()).vr_nrctremp := 7584625;
  v_dados(v_dados.last()).vr_vllanmto := 34.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15988554;
  v_dados(v_dados.last()).vr_nrctremp := 7010783;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16043812;
  v_dados(v_dados.last()).vr_nrctremp := 6468398;
  v_dados(v_dados.last()).vr_vllanmto := 1459.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16079078;
  v_dados(v_dados.last()).vr_nrctremp := 8037548;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16138040;
  v_dados(v_dados.last()).vr_nrctremp := 7460277;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16143540;
  v_dados(v_dados.last()).vr_nrctremp := 6537132;
  v_dados(v_dados.last()).vr_vllanmto := 1235.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16178343;
  v_dados(v_dados.last()).vr_nrctremp := 6968793;
  v_dados(v_dados.last()).vr_vllanmto := 2470.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16204379;
  v_dados(v_dados.last()).vr_nrctremp := 6973807;
  v_dados(v_dados.last()).vr_vllanmto := 464.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16216342;
  v_dados(v_dados.last()).vr_nrctremp := 6578175;
  v_dados(v_dados.last()).vr_vllanmto := 15.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16223489;
  v_dados(v_dados.last()).vr_nrctremp := 7539225;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16323297;
  v_dados(v_dados.last()).vr_nrctremp := 7955535;
  v_dados(v_dados.last()).vr_vllanmto := 11.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16346742;
  v_dados(v_dados.last()).vr_nrctremp := 7956695;
  v_dados(v_dados.last()).vr_vllanmto := 13.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16406087;
  v_dados(v_dados.last()).vr_nrctremp := 6812280;
  v_dados(v_dados.last()).vr_vllanmto := 24.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16424263;
  v_dados(v_dados.last()).vr_nrctremp := 7703248;
  v_dados(v_dados.last()).vr_vllanmto := 23.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16586123;
  v_dados(v_dados.last()).vr_nrctremp := 7659298;
  v_dados(v_dados.last()).vr_vllanmto := 14.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16626710;
  v_dados(v_dados.last()).vr_nrctremp := 6842761;
  v_dados(v_dados.last()).vr_vllanmto := 29.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16647351;
  v_dados(v_dados.last()).vr_nrctremp := 6880760;
  v_dados(v_dados.last()).vr_vllanmto := 27.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16651472;
  v_dados(v_dados.last()).vr_nrctremp := 7632149;
  v_dados(v_dados.last()).vr_vllanmto := 20.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16654277;
  v_dados(v_dados.last()).vr_nrctremp := 6860528;
  v_dados(v_dados.last()).vr_vllanmto := 1103.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16673646;
  v_dados(v_dados.last()).vr_nrctremp := 8151658;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16703006;
  v_dados(v_dados.last()).vr_nrctremp := 6993826;
  v_dados(v_dados.last()).vr_vllanmto := 422.47;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16726979;
  v_dados(v_dados.last()).vr_nrctremp := 6908266;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16735943;
  v_dados(v_dados.last()).vr_nrctremp := 6912730;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16799682;
  v_dados(v_dados.last()).vr_nrctremp := 7918017;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16834054;
  v_dados(v_dados.last()).vr_nrctremp := 6974556;
  v_dados(v_dados.last()).vr_vllanmto := 758.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16871251;
  v_dados(v_dados.last()).vr_nrctremp := 8139313;
  v_dados(v_dados.last()).vr_vllanmto := 12.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16890248;
  v_dados(v_dados.last()).vr_nrctremp := 7477015;
  v_dados(v_dados.last()).vr_vllanmto := 12.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16890248;
  v_dados(v_dados.last()).vr_nrctremp := 8121138;
  v_dados(v_dados.last()).vr_vllanmto := 20.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16921925;
  v_dados(v_dados.last()).vr_nrctremp := 8011243;
  v_dados(v_dados.last()).vr_vllanmto := 19.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16944453;
  v_dados(v_dados.last()).vr_nrctremp := 7730157;
  v_dados(v_dados.last()).vr_vllanmto := 597.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16971272;
  v_dados(v_dados.last()).vr_nrctremp := 7740691;
  v_dados(v_dados.last()).vr_vllanmto := 13.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17042003;
  v_dados(v_dados.last()).vr_nrctremp := 8163150;
  v_dados(v_dados.last()).vr_vllanmto := 15.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17071020;
  v_dados(v_dados.last()).vr_nrctremp := 7762825;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17106842;
  v_dados(v_dados.last()).vr_nrctremp := 8031272;
  v_dados(v_dados.last()).vr_vllanmto := 15.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17158079;
  v_dados(v_dados.last()).vr_nrctremp := 7688768;
  v_dados(v_dados.last()).vr_vllanmto := 38.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17299128;
  v_dados(v_dados.last()).vr_nrctremp := 7260659;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17365279;
  v_dados(v_dados.last()).vr_nrctremp := 7980340;
  v_dados(v_dados.last()).vr_vllanmto := 36.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17366135;
  v_dados(v_dados.last()).vr_nrctremp := 8069188;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17380383;
  v_dados(v_dados.last()).vr_nrctremp := 7536616;
  v_dados(v_dados.last()).vr_vllanmto := 49.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17405831;
  v_dados(v_dados.last()).vr_nrctremp := 7347363;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17447682;
  v_dados(v_dados.last()).vr_nrctremp := 7618797;
  v_dados(v_dados.last()).vr_vllanmto := 29973.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17495105;
  v_dados(v_dados.last()).vr_nrctremp := 8042798;
  v_dados(v_dados.last()).vr_vllanmto := 14.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17514495;
  v_dados(v_dados.last()).vr_nrctremp := 8094516;
  v_dados(v_dados.last()).vr_vllanmto := 29.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17551757;
  v_dados(v_dados.last()).vr_nrctremp := 8069252;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17636779;
  v_dados(v_dados.last()).vr_nrctremp := 7468803;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17677521;
  v_dados(v_dados.last()).vr_nrctremp := 8057580;
  v_dados(v_dados.last()).vr_vllanmto := 16.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17695457;
  v_dados(v_dados.last()).vr_nrctremp := 7511234;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17743540;
  v_dados(v_dados.last()).vr_nrctremp := 7538792;
  v_dados(v_dados.last()).vr_vllanmto := 21.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17800978;
  v_dados(v_dados.last()).vr_nrctremp := 7576771;
  v_dados(v_dados.last()).vr_vllanmto := 10.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 17913276;
  v_dados(v_dados.last()).vr_nrctremp := 7745107;
  v_dados(v_dados.last()).vr_vllanmto := 27023.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 18100414;
  v_dados(v_dados.last()).vr_nrctremp := 7810862;
  v_dados(v_dados.last()).vr_vllanmto := 18.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 18336345;
  v_dados(v_dados.last()).vr_nrctremp := 7940446;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 18379265;
  v_dados(v_dados.last()).vr_nrctremp := 8035643;
  v_dados(v_dados.last()).vr_vllanmto := 16.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 18407463;
  v_dados(v_dados.last()).vr_nrctremp := 7989840;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 18428851;
  v_dados(v_dados.last()).vr_nrctremp := 7987621;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80066810;
  v_dados(v_dados.last()).vr_nrctremp := 5793704;
  v_dados(v_dados.last()).vr_vllanmto := 11.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80068685;
  v_dados(v_dados.last()).vr_nrctremp := 6243277;
  v_dados(v_dados.last()).vr_vllanmto := 117.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80090842;
  v_dados(v_dados.last()).vr_nrctremp := 5204912;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80099319;
  v_dados(v_dados.last()).vr_nrctremp := 8153376;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80099386;
  v_dados(v_dados.last()).vr_nrctremp := 7986926;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80110002;
  v_dados(v_dados.last()).vr_nrctremp := 8079786;
  v_dados(v_dados.last()).vr_vllanmto := 28.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80174647;
  v_dados(v_dados.last()).vr_nrctremp := 7977294;
  v_dados(v_dados.last()).vr_vllanmto := 19.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80214479;
  v_dados(v_dados.last()).vr_nrctremp := 4921364;
  v_dados(v_dados.last()).vr_vllanmto := 14.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80242502;
  v_dados(v_dados.last()).vr_nrctremp := 6747896;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80275664;
  v_dados(v_dados.last()).vr_nrctremp := 7609874;
  v_dados(v_dados.last()).vr_vllanmto := 34.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80277829;
  v_dados(v_dados.last()).vr_nrctremp := 6693146;
  v_dados(v_dados.last()).vr_vllanmto := 12.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80278809;
  v_dados(v_dados.last()).vr_nrctremp := 6793742;
  v_dados(v_dados.last()).vr_vllanmto := 25.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80289282;
  v_dados(v_dados.last()).vr_nrctremp := 6844392;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80334768;
  v_dados(v_dados.last()).vr_nrctremp := 3858963;
  v_dados(v_dados.last()).vr_vllanmto := 5643.7;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80338526;
  v_dados(v_dados.last()).vr_nrctremp := 5672938;
  v_dados(v_dados.last()).vr_vllanmto := 1643.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80419461;
  v_dados(v_dados.last()).vr_nrctremp := 6943420;
  v_dados(v_dados.last()).vr_vllanmto := 13.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80424732;
  v_dados(v_dados.last()).vr_nrctremp := 7345673;
  v_dados(v_dados.last()).vr_vllanmto := 22.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80436960;
  v_dados(v_dados.last()).vr_nrctremp := 7482898;
  v_dados(v_dados.last()).vr_vllanmto := 10.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80476651;
  v_dados(v_dados.last()).vr_nrctremp := 4558023;
  v_dados(v_dados.last()).vr_vllanmto := 960.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80480756;
  v_dados(v_dados.last()).vr_nrctremp := 7956703;
  v_dados(v_dados.last()).vr_vllanmto := 10.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90075382;
  v_dados(v_dados.last()).vr_nrctremp := 7799813;
  v_dados(v_dados.last()).vr_vllanmto := 28.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 90261844;
  v_dados(v_dados.last()).vr_nrctremp := 7921127;
  v_dados(v_dados.last()).vr_vllanmto := 14.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 215449;
  v_dados(v_dados.last()).vr_nrctremp := 501184;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 342610;
  v_dados(v_dados.last()).vr_nrctremp := 435842;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 374733;
  v_dados(v_dados.last()).vr_nrctremp := 522734;
  v_dados(v_dados.last()).vr_vllanmto := 15.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 409960;
  v_dados(v_dados.last()).vr_nrctremp := 303878;
  v_dados(v_dados.last()).vr_vllanmto := 52.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 409960;
  v_dados(v_dados.last()).vr_nrctremp := 536862;
  v_dados(v_dados.last()).vr_vllanmto := 53.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 504831;
  v_dados(v_dados.last()).vr_nrctremp := 472649;
  v_dados(v_dados.last()).vr_vllanmto := 12.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 509094;
  v_dados(v_dados.last()).vr_nrctremp := 395508;
  v_dados(v_dados.last()).vr_vllanmto := 80.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 536938;
  v_dados(v_dados.last()).vr_nrctremp := 480009;
  v_dados(v_dados.last()).vr_vllanmto := 31.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575046;
  v_dados(v_dados.last()).vr_nrctremp := 383395;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 599867;
  v_dados(v_dados.last()).vr_nrctremp := 493816;
  v_dados(v_dados.last()).vr_vllanmto := 43.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 601470;
  v_dados(v_dados.last()).vr_nrctremp := 376735;
  v_dados(v_dados.last()).vr_vllanmto := 13.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 637823;
  v_dados(v_dados.last()).vr_nrctremp := 368400;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 639087;
  v_dados(v_dados.last()).vr_nrctremp := 527126;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 643017;
  v_dados(v_dados.last()).vr_nrctremp := 534974;
  v_dados(v_dados.last()).vr_vllanmto := 54.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 658731;
  v_dados(v_dados.last()).vr_nrctremp := 440677;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 663255;
  v_dados(v_dados.last()).vr_nrctremp := 444313;
  v_dados(v_dados.last()).vr_vllanmto := 19.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 663778;
  v_dados(v_dados.last()).vr_nrctremp := 336241;
  v_dados(v_dados.last()).vr_vllanmto := 158.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 677442;
  v_dados(v_dados.last()).vr_nrctremp := 382071;
  v_dados(v_dados.last()).vr_vllanmto := 2683.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 684732;
  v_dados(v_dados.last()).vr_nrctremp := 378559;
  v_dados(v_dados.last()).vr_vllanmto := 20.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 697583;
  v_dados(v_dados.last()).vr_nrctremp := 474347;
  v_dados(v_dados.last()).vr_vllanmto := 19.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 699160;
  v_dados(v_dados.last()).vr_nrctremp := 486560;
  v_dados(v_dados.last()).vr_vllanmto := 28.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 705888;
  v_dados(v_dados.last()).vr_nrctremp := 491578;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 708461;
  v_dados(v_dados.last()).vr_nrctremp := 353095;
  v_dados(v_dados.last()).vr_vllanmto := 328.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 713228;
  v_dados(v_dados.last()).vr_nrctremp := 404068;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 736767;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 1356.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 745243;
  v_dados(v_dados.last()).vr_nrctremp := 488334;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 757365;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 148.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 766232;
  v_dados(v_dados.last()).vr_nrctremp := 440287;
  v_dados(v_dados.last()).vr_vllanmto := 10.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 771511;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 1132.27;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 786160;
  v_dados(v_dados.last()).vr_nrctremp := 526843;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 800961;
  v_dados(v_dados.last()).vr_nrctremp := 385817;
  v_dados(v_dados.last()).vr_vllanmto := 16.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 866547;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 2182.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 870110;
  v_dados(v_dados.last()).vr_nrctremp := 535422;
  v_dados(v_dados.last()).vr_vllanmto := 43.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 873276;
  v_dados(v_dados.last()).vr_nrctremp := 462064;
  v_dados(v_dados.last()).vr_vllanmto := 16.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 877425;
  v_dados(v_dados.last()).vr_nrctremp := 525128;
  v_dados(v_dados.last()).vr_vllanmto := 12.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 886050;
  v_dados(v_dados.last()).vr_nrctremp := 382587;
  v_dados(v_dados.last()).vr_vllanmto := 1924.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 892742;
  v_dados(v_dados.last()).vr_nrctremp := 533139;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 902519;
  v_dados(v_dados.last()).vr_nrctremp := 318129;
  v_dados(v_dados.last()).vr_vllanmto := 2562.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 908290;
  v_dados(v_dados.last()).vr_nrctremp := 487434;
  v_dados(v_dados.last()).vr_vllanmto := 19.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931195;
  v_dados(v_dados.last()).vr_nrctremp := 524502;
  v_dados(v_dados.last()).vr_vllanmto := 18.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931314;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := 3079.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 958883;
  v_dados(v_dados.last()).vr_nrctremp := 329872;
  v_dados(v_dados.last()).vr_vllanmto := 206.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 963143;
  v_dados(v_dados.last()).vr_nrctremp := 330810;
  v_dados(v_dados.last()).vr_vllanmto := 108.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 978442;
  v_dados(v_dados.last()).vr_nrctremp := 367150;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 978892;
  v_dados(v_dados.last()).vr_nrctremp := 500268;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 983667;
  v_dados(v_dados.last()).vr_nrctremp := 532789;
  v_dados(v_dados.last()).vr_vllanmto := 14.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 26661.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 989231;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 2182.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 348292;
  v_dados(v_dados.last()).vr_vllanmto := 1962.06;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 374317;
  v_dados(v_dados.last()).vr_vllanmto := 1275.85;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1026089;
  v_dados(v_dados.last()).vr_nrctremp := 399005;
  v_dados(v_dados.last()).vr_vllanmto := 1978.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1063162;
  v_dados(v_dados.last()).vr_nrctremp := 448080;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1079115;
  v_dados(v_dados.last()).vr_nrctremp := 531434;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1091140;
  v_dados(v_dados.last()).vr_nrctremp := 467278;
  v_dados(v_dados.last()).vr_vllanmto := 14.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1121170;
  v_dados(v_dados.last()).vr_nrctremp := 465246;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1130781;
  v_dados(v_dados.last()).vr_nrctremp := 356325;
  v_dados(v_dados.last()).vr_vllanmto := 110.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1132210;
  v_dados(v_dados.last()).vr_nrctremp := 506242;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1151010;
  v_dados(v_dados.last()).vr_nrctremp := 373912;
  v_dados(v_dados.last()).vr_vllanmto := 22.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1156462;
  v_dados(v_dados.last()).vr_nrctremp := 384151;
  v_dados(v_dados.last()).vr_vllanmto := 4483.41;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1181394;
  v_dados(v_dados.last()).vr_nrctremp := 450500;
  v_dados(v_dados.last()).vr_vllanmto := 796.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1191829;
  v_dados(v_dados.last()).vr_nrctremp := 429429;
  v_dados(v_dados.last()).vr_vllanmto := 10.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1193333;
  v_dados(v_dados.last()).vr_nrctremp := 524856;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1205790;
  v_dados(v_dados.last()).vr_nrctremp := 499489;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1214349;
  v_dados(v_dados.last()).vr_nrctremp := 506870;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1236229;
  v_dados(v_dados.last()).vr_nrctremp := 495659;
  v_dados(v_dados.last()).vr_vllanmto := 21.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1237292;
  v_dados(v_dados.last()).vr_nrctremp := 522443;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14289083;
  v_dados(v_dados.last()).vr_nrctremp := 409576;
  v_dados(v_dados.last()).vr_vllanmto := 5147.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14393603;
  v_dados(v_dados.last()).vr_nrctremp := 464368;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14466244;
  v_dados(v_dados.last()).vr_nrctremp := 363449;
  v_dados(v_dados.last()).vr_vllanmto := 25.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14601168;
  v_dados(v_dados.last()).vr_nrctremp := 378298;
  v_dados(v_dados.last()).vr_vllanmto := 105.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14698722;
  v_dados(v_dados.last()).vr_nrctremp := 379118;
  v_dados(v_dados.last()).vr_vllanmto := 44.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14754983;
  v_dados(v_dados.last()).vr_nrctremp := 472974;
  v_dados(v_dados.last()).vr_vllanmto := 161.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15236552;
  v_dados(v_dados.last()).vr_nrctremp := 398871;
  v_dados(v_dados.last()).vr_vllanmto := 18.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15268527;
  v_dados(v_dados.last()).vr_nrctremp := 500587;
  v_dados(v_dados.last()).vr_vllanmto := 23.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15268799;
  v_dados(v_dados.last()).vr_nrctremp := 474688;
  v_dados(v_dados.last()).vr_vllanmto := 10.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15491242;
  v_dados(v_dados.last()).vr_nrctremp := 410375;
  v_dados(v_dados.last()).vr_vllanmto := 1085.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15520838;
  v_dados(v_dados.last()).vr_nrctremp := 526539;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15623750;
  v_dados(v_dados.last()).vr_nrctremp := 415668;
  v_dados(v_dados.last()).vr_vllanmto := 24707.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15629821;
  v_dados(v_dados.last()).vr_nrctremp := 415902;
  v_dados(v_dados.last()).vr_vllanmto := 76.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15699927;
  v_dados(v_dados.last()).vr_nrctremp := 427146;
  v_dados(v_dados.last()).vr_vllanmto := 1469.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755223;
  v_dados(v_dados.last()).vr_nrctremp := 420713;
  v_dados(v_dados.last()).vr_vllanmto := 972.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755495;
  v_dados(v_dados.last()).vr_nrctremp := 420674;
  v_dados(v_dados.last()).vr_vllanmto := 191.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15755495;
  v_dados(v_dados.last()).vr_nrctremp := 445923;
  v_dados(v_dados.last()).vr_vllanmto := 236.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15776069;
  v_dados(v_dados.last()).vr_nrctremp := 421630;
  v_dados(v_dados.last()).vr_vllanmto := 1475.28;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15785904;
  v_dados(v_dados.last()).vr_nrctremp := 421960;
  v_dados(v_dados.last()).vr_vllanmto := 1606.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15813290;
  v_dados(v_dados.last()).vr_nrctremp := 423196;
  v_dados(v_dados.last()).vr_vllanmto := 29.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15813290;
  v_dados(v_dados.last()).vr_nrctremp := 435418;
  v_dados(v_dados.last()).vr_vllanmto := 11.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15880800;
  v_dados(v_dados.last()).vr_nrctremp := 426071;
  v_dados(v_dados.last()).vr_vllanmto := 997.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15980626;
  v_dados(v_dados.last()).vr_nrctremp := 429868;
  v_dados(v_dados.last()).vr_vllanmto := 210;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15984060;
  v_dados(v_dados.last()).vr_nrctremp := 430175;
  v_dados(v_dados.last()).vr_vllanmto := 45.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15986756;
  v_dados(v_dados.last()).vr_nrctremp := 435801;
  v_dados(v_dados.last()).vr_vllanmto := 817.56;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16265289;
  v_dados(v_dados.last()).vr_nrctremp := 440729;
  v_dados(v_dados.last()).vr_vllanmto := 16.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16330420;
  v_dados(v_dados.last()).vr_nrctremp := 501616;
  v_dados(v_dados.last()).vr_vllanmto := 44339.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16335252;
  v_dados(v_dados.last()).vr_nrctremp := 443506;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16410327;
  v_dados(v_dados.last()).vr_nrctremp := 489317;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16539540;
  v_dados(v_dados.last()).vr_nrctremp := 450619;
  v_dados(v_dados.last()).vr_vllanmto := 35.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16553535;
  v_dados(v_dados.last()).vr_nrctremp := 450924;
  v_dados(v_dados.last()).vr_vllanmto := 18.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16573668;
  v_dados(v_dados.last()).vr_nrctremp := 493339;
  v_dados(v_dados.last()).vr_vllanmto := 15.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16605683;
  v_dados(v_dados.last()).vr_nrctremp := 453031;
  v_dados(v_dados.last()).vr_vllanmto := 10.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16616294;
  v_dados(v_dados.last()).vr_nrctremp := 453566;
  v_dados(v_dados.last()).vr_vllanmto := 20509.83;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16764196;
  v_dados(v_dados.last()).vr_nrctremp := 458967;
  v_dados(v_dados.last()).vr_vllanmto := 10552.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16802845;
  v_dados(v_dados.last()).vr_nrctremp := 518072;
  v_dados(v_dados.last()).vr_vllanmto := 17.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16807243;
  v_dados(v_dados.last()).vr_nrctremp := 538137;
  v_dados(v_dados.last()).vr_vllanmto := 21.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16900405;
  v_dados(v_dados.last()).vr_nrctremp := 463986;
  v_dados(v_dados.last()).vr_vllanmto := 13.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17132045;
  v_dados(v_dados.last()).vr_nrctremp := 472296;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17225442;
  v_dados(v_dados.last()).vr_nrctremp := 475523;
  v_dados(v_dados.last()).vr_vllanmto := 71.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17316910;
  v_dados(v_dados.last()).vr_nrctremp := 479116;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17330742;
  v_dados(v_dados.last()).vr_nrctremp := 479757;
  v_dados(v_dados.last()).vr_vllanmto := 15.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17375550;
  v_dados(v_dados.last()).vr_nrctremp := 505269;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17433347;
  v_dados(v_dados.last()).vr_nrctremp := 483948;
  v_dados(v_dados.last()).vr_vllanmto := 11.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17461243;
  v_dados(v_dados.last()).vr_nrctremp := 486582;
  v_dados(v_dados.last()).vr_vllanmto := 32.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17678242;
  v_dados(v_dados.last()).vr_nrctremp := 514655;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17705908;
  v_dados(v_dados.last()).vr_nrctremp := 495652;
  v_dados(v_dados.last()).vr_vllanmto := 12.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17733375;
  v_dados(v_dados.last()).vr_nrctremp := 525112;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17769400;
  v_dados(v_dados.last()).vr_nrctremp := 502464;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17770530;
  v_dados(v_dados.last()).vr_nrctremp := 509402;
  v_dados(v_dados.last()).vr_vllanmto := 22.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17777690;
  v_dados(v_dados.last()).vr_nrctremp := 526059;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17780233;
  v_dados(v_dados.last()).vr_nrctremp := 536159;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17781060;
  v_dados(v_dados.last()).vr_nrctremp := 513709;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17929890;
  v_dados(v_dados.last()).vr_nrctremp := 507122;
  v_dados(v_dados.last()).vr_vllanmto := 11.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17947677;
  v_dados(v_dados.last()).vr_nrctremp := 505762;
  v_dados(v_dados.last()).vr_vllanmto := 11.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17999472;
  v_dados(v_dados.last()).vr_nrctremp := 507925;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18205984;
  v_dados(v_dados.last()).vr_nrctremp := 516648;
  v_dados(v_dados.last()).vr_vllanmto := 21.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18258999;
  v_dados(v_dados.last()).vr_nrctremp := 519505;
  v_dados(v_dados.last()).vr_vllanmto := 11.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18330576;
  v_dados(v_dados.last()).vr_nrctremp := 531704;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18336221;
  v_dados(v_dados.last()).vr_nrctremp := 522360;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18410294;
  v_dados(v_dados.last()).vr_nrctremp := 528807;
  v_dados(v_dados.last()).vr_vllanmto := 13.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18430317;
  v_dados(v_dados.last()).vr_nrctremp := 525807;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 18437320;
  v_dados(v_dados.last()).vr_nrctremp := 533689;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 884;
  v_dados(v_dados.last()).vr_nrctremp := 24536;
  v_dados(v_dados.last()).vr_vllanmto := 1379.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 3700;
  v_dados(v_dados.last()).vr_nrctremp := 25233;
  v_dados(v_dados.last()).vr_vllanmto := 223.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 3719;
  v_dados(v_dados.last()).vr_nrctremp := 88605;
  v_dados(v_dados.last()).vr_vllanmto := 27.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 20010;
  v_dados(v_dados.last()).vr_nrctremp := 78448;
  v_dados(v_dados.last()).vr_vllanmto := 972.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 20010;
  v_dados(v_dados.last()).vr_nrctremp := 81837;
  v_dados(v_dados.last()).vr_vllanmto := 579.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 34738;
  v_dados(v_dados.last()).vr_nrctremp := 24502;
  v_dados(v_dados.last()).vr_vllanmto := 543.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 39039;
  v_dados(v_dados.last()).vr_nrctremp := 76410;
  v_dados(v_dados.last()).vr_vllanmto := 20.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 59544;
  v_dados(v_dados.last()).vr_nrctremp := 106670;
  v_dados(v_dados.last()).vr_vllanmto := 35.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 109347;
  v_dados(v_dados.last()).vr_nrctremp := 118842;
  v_dados(v_dados.last()).vr_vllanmto := 19.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 111732;
  v_dados(v_dados.last()).vr_nrctremp := 117875;
  v_dados(v_dados.last()).vr_vllanmto := 27.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 116033;
  v_dados(v_dados.last()).vr_nrctremp := 117352;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 130567;
  v_dados(v_dados.last()).vr_nrctremp := 111242;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 133540;
  v_dados(v_dados.last()).vr_nrctremp := 141236;
  v_dados(v_dados.last()).vr_vllanmto := 23.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 141372;
  v_dados(v_dados.last()).vr_nrctremp := 27934;
  v_dados(v_dados.last()).vr_vllanmto := 166.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 147699;
  v_dados(v_dados.last()).vr_nrctremp := 95073;
  v_dados(v_dados.last()).vr_vllanmto := 2214.37;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 150045;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 3647.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 155020;
  v_dados(v_dados.last()).vr_nrctremp := 102339;
  v_dados(v_dados.last()).vr_vllanmto := 23.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 165859;
  v_dados(v_dados.last()).vr_nrctremp := 115385;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 190349;
  v_dados(v_dados.last()).vr_nrctremp := 80775;
  v_dados(v_dados.last()).vr_vllanmto := 251.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 224065;
  v_dados(v_dados.last()).vr_nrctremp := 146101;
  v_dados(v_dados.last()).vr_vllanmto := 47.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 257427;
  v_dados(v_dados.last()).vr_nrctremp := 59721;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 269026;
  v_dados(v_dados.last()).vr_nrctremp := 116557;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 271411;
  v_dados(v_dados.last()).vr_nrctremp := 122861;
  v_dados(v_dados.last()).vr_vllanmto := 12.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 273058;
  v_dados(v_dados.last()).vr_nrctremp := 83042;
  v_dados(v_dados.last()).vr_vllanmto := 32.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 55893;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 286575;
  v_dados(v_dados.last()).vr_nrctremp := 63200;
  v_dados(v_dados.last()).vr_vllanmto := 10914.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 295965;
  v_dados(v_dados.last()).vr_nrctremp := 85137;
  v_dados(v_dados.last()).vr_vllanmto := 27.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 299340;
  v_dados(v_dados.last()).vr_nrctremp := 91176;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 304174;
  v_dados(v_dados.last()).vr_nrctremp := 99070;
  v_dados(v_dados.last()).vr_vllanmto := 10.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 310433;
  v_dados(v_dados.last()).vr_nrctremp := 101735;
  v_dados(v_dados.last()).vr_vllanmto := 186.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 315516;
  v_dados(v_dados.last()).vr_nrctremp := 95930;
  v_dados(v_dados.last()).vr_vllanmto := 30.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 322571;
  v_dados(v_dados.last()).vr_nrctremp := 79948;
  v_dados(v_dados.last()).vr_vllanmto := 517.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 323454;
  v_dados(v_dados.last()).vr_nrctremp := 95971;
  v_dados(v_dados.last()).vr_vllanmto := 1382.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 347663;
  v_dados(v_dados.last()).vr_nrctremp := 117332;
  v_dados(v_dados.last()).vr_vllanmto := 18452.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348732;
  v_dados(v_dados.last()).vr_nrctremp := 59739;
  v_dados(v_dados.last()).vr_vllanmto := 38.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349682;
  v_dados(v_dados.last()).vr_nrctremp := 60356;
  v_dados(v_dados.last()).vr_vllanmto := 990.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349712;
  v_dados(v_dados.last()).vr_nrctremp := 60062;
  v_dados(v_dados.last()).vr_vllanmto := 34.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 350796;
  v_dados(v_dados.last()).vr_nrctremp := 103907;
  v_dados(v_dados.last()).vr_vllanmto := 634.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 351652;
  v_dados(v_dados.last()).vr_nrctremp := 66094;
  v_dados(v_dados.last()).vr_vllanmto := 12539.33;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 351830;
  v_dados(v_dados.last()).vr_nrctremp := 61604;
  v_dados(v_dados.last()).vr_vllanmto := 14.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 369861;
  v_dados(v_dados.last()).vr_nrctremp := 133924;
  v_dados(v_dados.last()).vr_vllanmto := 12.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14163829;
  v_dados(v_dados.last()).vr_nrctremp := 109004;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14223597;
  v_dados(v_dados.last()).vr_nrctremp := 138515;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14430177;
  v_dados(v_dados.last()).vr_nrctremp := 65975;
  v_dados(v_dados.last()).vr_vllanmto := 3614.11;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14516950;
  v_dados(v_dados.last()).vr_nrctremp := 71862;
  v_dados(v_dados.last()).vr_vllanmto := 1080;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14593580;
  v_dados(v_dados.last()).vr_nrctremp := 149502;
  v_dados(v_dados.last()).vr_vllanmto := 21.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14874334;
  v_dados(v_dados.last()).vr_nrctremp := 97364;
  v_dados(v_dados.last()).vr_vllanmto := 3263.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15154521;
  v_dados(v_dados.last()).vr_nrctremp := 92379;
  v_dados(v_dados.last()).vr_vllanmto := 9759.79;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15543005;
  v_dados(v_dados.last()).vr_nrctremp := 84735;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15758508;
  v_dados(v_dados.last()).vr_nrctremp := 112669;
  v_dados(v_dados.last()).vr_vllanmto := 11.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15842541;
  v_dados(v_dados.last()).vr_nrctremp := 136560;
  v_dados(v_dados.last()).vr_vllanmto := 15.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 15999300;
  v_dados(v_dados.last()).vr_nrctremp := 138385;
  v_dados(v_dados.last()).vr_vllanmto := 11.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16182669;
  v_dados(v_dados.last()).vr_nrctremp := 99917;
  v_dados(v_dados.last()).vr_vllanmto := 335.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16242459;
  v_dados(v_dados.last()).vr_nrctremp := 100840;
  v_dados(v_dados.last()).vr_vllanmto := 13.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16422147;
  v_dados(v_dados.last()).vr_nrctremp := 143051;
  v_dados(v_dados.last()).vr_vllanmto := 10.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16573226;
  v_dados(v_dados.last()).vr_nrctremp := 145587;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16885805;
  v_dados(v_dados.last()).vr_nrctremp := 115959;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16891155;
  v_dados(v_dados.last()).vr_nrctremp := 144131;
  v_dados(v_dados.last()).vr_vllanmto := 19.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16927400;
  v_dados(v_dados.last()).vr_nrctremp := 113288;
  v_dados(v_dados.last()).vr_vllanmto := 22.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17426235;
  v_dados(v_dados.last()).vr_nrctremp := 144399;
  v_dados(v_dados.last()).vr_vllanmto := 10.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17764076;
  v_dados(v_dados.last()).vr_nrctremp := 129676;
  v_dados(v_dados.last()).vr_vllanmto := 13.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17807964;
  v_dados(v_dados.last()).vr_nrctremp := 130591;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17812232;
  v_dados(v_dados.last()).vr_nrctremp := 130388;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 17898552;
  v_dados(v_dados.last()).vr_nrctremp := 132150;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 18142974;
  v_dados(v_dados.last()).vr_nrctremp := 137223;
  v_dados(v_dados.last()).vr_vllanmto := 20.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 18587305;
  v_dados(v_dados.last()).vr_nrctremp := 148205;
  v_dados(v_dados.last()).vr_vllanmto := 69.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 18750338;
  v_dados(v_dados.last()).vr_nrctremp := 149487;
  v_dados(v_dados.last()).vr_vllanmto := 23.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 14397;
  v_dados(v_dados.last()).vr_nrctremp := 281739;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 45012;
  v_dados(v_dados.last()).vr_nrctremp := 283799;
  v_dados(v_dados.last()).vr_vllanmto := 28.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 72192;
  v_dados(v_dados.last()).vr_nrctremp := 272745;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 117935;
  v_dados(v_dados.last()).vr_nrctremp := 283668;
  v_dados(v_dados.last()).vr_vllanmto := 15.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 124230;
  v_dados(v_dados.last()).vr_nrctremp := 270409;
  v_dados(v_dados.last()).vr_vllanmto := 32.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 146170;
  v_dados(v_dados.last()).vr_nrctremp := 284827;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 185680;
  v_dados(v_dados.last()).vr_nrctremp := 269186;
  v_dados(v_dados.last()).vr_vllanmto := 217.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 251666;
  v_dados(v_dados.last()).vr_nrctremp := 276952;
  v_dados(v_dados.last()).vr_vllanmto := 11.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 16405919;
  v_dados(v_dados.last()).vr_nrctremp := 270949;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 16442580;
  v_dados(v_dados.last()).vr_nrctremp := 271645;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 16482638;
  v_dados(v_dados.last()).vr_nrctremp := 272437;
  v_dados(v_dados.last()).vr_vllanmto := 43.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17363730;
  v_dados(v_dados.last()).vr_nrctremp := 277876;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17418615;
  v_dados(v_dados.last()).vr_nrctremp := 280632;
  v_dados(v_dados.last()).vr_vllanmto := 93.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17430976;
  v_dados(v_dados.last()).vr_nrctremp := 283211;
  v_dados(v_dados.last()).vr_vllanmto := 28.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17534615;
  v_dados(v_dados.last()).vr_nrctremp := 277920;
  v_dados(v_dados.last()).vr_vllanmto := 48.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17534615;
  v_dados(v_dados.last()).vr_nrctremp := 278347;
  v_dados(v_dados.last()).vr_vllanmto := 11.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17709296;
  v_dados(v_dados.last()).vr_nrctremp := 279043;
  v_dados(v_dados.last()).vr_vllanmto := 14.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17776007;
  v_dados(v_dados.last()).vr_nrctremp := 279351;
  v_dados(v_dados.last()).vr_vllanmto := 52.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17783330;
  v_dados(v_dados.last()).vr_nrctremp := 280862;
  v_dados(v_dados.last()).vr_vllanmto := 25.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17783330;
  v_dados(v_dados.last()).vr_nrctremp := 280865;
  v_dados(v_dados.last()).vr_vllanmto := 34.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17843626;
  v_dados(v_dados.last()).vr_nrctremp := 279877;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 17957737;
  v_dados(v_dados.last()).vr_nrctremp := 280698;
  v_dados(v_dados.last()).vr_vllanmto := 15.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18287751;
  v_dados(v_dados.last()).vr_nrctremp := 283416;
  v_dados(v_dados.last()).vr_vllanmto := 34.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18287751;
  v_dados(v_dados.last()).vr_nrctremp := 283417;
  v_dados(v_dados.last()).vr_vllanmto := 28.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18342710;
  v_dados(v_dados.last()).vr_nrctremp := 283055;
  v_dados(v_dados.last()).vr_vllanmto := 14.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18416225;
  v_dados(v_dados.last()).vr_nrctremp := 283413;
  v_dados(v_dados.last()).vr_vllanmto := 41.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18425100;
  v_dados(v_dados.last()).vr_nrctremp := 283648;
  v_dados(v_dados.last()).vr_vllanmto := 13.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18431631;
  v_dados(v_dados.last()).vr_nrctremp := 284077;
  v_dados(v_dados.last()).vr_vllanmto := 43.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 6;
  v_dados(v_dados.last()).vr_nrdconta := 18463355;
  v_dados(v_dados.last()).vr_nrctremp := 283904;
  v_dados(v_dados.last()).vr_vllanmto := 32.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 2640;
  v_dados(v_dados.last()).vr_nrctremp := 90721;
  v_dados(v_dados.last()).vr_vllanmto := 24.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 2941;
  v_dados(v_dados.last()).vr_nrctremp := 91516;
  v_dados(v_dados.last()).vr_vllanmto := 19.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 2941;
  v_dados(v_dados.last()).vr_nrctremp := 101662;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 3980;
  v_dados(v_dados.last()).vr_nrctremp := 92017;
  v_dados(v_dados.last()).vr_vllanmto := 18.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 4138;
  v_dados(v_dados.last()).vr_nrctremp := 106692;
  v_dados(v_dados.last()).vr_vllanmto := 19.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 4529;
  v_dados(v_dados.last()).vr_nrctremp := 110661;
  v_dados(v_dados.last()).vr_vllanmto := 40.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 20800;
  v_dados(v_dados.last()).vr_nrctremp := 90708;
  v_dados(v_dados.last()).vr_vllanmto := 25.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 26360;
  v_dados(v_dados.last()).vr_nrctremp := 103205;
  v_dados(v_dados.last()).vr_vllanmto := 26.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 26409;
  v_dados(v_dados.last()).vr_nrctremp := 80039;
  v_dados(v_dados.last()).vr_vllanmto := 11.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 27600;
  v_dados(v_dados.last()).vr_nrctremp := 114125;
  v_dados(v_dados.last()).vr_vllanmto := 30.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 27669;
  v_dados(v_dados.last()).vr_nrctremp := 110731;
  v_dados(v_dados.last()).vr_vllanmto := 56.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 29513;
  v_dados(v_dados.last()).vr_nrctremp := 90748;
  v_dados(v_dados.last()).vr_vllanmto := 22.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 30198;
  v_dados(v_dados.last()).vr_nrctremp := 57566;
  v_dados(v_dados.last()).vr_vllanmto := 19.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 50008;
  v_dados(v_dados.last()).vr_nrctremp := 122364;
  v_dados(v_dados.last()).vr_vllanmto := 14.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 62316;
  v_dados(v_dados.last()).vr_nrctremp := 104611;
  v_dados(v_dados.last()).vr_vllanmto := 65.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 63983;
  v_dados(v_dados.last()).vr_nrctremp := 108987;
  v_dados(v_dados.last()).vr_vllanmto := 24.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 65234;
  v_dados(v_dados.last()).vr_nrctremp := 123737;
  v_dados(v_dados.last()).vr_vllanmto := 50;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 66729;
  v_dados(v_dados.last()).vr_nrctremp := 97175;
  v_dados(v_dados.last()).vr_vllanmto := 41.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 73709;
  v_dados(v_dados.last()).vr_nrctremp := 121724;
  v_dados(v_dados.last()).vr_vllanmto := 25.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 90115;
  v_dados(v_dados.last()).vr_nrctremp := 56274;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 132195;
  v_dados(v_dados.last()).vr_nrctremp := 102798;
  v_dados(v_dados.last()).vr_vllanmto := 119.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 158070;
  v_dados(v_dados.last()).vr_nrctremp := 126374;
  v_dados(v_dados.last()).vr_vllanmto := 16.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 162604;
  v_dados(v_dados.last()).vr_nrctremp := 116240;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 192830;
  v_dados(v_dados.last()).vr_nrctremp := 126765;
  v_dados(v_dados.last()).vr_vllanmto := 17.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 210307;
  v_dados(v_dados.last()).vr_nrctremp := 118306;
  v_dados(v_dados.last()).vr_vllanmto := 25.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 253480;
  v_dados(v_dados.last()).vr_nrctremp := 119092;
  v_dados(v_dados.last()).vr_vllanmto := 55.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 253480;
  v_dados(v_dados.last()).vr_nrctremp := 126312;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 285803;
  v_dados(v_dados.last()).vr_nrctremp := 101130;
  v_dados(v_dados.last()).vr_vllanmto := 2513.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 287946;
  v_dados(v_dados.last()).vr_nrctremp := 116153;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 294284;
  v_dados(v_dados.last()).vr_nrctremp := 104973;
  v_dados(v_dados.last()).vr_vllanmto := 21.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 309362;
  v_dados(v_dados.last()).vr_nrctremp := 107939;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 315800;
  v_dados(v_dados.last()).vr_nrctremp := 91660;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 337447;
  v_dados(v_dados.last()).vr_nrctremp := 131636;
  v_dados(v_dados.last()).vr_vllanmto := 10.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 367583;
  v_dados(v_dados.last()).vr_nrctremp := 129624;
  v_dados(v_dados.last()).vr_vllanmto := 26.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 380059;
  v_dados(v_dados.last()).vr_nrctremp := 95652;
  v_dados(v_dados.last()).vr_vllanmto := 20.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 381403;
  v_dados(v_dados.last()).vr_nrctremp := 65947;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 389030;
  v_dados(v_dados.last()).vr_nrctremp := 110729;
  v_dados(v_dados.last()).vr_vllanmto := 28887.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 389110;
  v_dados(v_dados.last()).vr_nrctremp := 91051;
  v_dados(v_dados.last()).vr_vllanmto := 17.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 392740;
  v_dados(v_dados.last()).vr_nrctremp := 72380;
  v_dados(v_dados.last()).vr_vllanmto := 17.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 396109;
  v_dados(v_dados.last()).vr_nrctremp := 92585;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 396257;
  v_dados(v_dados.last()).vr_nrctremp := 90868;
  v_dados(v_dados.last()).vr_vllanmto := 838.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 399027;
  v_dados(v_dados.last()).vr_nrctremp := 131025;
  v_dados(v_dados.last()).vr_vllanmto := 11.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 399612;
  v_dados(v_dados.last()).vr_nrctremp := 91233;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 400564;
  v_dados(v_dados.last()).vr_nrctremp := 109205;
  v_dados(v_dados.last()).vr_vllanmto := 14.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 412112;
  v_dados(v_dados.last()).vr_nrctremp := 109366;
  v_dados(v_dados.last()).vr_vllanmto := 18.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 414085;
  v_dados(v_dados.last()).vr_nrctremp := 88622;
  v_dados(v_dados.last()).vr_vllanmto := 1793.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 414557;
  v_dados(v_dados.last()).vr_nrctremp := 123796;
  v_dados(v_dados.last()).vr_vllanmto := 27.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 423998;
  v_dados(v_dados.last()).vr_nrctremp := 107369;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 427497;
  v_dados(v_dados.last()).vr_nrctremp := 68493;
  v_dados(v_dados.last()).vr_vllanmto := 13.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 428540;
  v_dados(v_dados.last()).vr_nrctremp := 92165;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 445924;
  v_dados(v_dados.last()).vr_nrctremp := 103100;
  v_dados(v_dados.last()).vr_vllanmto := 29.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 445940;
  v_dados(v_dados.last()).vr_nrctremp := 82037;
  v_dados(v_dados.last()).vr_vllanmto := 2690.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446025;
  v_dados(v_dados.last()).vr_nrctremp := 83056;
  v_dados(v_dados.last()).vr_vllanmto := 748.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446742;
  v_dados(v_dados.last()).vr_nrctremp := 82971;
  v_dados(v_dados.last()).vr_vllanmto := 36.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 463655;
  v_dados(v_dados.last()).vr_nrctremp := 127494;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 470422;
  v_dados(v_dados.last()).vr_nrctremp := 106504;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 472662;
  v_dados(v_dados.last()).vr_nrctremp := 108793;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 473634;
  v_dados(v_dados.last()).vr_nrctremp := 109937;
  v_dados(v_dados.last()).vr_vllanmto := 24.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 474495;
  v_dados(v_dados.last()).vr_nrctremp := 118813;
  v_dados(v_dados.last()).vr_vllanmto := 18.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 477079;
  v_dados(v_dados.last()).vr_nrctremp := 113803;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 477079;
  v_dados(v_dados.last()).vr_nrctremp := 117565;
  v_dados(v_dados.last()).vr_vllanmto := 18.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 13883054;
  v_dados(v_dados.last()).vr_nrctremp := 112188;
  v_dados(v_dados.last()).vr_vllanmto := 30.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14085909;
  v_dados(v_dados.last()).vr_nrctremp := 130285;
  v_dados(v_dados.last()).vr_vllanmto := 7115.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14112868;
  v_dados(v_dados.last()).vr_nrctremp := 103950;
  v_dados(v_dados.last()).vr_vllanmto := 16.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14113449;
  v_dados(v_dados.last()).vr_nrctremp := 71178;
  v_dados(v_dados.last()).vr_vllanmto := 496.72;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14116243;
  v_dados(v_dados.last()).vr_nrctremp := 108059;
  v_dados(v_dados.last()).vr_vllanmto := 17.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14121212;
  v_dados(v_dados.last()).vr_nrctremp := 91657;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14122413;
  v_dados(v_dados.last()).vr_nrctremp := 121584;
  v_dados(v_dados.last()).vr_vllanmto := 33.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14132834;
  v_dados(v_dados.last()).vr_nrctremp := 110893;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14140853;
  v_dados(v_dados.last()).vr_nrctremp := 118815;
  v_dados(v_dados.last()).vr_vllanmto := 36.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14140888;
  v_dados(v_dados.last()).vr_nrctremp := 106454;
  v_dados(v_dados.last()).vr_vllanmto := 880.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14143100;
  v_dados(v_dados.last()).vr_nrctremp := 97646;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14147114;
  v_dados(v_dados.last()).vr_nrctremp := 88553;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14164450;
  v_dados(v_dados.last()).vr_nrctremp := 102640;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14165791;
  v_dados(v_dados.last()).vr_nrctremp := 99439;
  v_dados(v_dados.last()).vr_vllanmto := 24.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14166313;
  v_dados(v_dados.last()).vr_nrctremp := 73261;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14187370;
  v_dados(v_dados.last()).vr_nrctremp := 112505;
  v_dados(v_dados.last()).vr_vllanmto := 17.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14192969;
  v_dados(v_dados.last()).vr_nrctremp := 72270;
  v_dados(v_dados.last()).vr_vllanmto := 13.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203103;
  v_dados(v_dados.last()).vr_nrctremp := 113182;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203324;
  v_dados(v_dados.last()).vr_nrctremp := 72406;
  v_dados(v_dados.last()).vr_vllanmto := 2215.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14203324;
  v_dados(v_dados.last()).vr_nrctremp := 85135;
  v_dados(v_dados.last()).vr_vllanmto := 2769.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14204118;
  v_dados(v_dados.last()).vr_nrctremp := 128165;
  v_dados(v_dados.last()).vr_vllanmto := 22.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14204274;
  v_dados(v_dados.last()).vr_nrctremp := 125764;
  v_dados(v_dados.last()).vr_vllanmto := 51.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14205653;
  v_dados(v_dados.last()).vr_nrctremp := 85268;
  v_dados(v_dados.last()).vr_vllanmto := 241.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14226367;
  v_dados(v_dados.last()).vr_nrctremp := 113354;
  v_dados(v_dados.last()).vr_vllanmto := 11.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73418;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73422;
  v_dados(v_dados.last()).vr_vllanmto := 165.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14228203;
  v_dados(v_dados.last()).vr_nrctremp := 130059;
  v_dados(v_dados.last()).vr_vllanmto := 28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14249383;
  v_dados(v_dados.last()).vr_nrctremp := 100206;
  v_dados(v_dados.last()).vr_vllanmto := 40.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14270706;
  v_dados(v_dados.last()).vr_nrctremp := 72996;
  v_dados(v_dados.last()).vr_vllanmto := 86.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14283425;
  v_dados(v_dados.last()).vr_nrctremp := 131798;
  v_dados(v_dados.last()).vr_vllanmto := 10.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14285703;
  v_dados(v_dados.last()).vr_nrctremp := 74338;
  v_dados(v_dados.last()).vr_vllanmto := 95.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14299534;
  v_dados(v_dados.last()).vr_nrctremp := 97212;
  v_dados(v_dados.last()).vr_vllanmto := 6248.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14300133;
  v_dados(v_dados.last()).vr_nrctremp := 74775;
  v_dados(v_dados.last()).vr_vllanmto := 176.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14418940;
  v_dados(v_dados.last()).vr_nrctremp := 75101;
  v_dados(v_dados.last()).vr_vllanmto := 2772.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14419181;
  v_dados(v_dados.last()).vr_nrctremp := 91178;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14507749;
  v_dados(v_dados.last()).vr_nrctremp := 77826;
  v_dados(v_dados.last()).vr_vllanmto := 344.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14508109;
  v_dados(v_dados.last()).vr_nrctremp := 96151;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14510030;
  v_dados(v_dados.last()).vr_nrctremp := 101028;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14511134;
  v_dados(v_dados.last()).vr_nrctremp := 98255;
  v_dados(v_dados.last()).vr_vllanmto := 17164.5;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14532492;
  v_dados(v_dados.last()).vr_nrctremp := 116677;
  v_dados(v_dados.last()).vr_vllanmto := 13.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14545454;
  v_dados(v_dados.last()).vr_nrctremp := 117503;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14552205;
  v_dados(v_dados.last()).vr_nrctremp := 129056;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14579715;
  v_dados(v_dados.last()).vr_nrctremp := 127210;
  v_dados(v_dados.last()).vr_vllanmto := 25.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14579898;
  v_dados(v_dados.last()).vr_nrctremp := 80162;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14786885;
  v_dados(v_dados.last()).vr_nrctremp := 81413;
  v_dados(v_dados.last()).vr_vllanmto := 25.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14788616;
  v_dados(v_dados.last()).vr_nrctremp := 82634;
  v_dados(v_dados.last()).vr_vllanmto := 95.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14797658;
  v_dados(v_dados.last()).vr_nrctremp := 80671;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14838460;
  v_dados(v_dados.last()).vr_nrctremp := 81031;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14956810;
  v_dados(v_dados.last()).vr_nrctremp := 123747;
  v_dados(v_dados.last()).vr_vllanmto := 38.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14999064;
  v_dados(v_dados.last()).vr_nrctremp := 83702;
  v_dados(v_dados.last()).vr_vllanmto := 365.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14999404;
  v_dados(v_dados.last()).vr_nrctremp := 106614;
  v_dados(v_dados.last()).vr_vllanmto := 18.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15035816;
  v_dados(v_dados.last()).vr_nrctremp := 127935;
  v_dados(v_dados.last()).vr_vllanmto := 11.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85491;
  v_dados(v_dados.last()).vr_vllanmto := 67.47;
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
  v_dados(v_dados.last()).vr_nrdconta := 15045536;
  v_dados(v_dados.last()).vr_nrctremp := 84301;
  v_dados(v_dados.last()).vr_vllanmto := 96.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15046125;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 21.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15047806;
  v_dados(v_dados.last()).vr_nrctremp := 84306;
  v_dados(v_dados.last()).vr_vllanmto := 129.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15049043;
  v_dados(v_dados.last()).vr_nrctremp := 109386;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15068269;
  v_dados(v_dados.last()).vr_nrctremp := 112826;
  v_dados(v_dados.last()).vr_vllanmto := 13.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15131769;
  v_dados(v_dados.last()).vr_nrctremp := 125655;
  v_dados(v_dados.last()).vr_vllanmto := 59.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15132170;
  v_dados(v_dados.last()).vr_nrctremp := 85404;
  v_dados(v_dados.last()).vr_vllanmto := 431.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15200345;
  v_dados(v_dados.last()).vr_nrctremp := 126895;
  v_dados(v_dados.last()).vr_vllanmto := 11.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15213200;
  v_dados(v_dados.last()).vr_nrctremp := 95436;
  v_dados(v_dados.last()).vr_vllanmto := 13.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15239314;
  v_dados(v_dados.last()).vr_nrctremp := 114608;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15245861;
  v_dados(v_dados.last()).vr_nrctremp := 86919;
  v_dados(v_dados.last()).vr_vllanmto := 7097.35;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 87201;
  v_dados(v_dados.last()).vr_vllanmto := 2478.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 87202;
  v_dados(v_dados.last()).vr_vllanmto := 579.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15257320;
  v_dados(v_dados.last()).vr_nrctremp := 91962;
  v_dados(v_dados.last()).vr_vllanmto := 2163.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15301990;
  v_dados(v_dados.last()).vr_nrctremp := 87717;
  v_dados(v_dados.last()).vr_vllanmto := 12.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15314090;
  v_dados(v_dados.last()).vr_nrctremp := 106406;
  v_dados(v_dados.last()).vr_vllanmto := 18.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15372499;
  v_dados(v_dados.last()).vr_nrctremp := 104977;
  v_dados(v_dados.last()).vr_vllanmto := 19.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15375501;
  v_dados(v_dados.last()).vr_nrctremp := 91551;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15473082;
  v_dados(v_dados.last()).vr_nrctremp := 107235;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15473082;
  v_dados(v_dados.last()).vr_nrctremp := 115811;
  v_dados(v_dados.last()).vr_vllanmto := 17.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15542530;
  v_dados(v_dados.last()).vr_nrctremp := 105554;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15563197;
  v_dados(v_dados.last()).vr_nrctremp := 93355;
  v_dados(v_dados.last()).vr_vllanmto := 1257.02;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15628035;
  v_dados(v_dados.last()).vr_nrctremp := 115507;
  v_dados(v_dados.last()).vr_vllanmto := 28.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15647315;
  v_dados(v_dados.last()).vr_nrctremp := 91958;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15674444;
  v_dados(v_dados.last()).vr_nrctremp := 98271;
  v_dados(v_dados.last()).vr_vllanmto := 16.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15682560;
  v_dados(v_dados.last()).vr_nrctremp := 92366;
  v_dados(v_dados.last()).vr_vllanmto := 39.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15718441;
  v_dados(v_dados.last()).vr_nrctremp := 127149;
  v_dados(v_dados.last()).vr_vllanmto := 20.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15719502;
  v_dados(v_dados.last()).vr_nrctremp := 127076;
  v_dados(v_dados.last()).vr_vllanmto := 10.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15725944;
  v_dados(v_dados.last()).vr_nrctremp := 93189;
  v_dados(v_dados.last()).vr_vllanmto := 20.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15738116;
  v_dados(v_dados.last()).vr_nrctremp := 93183;
  v_dados(v_dados.last()).vr_vllanmto := 263.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15783600;
  v_dados(v_dados.last()).vr_nrctremp := 99663;
  v_dados(v_dados.last()).vr_vllanmto := 12.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15783600;
  v_dados(v_dados.last()).vr_nrctremp := 106125;
  v_dados(v_dados.last()).vr_vllanmto := 40.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15786609;
  v_dados(v_dados.last()).vr_nrctremp := 128493;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15850145;
  v_dados(v_dados.last()).vr_nrctremp := 97214;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15854922;
  v_dados(v_dados.last()).vr_nrctremp := 94696;
  v_dados(v_dados.last()).vr_vllanmto := 31.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 94656;
  v_dados(v_dados.last()).vr_vllanmto := 1169.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862828;
  v_dados(v_dados.last()).vr_nrctremp := 95863;
  v_dados(v_dados.last()).vr_vllanmto := 184.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15862917;
  v_dados(v_dados.last()).vr_nrctremp := 119987;
  v_dados(v_dados.last()).vr_vllanmto := 10.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15863077;
  v_dados(v_dados.last()).vr_nrctremp := 131083;
  v_dados(v_dados.last()).vr_vllanmto := 35.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15863328;
  v_dados(v_dados.last()).vr_nrctremp := 94670;
  v_dados(v_dados.last()).vr_vllanmto := 61.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15863603;
  v_dados(v_dados.last()).vr_nrctremp := 95984;
  v_dados(v_dados.last()).vr_vllanmto := 24.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864065;
  v_dados(v_dados.last()).vr_nrctremp := 97094;
  v_dados(v_dados.last()).vr_vllanmto := 919.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15864529;
  v_dados(v_dados.last()).vr_nrctremp := 94677;
  v_dados(v_dados.last()).vr_vllanmto := 579.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15865002;
  v_dados(v_dados.last()).vr_nrctremp := 131283;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15868966;
  v_dados(v_dados.last()).vr_nrctremp := 96518;
  v_dados(v_dados.last()).vr_vllanmto := 12.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15868966;
  v_dados(v_dados.last()).vr_nrctremp := 96522;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15868966;
  v_dados(v_dados.last()).vr_nrctremp := 100559;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15868966;
  v_dados(v_dados.last()).vr_nrctremp := 109666;
  v_dados(v_dados.last()).vr_vllanmto := 20.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15876071;
  v_dados(v_dados.last()).vr_nrctremp := 96641;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15903915;
  v_dados(v_dados.last()).vr_nrctremp := 97640;
  v_dados(v_dados.last()).vr_vllanmto := 325.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15904709;
  v_dados(v_dados.last()).vr_nrctremp := 97668;
  v_dados(v_dados.last()).vr_vllanmto := 33.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15912647;
  v_dados(v_dados.last()).vr_nrctremp := 95590;
  v_dados(v_dados.last()).vr_vllanmto := 13.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15914151;
  v_dados(v_dados.last()).vr_nrctremp := 127566;
  v_dados(v_dados.last()).vr_vllanmto := 10.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15916391;
  v_dados(v_dados.last()).vr_nrctremp := 101061;
  v_dados(v_dados.last()).vr_vllanmto := 3811.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15917487;
  v_dados(v_dados.last()).vr_nrctremp := 98933;
  v_dados(v_dados.last()).vr_vllanmto := 10.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15917487;
  v_dados(v_dados.last()).vr_nrctremp := 108704;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
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
  v_dados(v_dados.last()).vr_nrdconta := 15941337;
  v_dados(v_dados.last()).vr_nrctremp := 96634;
  v_dados(v_dados.last()).vr_vllanmto := 27.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15949753;
  v_dados(v_dados.last()).vr_nrctremp := 96529;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15981177;
  v_dados(v_dados.last()).vr_nrctremp := 98041;
  v_dados(v_dados.last()).vr_vllanmto := 51.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15989291;
  v_dados(v_dados.last()).vr_nrctremp := 97016;
  v_dados(v_dados.last()).vr_vllanmto := 873.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15993221;
  v_dados(v_dados.last()).vr_nrctremp := 97852;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16021312;
  v_dados(v_dados.last()).vr_nrctremp := 129607;
  v_dados(v_dados.last()).vr_vllanmto := 66.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16023080;
  v_dados(v_dados.last()).vr_nrctremp := 100243;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16088891;
  v_dados(v_dados.last()).vr_nrctremp := 102646;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16097734;
  v_dados(v_dados.last()).vr_nrctremp := 98089;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16123255;
  v_dados(v_dados.last()).vr_nrctremp := 106448;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16137183;
  v_dados(v_dados.last()).vr_nrctremp := 125313;
  v_dados(v_dados.last()).vr_vllanmto := 78.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16160363;
  v_dados(v_dados.last()).vr_nrctremp := 101364;
  v_dados(v_dados.last()).vr_vllanmto := 1952.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16197062;
  v_dados(v_dados.last()).vr_nrctremp := 99199;
  v_dados(v_dados.last()).vr_vllanmto := 483.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16283716;
  v_dados(v_dados.last()).vr_nrctremp := 101132;
  v_dados(v_dados.last()).vr_vllanmto := 78.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16283716;
  v_dados(v_dados.last()).vr_nrctremp := 101137;
  v_dados(v_dados.last()).vr_vllanmto := 154.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16308638;
  v_dados(v_dados.last()).vr_nrctremp := 102501;
  v_dados(v_dados.last()).vr_vllanmto := 19.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16313895;
  v_dados(v_dados.last()).vr_nrctremp := 100585;
  v_dados(v_dados.last()).vr_vllanmto := 16.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16328990;
  v_dados(v_dados.last()).vr_nrctremp := 111222;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16330080;
  v_dados(v_dados.last()).vr_nrctremp := 101848;
  v_dados(v_dados.last()).vr_vllanmto := 13.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16332547;
  v_dados(v_dados.last()).vr_nrctremp := 129754;
  v_dados(v_dados.last()).vr_vllanmto := 66.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16444124;
  v_dados(v_dados.last()).vr_nrctremp := 102136;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16444124;
  v_dados(v_dados.last()).vr_nrctremp := 126733;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16447050;
  v_dados(v_dados.last()).vr_nrctremp := 119427;
  v_dados(v_dados.last()).vr_vllanmto := 40.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16478320;
  v_dados(v_dados.last()).vr_nrctremp := 102406;
  v_dados(v_dados.last()).vr_vllanmto := 2106.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16483219;
  v_dados(v_dados.last()).vr_nrctremp := 109929;
  v_dados(v_dados.last()).vr_vllanmto := 13.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16547373;
  v_dados(v_dados.last()).vr_nrctremp := 118085;
  v_dados(v_dados.last()).vr_vllanmto := 33.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16549414;
  v_dados(v_dados.last()).vr_nrctremp := 109334;
  v_dados(v_dados.last()).vr_vllanmto := 589.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16618637;
  v_dados(v_dados.last()).vr_nrctremp := 103993;
  v_dados(v_dados.last()).vr_vllanmto := 10.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16814991;
  v_dados(v_dados.last()).vr_nrctremp := 118234;
  v_dados(v_dados.last()).vr_vllanmto := 1172.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16816706;
  v_dados(v_dados.last()).vr_nrctremp := 108148;
  v_dados(v_dados.last()).vr_vllanmto := 15.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16835921;
  v_dados(v_dados.last()).vr_nrctremp := 108106;
  v_dados(v_dados.last()).vr_vllanmto := 10.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16855493;
  v_dados(v_dados.last()).vr_nrctremp := 111594;
  v_dados(v_dados.last()).vr_vllanmto := 20.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16857097;
  v_dados(v_dados.last()).vr_nrctremp := 107160;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16872460;
  v_dados(v_dados.last()).vr_nrctremp := 121957;
  v_dados(v_dados.last()).vr_vllanmto := 10.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16872460;
  v_dados(v_dados.last()).vr_nrctremp := 129965;
  v_dados(v_dados.last()).vr_vllanmto := 13.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16894952;
  v_dados(v_dados.last()).vr_nrctremp := 116312;
  v_dados(v_dados.last()).vr_vllanmto := 22.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16894952;
  v_dados(v_dados.last()).vr_nrctremp := 123465;
  v_dados(v_dados.last()).vr_vllanmto := 36.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16919343;
  v_dados(v_dados.last()).vr_nrctremp := 109944;
  v_dados(v_dados.last()).vr_vllanmto := 13.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16921399;
  v_dados(v_dados.last()).vr_nrctremp := 111185;
  v_dados(v_dados.last()).vr_vllanmto := 21.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16926676;
  v_dados(v_dados.last()).vr_nrctremp := 127914;
  v_dados(v_dados.last()).vr_vllanmto := 13.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16928873;
  v_dados(v_dados.last()).vr_nrctremp := 108284;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16997310;
  v_dados(v_dados.last()).vr_nrctremp := 128912;
  v_dados(v_dados.last()).vr_vllanmto := 42.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17000181;
  v_dados(v_dados.last()).vr_nrctremp := 109513;
  v_dados(v_dados.last()).vr_vllanmto := 13.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17012368;
  v_dados(v_dados.last()).vr_nrctremp := 109058;
  v_dados(v_dados.last()).vr_vllanmto := 2247.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17028663;
  v_dados(v_dados.last()).vr_nrctremp := 110723;
  v_dados(v_dados.last()).vr_vllanmto := 11.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17042569;
  v_dados(v_dados.last()).vr_nrctremp := 115982;
  v_dados(v_dados.last()).vr_vllanmto := 33.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17067081;
  v_dados(v_dados.last()).vr_nrctremp := 110811;
  v_dados(v_dados.last()).vr_vllanmto := 27.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17067081;
  v_dados(v_dados.last()).vr_nrctremp := 126301;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17071151;
  v_dados(v_dados.last()).vr_nrctremp := 110453;
  v_dados(v_dados.last()).vr_vllanmto := 15.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17086302;
  v_dados(v_dados.last()).vr_nrctremp := 110529;
  v_dados(v_dados.last()).vr_vllanmto := 40.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17086302;
  v_dados(v_dados.last()).vr_nrctremp := 125408;
  v_dados(v_dados.last()).vr_vllanmto := 25.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17089808;
  v_dados(v_dados.last()).vr_nrctremp := 117443;
  v_dados(v_dados.last()).vr_vllanmto := 33.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17105412;
  v_dados(v_dados.last()).vr_nrctremp := 122623;
  v_dados(v_dados.last()).vr_vllanmto := 14.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17177936;
  v_dados(v_dados.last()).vr_nrctremp := 111922;
  v_dados(v_dados.last()).vr_vllanmto := 22.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17181984;
  v_dados(v_dados.last()).vr_nrctremp := 116670;
  v_dados(v_dados.last()).vr_vllanmto := 40.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17198879;
  v_dados(v_dados.last()).vr_nrctremp := 115126;
  v_dados(v_dados.last()).vr_vllanmto := 20.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17198879;
  v_dados(v_dados.last()).vr_nrctremp := 126390;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17268222;
  v_dados(v_dados.last()).vr_nrctremp := 127976;
  v_dados(v_dados.last()).vr_vllanmto := 11.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17269890;
  v_dados(v_dados.last()).vr_nrctremp := 113204;
  v_dados(v_dados.last()).vr_vllanmto := 54.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17387094;
  v_dados(v_dados.last()).vr_nrctremp := 116447;
  v_dados(v_dados.last()).vr_vllanmto := 20.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17388295;
  v_dados(v_dados.last()).vr_nrctremp := 113599;
  v_dados(v_dados.last()).vr_vllanmto := 35.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17416159;
  v_dados(v_dados.last()).vr_nrctremp := 113894;
  v_dados(v_dados.last()).vr_vllanmto := 11.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17435854;
  v_dados(v_dados.last()).vr_nrctremp := 114185;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17463688;
  v_dados(v_dados.last()).vr_nrctremp := 115519;
  v_dados(v_dados.last()).vr_vllanmto := 17.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17485789;
  v_dados(v_dados.last()).vr_nrctremp := 114959;
  v_dados(v_dados.last()).vr_vllanmto := 25.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17486378;
  v_dados(v_dados.last()).vr_nrctremp := 115753;
  v_dados(v_dados.last()).vr_vllanmto := 40.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17504015;
  v_dados(v_dados.last()).vr_nrctremp := 114979;
  v_dados(v_dados.last()).vr_vllanmto := 21.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17570190;
  v_dados(v_dados.last()).vr_nrctremp := 115949;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17648408;
  v_dados(v_dados.last()).vr_nrctremp := 116627;
  v_dados(v_dados.last()).vr_vllanmto := 22.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17650500;
  v_dados(v_dados.last()).vr_nrctremp := 118437;
  v_dados(v_dados.last()).vr_vllanmto := 110.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17650607;
  v_dados(v_dados.last()).vr_nrctremp := 116640;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17737486;
  v_dados(v_dados.last()).vr_nrctremp := 117966;
  v_dados(v_dados.last()).vr_vllanmto := 13.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17744059;
  v_dados(v_dados.last()).vr_nrctremp := 118404;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17767261;
  v_dados(v_dados.last()).vr_nrctremp := 118947;
  v_dados(v_dados.last()).vr_vllanmto := 15.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17810132;
  v_dados(v_dados.last()).vr_nrctremp := 119290;
  v_dados(v_dados.last()).vr_vllanmto := 11.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17831105;
  v_dados(v_dados.last()).vr_nrctremp := 120292;
  v_dados(v_dados.last()).vr_vllanmto := 33.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17950031;
  v_dados(v_dados.last()).vr_nrctremp := 123183;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 17957567;
  v_dados(v_dados.last()).vr_nrctremp := 122637;
  v_dados(v_dados.last()).vr_vllanmto := 12.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18105629;
  v_dados(v_dados.last()).vr_nrctremp := 123963;
  v_dados(v_dados.last()).vr_vllanmto := 25.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18204830;
  v_dados(v_dados.last()).vr_nrctremp := 129451;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18238920;
  v_dados(v_dados.last()).vr_nrctremp := 129686;
  v_dados(v_dados.last()).vr_vllanmto := 18.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18253091;
  v_dados(v_dados.last()).vr_nrctremp := 125761;
  v_dados(v_dados.last()).vr_vllanmto := 21.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18260691;
  v_dados(v_dados.last()).vr_nrctremp := 126212;
  v_dados(v_dados.last()).vr_vllanmto := 11.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18282334;
  v_dados(v_dados.last()).vr_nrctremp := 125829;
  v_dados(v_dados.last()).vr_vllanmto := 20.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18287980;
  v_dados(v_dados.last()).vr_nrctremp := 126574;
  v_dados(v_dados.last()).vr_vllanmto := 18.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18351972;
  v_dados(v_dados.last()).vr_nrctremp := 127269;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18479081;
  v_dados(v_dados.last()).vr_nrctremp := 128967;
  v_dados(v_dados.last()).vr_vllanmto := 39.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18509576;
  v_dados(v_dados.last()).vr_nrctremp := 129123;
  v_dados(v_dados.last()).vr_vllanmto := 16.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18511775;
  v_dados(v_dados.last()).vr_nrctremp := 129168;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18512291;
  v_dados(v_dados.last()).vr_nrctremp := 129281;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18553834;
  v_dados(v_dados.last()).vr_nrctremp := 129776;
  v_dados(v_dados.last()).vr_vllanmto := 15.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18556817;
  v_dados(v_dados.last()).vr_nrctremp := 129890;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18577113;
  v_dados(v_dados.last()).vr_nrctremp := 131404;
  v_dados(v_dados.last()).vr_vllanmto := 11.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18612849;
  v_dados(v_dados.last()).vr_nrctremp := 130973;
  v_dados(v_dados.last()).vr_vllanmto := 13.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18628338;
  v_dados(v_dados.last()).vr_nrctremp := 132176;
  v_dados(v_dados.last()).vr_vllanmto := 21.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18676456;
  v_dados(v_dados.last()).vr_nrctremp := 131922;
  v_dados(v_dados.last()).vr_vllanmto := 10.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 18738028;
  v_dados(v_dados.last()).vr_nrctremp := 132869;
  v_dados(v_dados.last()).vr_vllanmto := 10.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 128830;
  v_dados(v_dados.last()).vr_nrctremp := 73341;
  v_dados(v_dados.last()).vr_vllanmto := 21801.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 128830;
  v_dados(v_dados.last()).vr_nrctremp := 83688;
  v_dados(v_dados.last()).vr_vllanmto := 7233.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 160695;
  v_dados(v_dados.last()).vr_nrctremp := 79313;
  v_dados(v_dados.last()).vr_vllanmto := 12.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 162256;
  v_dados(v_dados.last()).vr_nrctremp := 107161;
  v_dados(v_dados.last()).vr_vllanmto := 34.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 188239;
  v_dados(v_dados.last()).vr_nrctremp := 85134;
  v_dados(v_dados.last()).vr_vllanmto := 22.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 227552;
  v_dados(v_dados.last()).vr_nrctremp := 92894;
  v_dados(v_dados.last()).vr_vllanmto := 37.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 260657;
  v_dados(v_dados.last()).vr_nrctremp := 107217;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 313181;
  v_dados(v_dados.last()).vr_nrctremp := 109032;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 314226;
  v_dados(v_dados.last()).vr_nrctremp := 95461;
  v_dados(v_dados.last()).vr_vllanmto := 13.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 338630;
  v_dados(v_dados.last()).vr_nrctremp := 103790;
  v_dados(v_dados.last()).vr_vllanmto := 10142.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 354180;
  v_dados(v_dados.last()).vr_nrctremp := 70257;
  v_dados(v_dados.last()).vr_vllanmto := 14.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 387770;
  v_dados(v_dados.last()).vr_nrctremp := 85855;
  v_dados(v_dados.last()).vr_vllanmto := 1224.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 407046;
  v_dados(v_dados.last()).vr_nrctremp := 101796;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 426393;
  v_dados(v_dados.last()).vr_nrctremp := 75628;
  v_dados(v_dados.last()).vr_vllanmto := 10.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 438391;
  v_dados(v_dados.last()).vr_nrctremp := 86797;
  v_dados(v_dados.last()).vr_vllanmto := 31.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 446866;
  v_dados(v_dados.last()).vr_nrctremp := 91552;
  v_dados(v_dados.last()).vr_vllanmto := 12.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501778;
  v_dados(v_dados.last()).vr_nrctremp := 91224;
  v_dados(v_dados.last()).vr_vllanmto := 5022.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506117;
  v_dados(v_dados.last()).vr_nrctremp := 93232;
  v_dados(v_dados.last()).vr_vllanmto := 21.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 524298;
  v_dados(v_dados.last()).vr_nrctremp := 106902;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 527610;
  v_dados(v_dados.last()).vr_nrctremp := 91460;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 529281;
  v_dados(v_dados.last()).vr_nrctremp := 96860;
  v_dados(v_dados.last()).vr_vllanmto := 2263.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 529443;
  v_dados(v_dados.last()).vr_nrctremp := 102499;
  v_dados(v_dados.last()).vr_vllanmto := 11.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 543926;
  v_dados(v_dados.last()).vr_nrctremp := 87566;
  v_dados(v_dados.last()).vr_vllanmto := 15.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 549460;
  v_dados(v_dados.last()).vr_nrctremp := 81619;
  v_dados(v_dados.last()).vr_vllanmto := 2667.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 563030;
  v_dados(v_dados.last()).vr_nrctremp := 88791;
  v_dados(v_dados.last()).vr_vllanmto := 21.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 587672;
  v_dados(v_dados.last()).vr_nrctremp := 98363;
  v_dados(v_dados.last()).vr_vllanmto := 80.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 14503379;
  v_dados(v_dados.last()).vr_nrctremp := 104121;
  v_dados(v_dados.last()).vr_vllanmto := 12.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 14922754;
  v_dados(v_dados.last()).vr_nrctremp := 100566;
  v_dados(v_dados.last()).vr_vllanmto := 16.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15155455;
  v_dados(v_dados.last()).vr_nrctremp := 101557;
  v_dados(v_dados.last()).vr_vllanmto := 17.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15242617;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 1939.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15375641;
  v_dados(v_dados.last()).vr_nrctremp := 86265;
  v_dados(v_dados.last()).vr_vllanmto := 21571.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15812723;
  v_dados(v_dados.last()).vr_nrctremp := 82593;
  v_dados(v_dados.last()).vr_vllanmto := 55.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16239539;
  v_dados(v_dados.last()).vr_nrctremp := 89734;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16324447;
  v_dados(v_dados.last()).vr_nrctremp := 90822;
  v_dados(v_dados.last()).vr_vllanmto := 55.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16542088;
  v_dados(v_dados.last()).vr_nrctremp := 92191;
  v_dados(v_dados.last()).vr_vllanmto := 62.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16706188;
  v_dados(v_dados.last()).vr_nrctremp := 97427;
  v_dados(v_dados.last()).vr_vllanmto := 26.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 16887891;
  v_dados(v_dados.last()).vr_nrctremp := 99136;
  v_dados(v_dados.last()).vr_vllanmto := 13.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17107393;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 99.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17107920;
  v_dados(v_dados.last()).vr_nrctremp := 96028;
  v_dados(v_dados.last()).vr_vllanmto := 11.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17112761;
  v_dados(v_dados.last()).vr_nrctremp := 108112;
  v_dados(v_dados.last()).vr_vllanmto := 23.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17166900;
  v_dados(v_dados.last()).vr_nrctremp := 103578;
  v_dados(v_dados.last()).vr_vllanmto := 10.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17239184;
  v_dados(v_dados.last()).vr_nrctremp := 90531;
  v_dados(v_dados.last()).vr_vllanmto := 133.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17351669;
  v_dados(v_dados.last()).vr_nrctremp := 98969;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17569257;
  v_dados(v_dados.last()).vr_nrctremp := 99645;
  v_dados(v_dados.last()).vr_vllanmto := 27.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17682282;
  v_dados(v_dados.last()).vr_nrctremp := 95649;
  v_dados(v_dados.last()).vr_vllanmto := 865.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17962544;
  v_dados(v_dados.last()).vr_nrctremp := 98697;
  v_dados(v_dados.last()).vr_vllanmto := 27.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 3000;
  v_dados(v_dados.last()).vr_nrctremp := 394114;
  v_dados(v_dados.last()).vr_vllanmto := 23.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 5371;
  v_dados(v_dados.last()).vr_nrctremp := 179380;
  v_dados(v_dados.last()).vr_vllanmto := 105.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 5371;
  v_dados(v_dados.last()).vr_nrctremp := 339054;
  v_dados(v_dados.last()).vr_vllanmto := 72.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14850;
  v_dados(v_dados.last()).vr_nrctremp := 388478;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15156;
  v_dados(v_dados.last()).vr_nrctremp := 435025;
  v_dados(v_dados.last()).vr_vllanmto := 40.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17485;
  v_dados(v_dados.last()).vr_nrctremp := 392051;
  v_dados(v_dados.last()).vr_vllanmto := 17.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17485;
  v_dados(v_dados.last()).vr_nrctremp := 440292;
  v_dados(v_dados.last()).vr_vllanmto := 16.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 19470;
  v_dados(v_dados.last()).vr_nrctremp := 320518;
  v_dados(v_dados.last()).vr_vllanmto := 11.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 50180;
  v_dados(v_dados.last()).vr_nrctremp := 353542;
  v_dados(v_dados.last()).vr_vllanmto := 30.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 57533;
  v_dados(v_dados.last()).vr_nrctremp := 309787;
  v_dados(v_dados.last()).vr_vllanmto := 35.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 62782;
  v_dados(v_dados.last()).vr_nrctremp := 328300;
  v_dados(v_dados.last()).vr_vllanmto := 31.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 88064;
  v_dados(v_dados.last()).vr_nrctremp := 364198;
  v_dados(v_dados.last()).vr_vllanmto := 12.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 98205;
  v_dados(v_dados.last()).vr_nrctremp := 334391;
  v_dados(v_dados.last()).vr_vllanmto := 27.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 133264;
  v_dados(v_dados.last()).vr_nrctremp := 197299;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 133264;
  v_dados(v_dados.last()).vr_nrctremp := 393151;
  v_dados(v_dados.last()).vr_vllanmto := 38.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 149055;
  v_dados(v_dados.last()).vr_nrctremp := 380787;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 149055;
  v_dados(v_dados.last()).vr_nrctremp := 441636;
  v_dados(v_dados.last()).vr_vllanmto := 19.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 153427;
  v_dados(v_dados.last()).vr_nrctremp := 384040;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 164372;
  v_dados(v_dados.last()).vr_nrctremp := 436305;
  v_dados(v_dados.last()).vr_vllanmto := 25.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 196827;
  v_dados(v_dados.last()).vr_nrctremp := 343231;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 208043;
  v_dados(v_dados.last()).vr_nrctremp := 439036;
  v_dados(v_dados.last()).vr_vllanmto := 26.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 210960;
  v_dados(v_dados.last()).vr_nrctremp := 287253;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 227943;
  v_dados(v_dados.last()).vr_nrctremp := 304044;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 235946;
  v_dados(v_dados.last()).vr_nrctremp := 318809;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 260835;
  v_dados(v_dados.last()).vr_nrctremp := 358054;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 275913;
  v_dados(v_dados.last()).vr_nrctremp := 162805;
  v_dados(v_dados.last()).vr_vllanmto := 341.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 309311;
  v_dados(v_dados.last()).vr_nrctremp := 341377;
  v_dados(v_dados.last()).vr_vllanmto := 10.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 319171;
  v_dados(v_dados.last()).vr_nrctremp := 353004;
  v_dados(v_dados.last()).vr_vllanmto := 14.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 345180;
  v_dados(v_dados.last()).vr_nrctremp := 358595;
  v_dados(v_dados.last()).vr_vllanmto := 12.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 348082;
  v_dados(v_dados.last()).vr_nrctremp := 339377;
  v_dados(v_dados.last()).vr_vllanmto := 31.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 351725;
  v_dados(v_dados.last()).vr_nrctremp := 354164;
  v_dados(v_dados.last()).vr_vllanmto := 10.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 361143;
  v_dados(v_dados.last()).vr_nrctremp := 330933;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 371912;
  v_dados(v_dados.last()).vr_nrctremp := 424607;
  v_dados(v_dados.last()).vr_vllanmto := 19057.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 371939;
  v_dados(v_dados.last()).vr_nrctremp := 251597;
  v_dados(v_dados.last()).vr_vllanmto := 13.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 406325;
  v_dados(v_dados.last()).vr_nrctremp := 376966;
  v_dados(v_dados.last()).vr_vllanmto := 27907.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 406325;
  v_dados(v_dados.last()).vr_nrctremp := 430756;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 415723;
  v_dados(v_dados.last()).vr_nrctremp := 339020;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 415960;
  v_dados(v_dados.last()).vr_nrctremp := 355454;
  v_dados(v_dados.last()).vr_vllanmto := 32.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 424536;
  v_dados(v_dados.last()).vr_nrctremp := 204085;
  v_dados(v_dados.last()).vr_vllanmto := 12.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 444537;
  v_dados(v_dados.last()).vr_nrctremp := 327557;
  v_dados(v_dados.last()).vr_vllanmto := 19.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 456772;
  v_dados(v_dados.last()).vr_nrctremp := 400086;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 461644;
  v_dados(v_dados.last()).vr_nrctremp := 389889;
  v_dados(v_dados.last()).vr_vllanmto := 12.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 463868;
  v_dados(v_dados.last()).vr_nrctremp := 396365;
  v_dados(v_dados.last()).vr_vllanmto := 33.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 466522;
  v_dados(v_dados.last()).vr_nrctremp := 327048;
  v_dados(v_dados.last()).vr_vllanmto := 30.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 470937;
  v_dados(v_dados.last()).vr_nrctremp := 422275;
  v_dados(v_dados.last()).vr_vllanmto := 19.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 498050;
  v_dados(v_dados.last()).vr_nrctremp := 340569;
  v_dados(v_dados.last()).vr_vllanmto := 553.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 501573;
  v_dados(v_dados.last()).vr_nrctremp := 359321;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 506370;
  v_dados(v_dados.last()).vr_nrctremp := 179782;
  v_dados(v_dados.last()).vr_vllanmto := 444.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 518298;
  v_dados(v_dados.last()).vr_nrctremp := 320766;
  v_dados(v_dados.last()).vr_vllanmto := 16.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 529818;
  v_dados(v_dados.last()).vr_nrctremp := 402365;
  v_dados(v_dados.last()).vr_vllanmto := 14.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 541290;
  v_dados(v_dados.last()).vr_nrctremp := 428491;
  v_dados(v_dados.last()).vr_vllanmto := 39.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 549428;
  v_dados(v_dados.last()).vr_nrctremp := 292376;
  v_dados(v_dados.last()).vr_vllanmto := 15.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 550264;
  v_dados(v_dados.last()).vr_nrctremp := 342784;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 555371;
  v_dados(v_dados.last()).vr_nrctremp := 410136;
  v_dados(v_dados.last()).vr_vllanmto := 11.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 566080;
  v_dados(v_dados.last()).vr_nrctremp := 291453;
  v_dados(v_dados.last()).vr_vllanmto := 7908.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 570214;
  v_dados(v_dados.last()).vr_nrctremp := 289844;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 580171;
  v_dados(v_dados.last()).vr_nrctremp := 410519;
  v_dados(v_dados.last()).vr_vllanmto := 13.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 589977;
  v_dados(v_dados.last()).vr_nrctremp := 208448;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 608378;
  v_dados(v_dados.last()).vr_nrctremp := 440344;
  v_dados(v_dados.last()).vr_vllanmto := 33.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 611999;
  v_dados(v_dados.last()).vr_nrctremp := 192831;
  v_dados(v_dados.last()).vr_vllanmto := 8464.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 617458;
  v_dados(v_dados.last()).vr_nrctremp := 169526;
  v_dados(v_dados.last()).vr_vllanmto := 10.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 403195;
  v_dados(v_dados.last()).vr_vllanmto := 20.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 620408;
  v_dados(v_dados.last()).vr_nrctremp := 396342;
  v_dados(v_dados.last()).vr_vllanmto := 42.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 621595;
  v_dados(v_dados.last()).vr_nrctremp := 404040;
  v_dados(v_dados.last()).vr_vllanmto := 10.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 626376;
  v_dados(v_dados.last()).vr_nrctremp := 263358;
  v_dados(v_dados.last()).vr_vllanmto := 7014.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 640310;
  v_dados(v_dados.last()).vr_nrctremp := 306569;
  v_dados(v_dados.last()).vr_vllanmto := 26.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 647632;
  v_dados(v_dados.last()).vr_nrctremp := 312362;
  v_dados(v_dados.last()).vr_vllanmto := 14.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 647632;
  v_dados(v_dados.last()).vr_nrctremp := 422073;
  v_dados(v_dados.last()).vr_vllanmto := 15.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 649368;
  v_dados(v_dados.last()).vr_nrctremp := 352742;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 667820;
  v_dados(v_dados.last()).vr_nrctremp := 432051;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 671746;
  v_dados(v_dados.last()).vr_nrctremp := 410800;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 676160;
  v_dados(v_dados.last()).vr_nrctremp := 377031;
  v_dados(v_dados.last()).vr_vllanmto := 13.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 678309;
  v_dados(v_dados.last()).vr_nrctremp := 161727;
  v_dados(v_dados.last()).vr_vllanmto := 27.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 698741;
  v_dados(v_dados.last()).vr_nrctremp := 433175;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 699080;
  v_dados(v_dados.last()).vr_nrctremp := 266458;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 721123;
  v_dados(v_dados.last()).vr_nrctremp := 381380;
  v_dados(v_dados.last()).vr_vllanmto := 20.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 725161;
  v_dados(v_dados.last()).vr_nrctremp := 326127;
  v_dados(v_dados.last()).vr_vllanmto := 11.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 726028;
  v_dados(v_dados.last()).vr_nrctremp := 158732;
  v_dados(v_dados.last()).vr_vllanmto := 51.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729205;
  v_dados(v_dados.last()).vr_nrctremp := 309697;
  v_dados(v_dados.last()).vr_vllanmto := 348.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729582;
  v_dados(v_dados.last()).vr_nrctremp := 237608;
  v_dados(v_dados.last()).vr_vllanmto := 2401.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 755583;
  v_dados(v_dados.last()).vr_nrctremp := 331019;
  v_dados(v_dados.last()).vr_vllanmto := 18.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 779792;
  v_dados(v_dados.last()).vr_nrctremp := 432549;
  v_dados(v_dados.last()).vr_vllanmto := 18.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 813400;
  v_dados(v_dados.last()).vr_nrctremp := 408332;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 816841;
  v_dados(v_dados.last()).vr_nrctremp := 387685;
  v_dados(v_dados.last()).vr_vllanmto := 12.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 823023;
  v_dados(v_dados.last()).vr_nrctremp := 213460;
  v_dados(v_dados.last()).vr_vllanmto := 571.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 832170;
  v_dados(v_dados.last()).vr_nrctremp := 202073;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 858285;
  v_dados(v_dados.last()).vr_nrctremp := 341906;
  v_dados(v_dados.last()).vr_vllanmto := 18.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 859648;
  v_dados(v_dados.last()).vr_nrctremp := 420954;
  v_dados(v_dados.last()).vr_vllanmto := 20.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 904929;
  v_dados(v_dados.last()).vr_nrctremp := 439924;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 905232;
  v_dados(v_dados.last()).vr_nrctremp := 364086;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 911003;
  v_dados(v_dados.last()).vr_nrctremp := 432919;
  v_dados(v_dados.last()).vr_vllanmto := 44.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 920185;
  v_dados(v_dados.last()).vr_nrctremp := 416025;
  v_dados(v_dados.last()).vr_vllanmto := 770.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 920380;
  v_dados(v_dados.last()).vr_nrctremp := 432140;
  v_dados(v_dados.last()).vr_vllanmto := 48.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 924229;
  v_dados(v_dados.last()).vr_nrctremp := 280692;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 924296;
  v_dados(v_dados.last()).vr_nrctremp := 366422;
  v_dados(v_dados.last()).vr_vllanmto := 19.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 929310;
  v_dados(v_dados.last()).vr_nrctremp := 374461;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 934402;
  v_dados(v_dados.last()).vr_nrctremp := 278165;
  v_dados(v_dados.last()).vr_vllanmto := 20.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 934615;
  v_dados(v_dados.last()).vr_nrctremp := 269482;
  v_dados(v_dados.last()).vr_vllanmto := 69.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 936499;
  v_dados(v_dados.last()).vr_nrctremp := 263351;
  v_dados(v_dados.last()).vr_vllanmto := 37.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 936499;
  v_dados(v_dados.last()).vr_nrctremp := 270772;
  v_dados(v_dados.last()).vr_vllanmto := 36.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 936863;
  v_dados(v_dados.last()).vr_nrctremp := 366483;
  v_dados(v_dados.last()).vr_vllanmto := 21002.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 952923;
  v_dados(v_dados.last()).vr_nrctremp := 416630;
  v_dados(v_dados.last()).vr_vllanmto := 19.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 956139;
  v_dados(v_dados.last()).vr_nrctremp := 348788;
  v_dados(v_dados.last()).vr_vllanmto := 288.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 959367;
  v_dados(v_dados.last()).vr_nrctremp := 249604;
  v_dados(v_dados.last()).vr_vllanmto := 21.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 961337;
  v_dados(v_dados.last()).vr_nrctremp := 414458;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 962180;
  v_dados(v_dados.last()).vr_nrctremp := 380720;
  v_dados(v_dados.last()).vr_vllanmto := 19.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 967572;
  v_dados(v_dados.last()).vr_nrctremp := 357161;
  v_dados(v_dados.last()).vr_vllanmto := 19.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 969508;
  v_dados(v_dados.last()).vr_nrctremp := 322654;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 972355;
  v_dados(v_dados.last()).vr_nrctremp := 423960;
  v_dados(v_dados.last()).vr_vllanmto := 39.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 972355;
  v_dados(v_dados.last()).vr_nrctremp := 442649;
  v_dados(v_dados.last()).vr_vllanmto := 39.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 976121;
  v_dados(v_dados.last()).vr_nrctremp := 368801;
  v_dados(v_dados.last()).vr_vllanmto := 15.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 984477;
  v_dados(v_dados.last()).vr_nrctremp := 352169;
  v_dados(v_dados.last()).vr_vllanmto := 24.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 987581;
  v_dados(v_dados.last()).vr_nrctremp := 359973;
  v_dados(v_dados.last()).vr_vllanmto := 4963.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 1019201;
  v_dados(v_dados.last()).vr_nrctremp := 369887;
  v_dados(v_dados.last()).vr_vllanmto := 15.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 1019961;
  v_dados(v_dados.last()).vr_nrctremp := 422978;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 1027328;
  v_dados(v_dados.last()).vr_nrctremp := 433538;
  v_dados(v_dados.last()).vr_vllanmto := 13.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 13999168;
  v_dados(v_dados.last()).vr_nrctremp := 357395;
  v_dados(v_dados.last()).vr_vllanmto := 17.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14040468;
  v_dados(v_dados.last()).vr_nrctremp := 320381;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14090880;
  v_dados(v_dados.last()).vr_nrctremp := 199550;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14090880;
  v_dados(v_dados.last()).vr_nrctremp := 290499;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14090880;
  v_dados(v_dados.last()).vr_nrctremp := 356668;
  v_dados(v_dados.last()).vr_vllanmto := 52.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14103176;
  v_dados(v_dados.last()).vr_nrctremp := 197303;
  v_dados(v_dados.last()).vr_vllanmto := 11.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14240149;
  v_dados(v_dados.last()).vr_nrctremp := 381166;
  v_dados(v_dados.last()).vr_vllanmto := 6259.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14292750;
  v_dados(v_dados.last()).vr_nrctremp := 372611;
  v_dados(v_dados.last()).vr_vllanmto := 13.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14292750;
  v_dados(v_dados.last()).vr_nrctremp := 395358;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14318458;
  v_dados(v_dados.last()).vr_nrctremp := 370081;
  v_dados(v_dados.last()).vr_vllanmto := 21.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14821850;
  v_dados(v_dados.last()).vr_nrctremp := 306862;
  v_dados(v_dados.last()).vr_vllanmto := 12.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14902044;
  v_dados(v_dados.last()).vr_nrctremp := 304761;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14948591;
  v_dados(v_dados.last()).vr_nrctremp := 316695;
  v_dados(v_dados.last()).vr_vllanmto := 11.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 14968185;
  v_dados(v_dados.last()).vr_nrctremp := 274419;
  v_dados(v_dados.last()).vr_vllanmto := 19.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15089940;
  v_dados(v_dados.last()).vr_nrctremp := 256236;
  v_dados(v_dados.last()).vr_vllanmto := 22.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15089940;
  v_dados(v_dados.last()).vr_nrctremp := 301181;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15114163;
  v_dados(v_dados.last()).vr_nrctremp := 301193;
  v_dados(v_dados.last()).vr_vllanmto := 15.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15128792;
  v_dados(v_dados.last()).vr_nrctremp := 398471;
  v_dados(v_dados.last()).vr_vllanmto := 20.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15159779;
  v_dados(v_dados.last()).vr_nrctremp := 397977;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15217531;
  v_dados(v_dados.last()).vr_nrctremp := 370620;
  v_dados(v_dados.last()).vr_vllanmto := 20.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15292460;
  v_dados(v_dados.last()).vr_nrctremp := 417795;
  v_dados(v_dados.last()).vr_vllanmto := 52.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15295273;
  v_dados(v_dados.last()).vr_nrctremp := 402086;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15316122;
  v_dados(v_dados.last()).vr_nrctremp := 318693;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15316734;
  v_dados(v_dados.last()).vr_nrctremp := 317120;
  v_dados(v_dados.last()).vr_vllanmto := 3279.63;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15317463;
  v_dados(v_dados.last()).vr_nrctremp := 328523;
  v_dados(v_dados.last()).vr_vllanmto := 38.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15321240;
  v_dados(v_dados.last()).vr_nrctremp := 418711;
  v_dados(v_dados.last()).vr_vllanmto := 15.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15335267;
  v_dados(v_dados.last()).vr_nrctremp := 345016;
  v_dados(v_dados.last()).vr_vllanmto := 12.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15335267;
  v_dados(v_dados.last()).vr_nrctremp := 394030;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15416313;
  v_dados(v_dados.last()).vr_nrctremp := 269786;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15492540;
  v_dados(v_dados.last()).vr_nrctremp := 441922;
  v_dados(v_dados.last()).vr_vllanmto := 23.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15561275;
  v_dados(v_dados.last()).vr_nrctremp := 277190;
  v_dados(v_dados.last()).vr_vllanmto := 10.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15561275;
  v_dados(v_dados.last()).vr_nrctremp := 281591;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15674762;
  v_dados(v_dados.last()).vr_nrctremp := 353427;
  v_dados(v_dados.last()).vr_vllanmto := 15.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15715299;
  v_dados(v_dados.last()).vr_nrctremp := 321102;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15852849;
  v_dados(v_dados.last()).vr_nrctremp := 326444;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15878805;
  v_dados(v_dados.last()).vr_nrctremp := 295261;
  v_dados(v_dados.last()).vr_vllanmto := 13.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15884473;
  v_dados(v_dados.last()).vr_nrctremp := 304703;
  v_dados(v_dados.last()).vr_vllanmto := 31.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15936465;
  v_dados(v_dados.last()).vr_nrctremp := 300274;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15963179;
  v_dados(v_dados.last()).vr_nrctremp := 300118;
  v_dados(v_dados.last()).vr_vllanmto := 11.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15966720;
  v_dados(v_dados.last()).vr_nrctremp := 300141;
  v_dados(v_dados.last()).vr_vllanmto := 15.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15977307;
  v_dados(v_dados.last()).vr_nrctremp := 300448;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16015118;
  v_dados(v_dados.last()).vr_nrctremp := 335393;
  v_dados(v_dados.last()).vr_vllanmto := 15.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16018699;
  v_dados(v_dados.last()).vr_nrctremp := 303062;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16045165;
  v_dados(v_dados.last()).vr_nrctremp := 310680;
  v_dados(v_dados.last()).vr_vllanmto := 19.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16051912;
  v_dados(v_dados.last()).vr_nrctremp := 420181;
  v_dados(v_dados.last()).vr_vllanmto := 60.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16060644;
  v_dados(v_dados.last()).vr_nrctremp := 312606;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16087569;
  v_dados(v_dados.last()).vr_nrctremp := 312066;
  v_dados(v_dados.last()).vr_vllanmto := 12235.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16096525;
  v_dados(v_dados.last()).vr_nrctremp := 308323;
  v_dados(v_dados.last()).vr_vllanmto := 17.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16100158;
  v_dados(v_dados.last()).vr_nrctremp := 307918;
  v_dados(v_dados.last()).vr_vllanmto := 21.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16111982;
  v_dados(v_dados.last()).vr_nrctremp := 419529;
  v_dados(v_dados.last()).vr_vllanmto := 28.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16112580;
  v_dados(v_dados.last()).vr_nrctremp := 311955;
  v_dados(v_dados.last()).vr_vllanmto := 15.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16125673;
  v_dados(v_dados.last()).vr_nrctremp := 309197;
  v_dados(v_dados.last()).vr_vllanmto := 4409.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16137540;
  v_dados(v_dados.last()).vr_nrctremp := 438198;
  v_dados(v_dados.last()).vr_vllanmto := 47.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16139593;
  v_dados(v_dados.last()).vr_nrctremp := 309414;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16145135;
  v_dados(v_dados.last()).vr_nrctremp := 309667;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16152867;
  v_dados(v_dados.last()).vr_nrctremp := 310012;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16155149;
  v_dados(v_dados.last()).vr_nrctremp := 310112;
  v_dados(v_dados.last()).vr_vllanmto := 17.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16159977;
  v_dados(v_dados.last()).vr_nrctremp := 310331;
  v_dados(v_dados.last()).vr_vllanmto := 13.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16164296;
  v_dados(v_dados.last()).vr_nrctremp := 310722;
  v_dados(v_dados.last()).vr_vllanmto := 20.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16170644;
  v_dados(v_dados.last()).vr_nrctremp := 310696;
  v_dados(v_dados.last()).vr_vllanmto := 23.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16172140;
  v_dados(v_dados.last()).vr_nrctremp := 433348;
  v_dados(v_dados.last()).vr_vllanmto := 19.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16180879;
  v_dados(v_dados.last()).vr_nrctremp := 311317;
  v_dados(v_dados.last()).vr_vllanmto := 23.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16195680;
  v_dados(v_dados.last()).vr_nrctremp := 437230;
  v_dados(v_dados.last()).vr_vllanmto := 27.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16195981;
  v_dados(v_dados.last()).vr_nrctremp := 312163;
  v_dados(v_dados.last()).vr_vllanmto := 22.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16196449;
  v_dados(v_dados.last()).vr_nrctremp := 435795;
  v_dados(v_dados.last()).vr_vllanmto := 11.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16200365;
  v_dados(v_dados.last()).vr_nrctremp := 375365;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16210115;
  v_dados(v_dados.last()).vr_nrctremp := 312722;
  v_dados(v_dados.last()).vr_vllanmto := 18.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16230310;
  v_dados(v_dados.last()).vr_nrctremp := 313803;
  v_dados(v_dados.last()).vr_vllanmto := 23.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16231759;
  v_dados(v_dados.last()).vr_nrctremp := 313821;
  v_dados(v_dados.last()).vr_vllanmto := 29.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16238281;
  v_dados(v_dados.last()).vr_nrctremp := 314032;
  v_dados(v_dados.last()).vr_vllanmto := 48.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16262204;
  v_dados(v_dados.last()).vr_nrctremp := 315124;
  v_dados(v_dados.last()).vr_vllanmto := 21.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16262581;
  v_dados(v_dados.last()).vr_nrctremp := 429101;
  v_dados(v_dados.last()).vr_vllanmto := 43.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16263626;
  v_dados(v_dados.last()).vr_nrctremp := 315121;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16265980;
  v_dados(v_dados.last()).vr_nrctremp := 315190;
  v_dados(v_dados.last()).vr_vllanmto := 139.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16282990;
  v_dados(v_dados.last()).vr_nrctremp := 316148;
  v_dados(v_dados.last()).vr_vllanmto := 19.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16284259;
  v_dados(v_dados.last()).vr_nrctremp := 316174;
  v_dados(v_dados.last()).vr_vllanmto := 18.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16284488;
  v_dados(v_dados.last()).vr_nrctremp := 360629;
  v_dados(v_dados.last()).vr_vllanmto := 10.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16287045;
  v_dados(v_dados.last()).vr_nrctremp := 316373;
  v_dados(v_dados.last()).vr_vllanmto := 19.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16289277;
  v_dados(v_dados.last()).vr_nrctremp := 316440;
  v_dados(v_dados.last()).vr_vllanmto := 14.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16294220;
  v_dados(v_dados.last()).vr_nrctremp := 316675;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16297075;
  v_dados(v_dados.last()).vr_nrctremp := 316738;
  v_dados(v_dados.last()).vr_vllanmto := 10.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 326663;
  v_dados(v_dados.last()).vr_vllanmto := 212.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301200;
  v_dados(v_dados.last()).vr_nrctremp := 396174;
  v_dados(v_dados.last()).vr_vllanmto := 15.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301404;
  v_dados(v_dados.last()).vr_nrctremp := 399503;
  v_dados(v_dados.last()).vr_vllanmto := 14.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16301684;
  v_dados(v_dados.last()).vr_nrctremp := 404161;
  v_dados(v_dados.last()).vr_vllanmto := 14.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16307291;
  v_dados(v_dados.last()).vr_nrctremp := 329190;
  v_dados(v_dados.last()).vr_vllanmto := 13.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16308786;
  v_dados(v_dados.last()).vr_nrctremp := 318661;
  v_dados(v_dados.last()).vr_vllanmto := 12.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16313550;
  v_dados(v_dados.last()).vr_nrctremp := 318061;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16313615;
  v_dados(v_dados.last()).vr_nrctremp := 357284;
  v_dados(v_dados.last()).vr_vllanmto := 21.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16320042;
  v_dados(v_dados.last()).vr_nrctremp := 319906;
  v_dados(v_dados.last()).vr_vllanmto := 15.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16350766;
  v_dados(v_dados.last()).vr_nrctremp := 320034;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16364295;
  v_dados(v_dados.last()).vr_nrctremp := 322722;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16368215;
  v_dados(v_dados.last()).vr_nrctremp := 436150;
  v_dados(v_dados.last()).vr_vllanmto := 29.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16368380;
  v_dados(v_dados.last()).vr_nrctremp := 320759;
  v_dados(v_dados.last()).vr_vllanmto := 17.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16372573;
  v_dados(v_dados.last()).vr_nrctremp := 320966;
  v_dados(v_dados.last()).vr_vllanmto := 20.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16378016;
  v_dados(v_dados.last()).vr_nrctremp := 321869;
  v_dados(v_dados.last()).vr_vllanmto := 29.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16380584;
  v_dados(v_dados.last()).vr_nrctremp := 323260;
  v_dados(v_dados.last()).vr_vllanmto := 21.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16388291;
  v_dados(v_dados.last()).vr_nrctremp := 321725;
  v_dados(v_dados.last()).vr_vllanmto := 19.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16397673;
  v_dados(v_dados.last()).vr_nrctremp := 350572;
  v_dados(v_dados.last()).vr_vllanmto := 14.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16397819;
  v_dados(v_dados.last()).vr_nrctremp := 322133;
  v_dados(v_dados.last()).vr_vllanmto := 50.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16401972;
  v_dados(v_dados.last()).vr_nrctremp := 322295;
  v_dados(v_dados.last()).vr_vllanmto := 10.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16402880;
  v_dados(v_dados.last()).vr_nrctremp := 322326;
  v_dados(v_dados.last()).vr_vllanmto := 29.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16405455;
  v_dados(v_dados.last()).vr_nrctremp := 322661;
  v_dados(v_dados.last()).vr_vllanmto := 30.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16405455;
  v_dados(v_dados.last()).vr_nrctremp := 392511;
  v_dados(v_dados.last()).vr_vllanmto := 21.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16408225;
  v_dados(v_dados.last()).vr_nrctremp := 326771;
  v_dados(v_dados.last()).vr_vllanmto := 35.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16413091;
  v_dados(v_dados.last()).vr_nrctremp := 323794;
  v_dados(v_dados.last()).vr_vllanmto := 24.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16423453;
  v_dados(v_dados.last()).vr_nrctremp := 323182;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16444256;
  v_dados(v_dados.last()).vr_nrctremp := 324902;
  v_dados(v_dados.last()).vr_vllanmto := 392.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16456670;
  v_dados(v_dados.last()).vr_nrctremp := 324786;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16457811;
  v_dados(v_dados.last()).vr_nrctremp := 333386;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16469984;
  v_dados(v_dados.last()).vr_nrctremp := 325325;
  v_dados(v_dados.last()).vr_vllanmto := 22.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16480910;
  v_dados(v_dados.last()).vr_nrctremp := 439592;
  v_dados(v_dados.last()).vr_vllanmto := 48.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16488792;
  v_dados(v_dados.last()).vr_nrctremp := 326467;
  v_dados(v_dados.last()).vr_vllanmto := 25.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16491343;
  v_dados(v_dados.last()).vr_nrctremp := 326590;
  v_dados(v_dados.last()).vr_vllanmto := 18.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16493427;
  v_dados(v_dados.last()).vr_nrctremp := 432915;
  v_dados(v_dados.last()).vr_vllanmto := 24.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16498860;
  v_dados(v_dados.last()).vr_nrctremp := 327684;
  v_dados(v_dados.last()).vr_vllanmto := 14.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16504259;
  v_dados(v_dados.last()).vr_nrctremp := 327210;
  v_dados(v_dados.last()).vr_vllanmto := 25.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16505476;
  v_dados(v_dados.last()).vr_nrctremp := 327255;
  v_dados(v_dados.last()).vr_vllanmto := 39.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16518128;
  v_dados(v_dados.last()).vr_nrctremp := 431961;
  v_dados(v_dados.last()).vr_vllanmto := 38.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16539125;
  v_dados(v_dados.last()).vr_nrctremp := 441614;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16547489;
  v_dados(v_dados.last()).vr_nrctremp := 329243;
  v_dados(v_dados.last()).vr_vllanmto := 12.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16549732;
  v_dados(v_dados.last()).vr_nrctremp := 329379;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16551850;
  v_dados(v_dados.last()).vr_nrctremp := 429496;
  v_dados(v_dados.last()).vr_vllanmto := 32612.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16573552;
  v_dados(v_dados.last()).vr_nrctremp := 330687;
  v_dados(v_dados.last()).vr_vllanmto := 34.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16573927;
  v_dados(v_dados.last()).vr_nrctremp := 330678;
  v_dados(v_dados.last()).vr_vllanmto := 21.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16579941;
  v_dados(v_dados.last()).vr_nrctremp := 331638;
  v_dados(v_dados.last()).vr_vllanmto := 13.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16582241;
  v_dados(v_dados.last()).vr_nrctremp := 420742;
  v_dados(v_dados.last()).vr_vllanmto := 29.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16598407;
  v_dados(v_dados.last()).vr_nrctremp := 331616;
  v_dados(v_dados.last()).vr_vllanmto := 18.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16608500;
  v_dados(v_dados.last()).vr_nrctremp := 424620;
  v_dados(v_dados.last()).vr_vllanmto := 16.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16609387;
  v_dados(v_dados.last()).vr_nrctremp := 332548;
  v_dados(v_dados.last()).vr_vllanmto := 1518.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16612337;
  v_dados(v_dados.last()).vr_nrctremp := 332687;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16612710;
  v_dados(v_dados.last()).vr_nrctremp := 333270;
  v_dados(v_dados.last()).vr_vllanmto := 10.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16623576;
  v_dados(v_dados.last()).vr_nrctremp := 424025;
  v_dados(v_dados.last()).vr_vllanmto := 27.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16626397;
  v_dados(v_dados.last()).vr_nrctremp := 333436;
  v_dados(v_dados.last()).vr_vllanmto := 17.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16626729;
  v_dados(v_dados.last()).vr_nrctremp := 429208;
  v_dados(v_dados.last()).vr_vllanmto := 18.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16631331;
  v_dados(v_dados.last()).vr_nrctremp := 377813;
  v_dados(v_dados.last()).vr_vllanmto := 40.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16635744;
  v_dados(v_dados.last()).vr_nrctremp := 333757;
  v_dados(v_dados.last()).vr_vllanmto := 1832.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16638000;
  v_dados(v_dados.last()).vr_nrctremp := 344337;
  v_dados(v_dados.last()).vr_vllanmto := 26.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16642520;
  v_dados(v_dados.last()).vr_nrctremp := 334276;
  v_dados(v_dados.last()).vr_vllanmto := 18.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16644093;
  v_dados(v_dados.last()).vr_nrctremp := 334323;
  v_dados(v_dados.last()).vr_vllanmto := 17.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16656342;
  v_dados(v_dados.last()).vr_nrctremp := 334965;
  v_dados(v_dados.last()).vr_vllanmto := 17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16660706;
  v_dados(v_dados.last()).vr_nrctremp := 335113;
  v_dados(v_dados.last()).vr_vllanmto := 20.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16664000;
  v_dados(v_dados.last()).vr_nrctremp := 377978;
  v_dados(v_dados.last()).vr_vllanmto := 26.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16664124;
  v_dados(v_dados.last()).vr_nrctremp := 335217;
  v_dados(v_dados.last()).vr_vllanmto := 20.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16664272;
  v_dados(v_dados.last()).vr_nrctremp := 420189;
  v_dados(v_dados.last()).vr_vllanmto := 15.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16664558;
  v_dados(v_dados.last()).vr_nrctremp := 335232;
  v_dados(v_dados.last()).vr_vllanmto := 25.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16668618;
  v_dados(v_dados.last()).vr_nrctremp := 335421;
  v_dados(v_dados.last()).vr_vllanmto := 70064.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16676980;
  v_dados(v_dados.last()).vr_nrctremp := 344388;
  v_dados(v_dados.last()).vr_vllanmto := 11.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16685229;
  v_dados(v_dados.last()).vr_nrctremp := 336421;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16685237;
  v_dados(v_dados.last()).vr_nrctremp := 336418;
  v_dados(v_dados.last()).vr_vllanmto := 14.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16698479;
  v_dados(v_dados.last()).vr_nrctremp := 337370;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16698665;
  v_dados(v_dados.last()).vr_nrctremp := 337267;
  v_dados(v_dados.last()).vr_vllanmto := 37602.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16709616;
  v_dados(v_dados.last()).vr_nrctremp := 341925;
  v_dados(v_dados.last()).vr_vllanmto := 616.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16722230;
  v_dados(v_dados.last()).vr_nrctremp := 338532;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16727029;
  v_dados(v_dados.last()).vr_nrctremp := 339072;
  v_dados(v_dados.last()).vr_vllanmto := 44427.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16729927;
  v_dados(v_dados.last()).vr_nrctremp := 374488;
  v_dados(v_dados.last()).vr_vllanmto := 21.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16729927;
  v_dados(v_dados.last()).vr_nrctremp := 383383;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16739884;
  v_dados(v_dados.last()).vr_nrctremp := 339291;
  v_dados(v_dados.last()).vr_vllanmto := 26.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16741390;
  v_dados(v_dados.last()).vr_nrctremp := 339527;
  v_dados(v_dados.last()).vr_vllanmto := 15.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16742974;
  v_dados(v_dados.last()).vr_nrctremp := 351524;
  v_dados(v_dados.last()).vr_vllanmto := 26.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16744594;
  v_dados(v_dados.last()).vr_nrctremp := 376479;
  v_dados(v_dados.last()).vr_vllanmto := 56.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16745965;
  v_dados(v_dados.last()).vr_nrctremp := 339590;
  v_dados(v_dados.last()).vr_vllanmto := 966.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16746520;
  v_dados(v_dados.last()).vr_nrctremp := 339602;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16746830;
  v_dados(v_dados.last()).vr_nrctremp := 339605;
  v_dados(v_dados.last()).vr_vllanmto := 24.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16747143;
  v_dados(v_dados.last()).vr_nrctremp := 441957;
  v_dados(v_dados.last()).vr_vllanmto := 26.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16748085;
  v_dados(v_dados.last()).vr_nrctremp := 339586;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16757564;
  v_dados(v_dados.last()).vr_nrctremp := 391062;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16757882;
  v_dados(v_dados.last()).vr_nrctremp := 413569;
  v_dados(v_dados.last()).vr_vllanmto := 11.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16774671;
  v_dados(v_dados.last()).vr_nrctremp := 393690;
  v_dados(v_dados.last()).vr_vllanmto := 17.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16778154;
  v_dados(v_dados.last()).vr_nrctremp := 344900;
  v_dados(v_dados.last()).vr_vllanmto := 13.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16781988;
  v_dados(v_dados.last()).vr_nrctremp := 400150;
  v_dados(v_dados.last()).vr_vllanmto := 11.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16781988;
  v_dados(v_dados.last()).vr_nrctremp := 401459;
  v_dados(v_dados.last()).vr_vllanmto := 29.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16781988;
  v_dados(v_dados.last()).vr_nrctremp := 401460;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16786610;
  v_dados(v_dados.last()).vr_nrctremp := 348862;
  v_dados(v_dados.last()).vr_vllanmto := 34.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16823257;
  v_dados(v_dados.last()).vr_nrctremp := 344780;
  v_dados(v_dados.last()).vr_vllanmto := 24.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16840798;
  v_dados(v_dados.last()).vr_nrctremp := 354644;
  v_dados(v_dados.last()).vr_vllanmto := 40.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16840798;
  v_dados(v_dados.last()).vr_nrctremp := 357776;
  v_dados(v_dados.last()).vr_vllanmto := 14.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16849051;
  v_dados(v_dados.last()).vr_nrctremp := 374273;
  v_dados(v_dados.last()).vr_vllanmto := 13.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16849051;
  v_dados(v_dados.last()).vr_nrctremp := 424951;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16853148;
  v_dados(v_dados.last()).vr_nrctremp := 344791;
  v_dados(v_dados.last()).vr_vllanmto := 29.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16870425;
  v_dados(v_dados.last()).vr_nrctremp := 420211;
  v_dados(v_dados.last()).vr_vllanmto := 11.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16892119;
  v_dados(v_dados.last()).vr_nrctremp := 348669;
  v_dados(v_dados.last()).vr_vllanmto := 10.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16901428;
  v_dados(v_dados.last()).vr_nrctremp := 347163;
  v_dados(v_dados.last()).vr_vllanmto := 189.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16920082;
  v_dados(v_dados.last()).vr_nrctremp := 439450;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16936264;
  v_dados(v_dados.last()).vr_nrctremp := 423976;
  v_dados(v_dados.last()).vr_vllanmto := 22.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16947886;
  v_dados(v_dados.last()).vr_nrctremp := 349223;
  v_dados(v_dados.last()).vr_vllanmto := 23.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16948890;
  v_dados(v_dados.last()).vr_nrctremp := 349473;
  v_dados(v_dados.last()).vr_vllanmto := 21.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16972015;
  v_dados(v_dados.last()).vr_nrctremp := 351678;
  v_dados(v_dados.last()).vr_vllanmto := 11.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17041805;
  v_dados(v_dados.last()).vr_nrctremp := 389796;
  v_dados(v_dados.last()).vr_vllanmto := 21961.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17044022;
  v_dados(v_dados.last()).vr_nrctremp := 432512;
  v_dados(v_dados.last()).vr_vllanmto := 22.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17057833;
  v_dados(v_dados.last()).vr_nrctremp := 354523;
  v_dados(v_dados.last()).vr_vllanmto := 19.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17060494;
  v_dados(v_dados.last()).vr_nrctremp := 369457;
  v_dados(v_dados.last()).vr_vllanmto := 20.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17064880;
  v_dados(v_dados.last()).vr_nrctremp := 354841;
  v_dados(v_dados.last()).vr_vllanmto := 37.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17072263;
  v_dados(v_dados.last()).vr_nrctremp := 421611;
  v_dados(v_dados.last()).vr_vllanmto := 16.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17083540;
  v_dados(v_dados.last()).vr_nrctremp := 355468;
  v_dados(v_dados.last()).vr_vllanmto := 16.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17089301;
  v_dados(v_dados.last()).vr_nrctremp := 388110;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17099811;
  v_dados(v_dados.last()).vr_nrctremp := 368275;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17100470;
  v_dados(v_dados.last()).vr_nrctremp := 409463;
  v_dados(v_dados.last()).vr_vllanmto := 16.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17110343;
  v_dados(v_dados.last()).vr_nrctremp := 356926;
  v_dados(v_dados.last()).vr_vllanmto := 18.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17126894;
  v_dados(v_dados.last()).vr_nrctremp := 357846;
  v_dados(v_dados.last()).vr_vllanmto := 28.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17136725;
  v_dados(v_dados.last()).vr_nrctremp := 358179;
  v_dados(v_dados.last()).vr_vllanmto := 28.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17146771;
  v_dados(v_dados.last()).vr_nrctremp := 358932;
  v_dados(v_dados.last()).vr_vllanmto := 10.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17148502;
  v_dados(v_dados.last()).vr_nrctremp := 424366;
  v_dados(v_dados.last()).vr_vllanmto := 128913.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17152836;
  v_dados(v_dados.last()).vr_nrctremp := 358958;
  v_dados(v_dados.last()).vr_vllanmto := 11.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17153000;
  v_dados(v_dados.last()).vr_nrctremp := 358837;
  v_dados(v_dados.last()).vr_vllanmto := 22.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17153743;
  v_dados(v_dados.last()).vr_nrctremp := 379235;
  v_dados(v_dados.last()).vr_vllanmto := 40.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17153743;
  v_dados(v_dados.last()).vr_nrctremp := 379237;
  v_dados(v_dados.last()).vr_vllanmto := 10.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17153743;
  v_dados(v_dados.last()).vr_nrctremp := 400176;
  v_dados(v_dados.last()).vr_vllanmto := 14.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17203597;
  v_dados(v_dados.last()).vr_nrctremp := 361445;
  v_dados(v_dados.last()).vr_vllanmto := 10.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17206103;
  v_dados(v_dados.last()).vr_nrctremp := 361318;
  v_dados(v_dados.last()).vr_vllanmto := 818.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17238625;
  v_dados(v_dados.last()).vr_nrctremp := 362676;
  v_dados(v_dados.last()).vr_vllanmto := 20.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17253519;
  v_dados(v_dados.last()).vr_nrctremp := 381163;
  v_dados(v_dados.last()).vr_vllanmto := 39.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17261090;
  v_dados(v_dados.last()).vr_nrctremp := 364338;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17266610;
  v_dados(v_dados.last()).vr_nrctremp := 364219;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17285879;
  v_dados(v_dados.last()).vr_nrctremp := 371812;
  v_dados(v_dados.last()).vr_vllanmto := 28.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17290660;
  v_dados(v_dados.last()).vr_nrctremp := 366149;
  v_dados(v_dados.last()).vr_vllanmto := 13.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17290660;
  v_dados(v_dados.last()).vr_nrctremp := 384084;
  v_dados(v_dados.last()).vr_vllanmto := 23.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17293235;
  v_dados(v_dados.last()).vr_nrctremp := 365561;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17303680;
  v_dados(v_dados.last()).vr_nrctremp := 413728;
  v_dados(v_dados.last()).vr_vllanmto := 45.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17309026;
  v_dados(v_dados.last()).vr_nrctremp := 366254;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17324661;
  v_dados(v_dados.last()).vr_nrctremp := 383058;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17325781;
  v_dados(v_dados.last()).vr_nrctremp := 386322;
  v_dados(v_dados.last()).vr_vllanmto := 40.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17329582;
  v_dados(v_dados.last()).vr_nrctremp := 367495;
  v_dados(v_dados.last()).vr_vllanmto := 10.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17330360;
  v_dados(v_dados.last()).vr_nrctremp := 367665;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17333423;
  v_dados(v_dados.last()).vr_nrctremp := 367603;
  v_dados(v_dados.last()).vr_vllanmto := 23.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17365210;
  v_dados(v_dados.last()).vr_nrctremp := 368994;
  v_dados(v_dados.last()).vr_vllanmto := 18.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17377811;
  v_dados(v_dados.last()).vr_nrctremp := 370402;
  v_dados(v_dados.last()).vr_vllanmto := 1356.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17397634;
  v_dados(v_dados.last()).vr_nrctremp := 379458;
  v_dados(v_dados.last()).vr_vllanmto := 16.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17404169;
  v_dados(v_dados.last()).vr_nrctremp := 422701;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17416167;
  v_dados(v_dados.last()).vr_nrctremp := 375893;
  v_dados(v_dados.last()).vr_vllanmto := 41.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17421330;
  v_dados(v_dados.last()).vr_nrctremp := 371849;
  v_dados(v_dados.last()).vr_vllanmto := 23.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17452414;
  v_dados(v_dados.last()).vr_nrctremp := 373572;
  v_dados(v_dados.last()).vr_vllanmto := 14.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17464030;
  v_dados(v_dados.last()).vr_nrctremp := 426651;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17474698;
  v_dados(v_dados.last()).vr_nrctremp := 374975;
  v_dados(v_dados.last()).vr_vllanmto := 25.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17478383;
  v_dados(v_dados.last()).vr_nrctremp := 374827;
  v_dados(v_dados.last()).vr_vllanmto := 15.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17478529;
  v_dados(v_dados.last()).vr_nrctremp := 429459;
  v_dados(v_dados.last()).vr_vllanmto := 36.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17481066;
  v_dados(v_dados.last()).vr_nrctremp := 382063;
  v_dados(v_dados.last()).vr_vllanmto := 12.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17487960;
  v_dados(v_dados.last()).vr_nrctremp := 433280;
  v_dados(v_dados.last()).vr_vllanmto := 13.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17494168;
  v_dados(v_dados.last()).vr_nrctremp := 375883;
  v_dados(v_dados.last()).vr_vllanmto := 15.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17535751;
  v_dados(v_dados.last()).vr_nrctremp := 380712;
  v_dados(v_dados.last()).vr_vllanmto := 48.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17539110;
  v_dados(v_dados.last()).vr_nrctremp := 378482;
  v_dados(v_dados.last()).vr_vllanmto := 51114.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17579317;
  v_dados(v_dados.last()).vr_nrctremp := 385664;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17585503;
  v_dados(v_dados.last()).vr_nrctremp := 380812;
  v_dados(v_dados.last()).vr_vllanmto := 96.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17593824;
  v_dados(v_dados.last()).vr_nrctremp := 382549;
  v_dados(v_dados.last()).vr_vllanmto := 499.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17605113;
  v_dados(v_dados.last()).vr_nrctremp := 381977;
  v_dados(v_dados.last()).vr_vllanmto := 25.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17605539;
  v_dados(v_dados.last()).vr_nrctremp := 381992;
  v_dados(v_dados.last()).vr_vllanmto := 20.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17631157;
  v_dados(v_dados.last()).vr_nrctremp := 387742;
  v_dados(v_dados.last()).vr_vllanmto := 15.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17634660;
  v_dados(v_dados.last()).vr_nrctremp := 383139;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17649862;
  v_dados(v_dados.last()).vr_nrctremp := 384036;
  v_dados(v_dados.last()).vr_vllanmto := 466.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17657300;
  v_dados(v_dados.last()).vr_nrctremp := 384601;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17662575;
  v_dados(v_dados.last()).vr_nrctremp := 385127;
  v_dados(v_dados.last()).vr_vllanmto := 14.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17680433;
  v_dados(v_dados.last()).vr_nrctremp := 388552;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17695902;
  v_dados(v_dados.last()).vr_nrctremp := 434135;
  v_dados(v_dados.last()).vr_vllanmto := 13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17700035;
  v_dados(v_dados.last()).vr_nrctremp := 386948;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17707196;
  v_dados(v_dados.last()).vr_nrctremp := 400321;
  v_dados(v_dados.last()).vr_vllanmto := 10.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17707196;
  v_dados(v_dados.last()).vr_nrctremp := 416091;
  v_dados(v_dados.last()).vr_vllanmto := 11.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17724538;
  v_dados(v_dados.last()).vr_nrctremp := 388639;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17734746;
  v_dados(v_dados.last()).vr_nrctremp := 388644;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17741300;
  v_dados(v_dados.last()).vr_nrctremp := 389071;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17743206;
  v_dados(v_dados.last()).vr_nrctremp := 389024;
  v_dados(v_dados.last()).vr_vllanmto := 21.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17746698;
  v_dados(v_dados.last()).vr_nrctremp := 408360;
  v_dados(v_dados.last()).vr_vllanmto := 39.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17751934;
  v_dados(v_dados.last()).vr_nrctremp := 389430;
  v_dados(v_dados.last()).vr_vllanmto := 45.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17752221;
  v_dados(v_dados.last()).vr_nrctremp := 389396;
  v_dados(v_dados.last()).vr_vllanmto := 55.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17758203;
  v_dados(v_dados.last()).vr_nrctremp := 390188;
  v_dados(v_dados.last()).vr_vllanmto := 29.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17759498;
  v_dados(v_dados.last()).vr_nrctremp := 390238;
  v_dados(v_dados.last()).vr_vllanmto := 515.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17759498;
  v_dados(v_dados.last()).vr_nrctremp := 390735;
  v_dados(v_dados.last()).vr_vllanmto := 12.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17794331;
  v_dados(v_dados.last()).vr_nrctremp := 419900;
  v_dados(v_dados.last()).vr_vllanmto := 22.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17814901;
  v_dados(v_dados.last()).vr_nrctremp := 393629;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17816483;
  v_dados(v_dados.last()).vr_nrctremp := 437498;
  v_dados(v_dados.last()).vr_vllanmto := 54.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17826861;
  v_dados(v_dados.last()).vr_nrctremp := 426169;
  v_dados(v_dados.last()).vr_vllanmto := 21.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17835577;
  v_dados(v_dados.last()).vr_nrctremp := 394131;
  v_dados(v_dados.last()).vr_vllanmto := 392.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17842050;
  v_dados(v_dados.last()).vr_nrctremp := 394532;
  v_dados(v_dados.last()).vr_vllanmto := 14.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17855683;
  v_dados(v_dados.last()).vr_nrctremp := 395361;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17887615;
  v_dados(v_dados.last()).vr_nrctremp := 400681;
  v_dados(v_dados.last()).vr_vllanmto := 41.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17930375;
  v_dados(v_dados.last()).vr_nrctremp := 401662;
  v_dados(v_dados.last()).vr_vllanmto := 15.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17932106;
  v_dados(v_dados.last()).vr_nrctremp := 398999;
  v_dados(v_dados.last()).vr_vllanmto := 12.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17959764;
  v_dados(v_dados.last()).vr_nrctremp := 400394;
  v_dados(v_dados.last()).vr_vllanmto := 144.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17985692;
  v_dados(v_dados.last()).vr_nrctremp := 401982;
  v_dados(v_dados.last()).vr_vllanmto := 272.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18008690;
  v_dados(v_dados.last()).vr_nrctremp := 403327;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18011527;
  v_dados(v_dados.last()).vr_nrctremp := 403442;
  v_dados(v_dados.last()).vr_vllanmto := 17.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18011527;
  v_dados(v_dados.last()).vr_nrctremp := 429852;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18021549;
  v_dados(v_dados.last()).vr_nrctremp := 404029;
  v_dados(v_dados.last()).vr_vllanmto := 12.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18045995;
  v_dados(v_dados.last()).vr_nrctremp := 405779;
  v_dados(v_dados.last()).vr_vllanmto := 14.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18051790;
  v_dados(v_dados.last()).vr_nrctremp := 406908;
  v_dados(v_dados.last()).vr_vllanmto := 54.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18144888;
  v_dados(v_dados.last()).vr_nrctremp := 411184;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18159761;
  v_dados(v_dados.last()).vr_nrctremp := 411749;
  v_dados(v_dados.last()).vr_vllanmto := 20.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18186793;
  v_dados(v_dados.last()).vr_nrctremp := 421008;
  v_dados(v_dados.last()).vr_vllanmto := 62.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18254470;
  v_dados(v_dados.last()).vr_nrctremp := 416629;
  v_dados(v_dados.last()).vr_vllanmto := 59.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18293573;
  v_dados(v_dados.last()).vr_nrctremp := 418618;
  v_dados(v_dados.last()).vr_vllanmto := 18.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18432190;
  v_dados(v_dados.last()).vr_nrctremp := 439568;
  v_dados(v_dados.last()).vr_vllanmto := 23.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18473091;
  v_dados(v_dados.last()).vr_nrctremp := 428377;
  v_dados(v_dados.last()).vr_vllanmto := 11.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18485626;
  v_dados(v_dados.last()).vr_nrctremp := 428303;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18496164;
  v_dados(v_dados.last()).vr_nrctremp := 431510;
  v_dados(v_dados.last()).vr_vllanmto := 24248.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18496164;
  v_dados(v_dados.last()).vr_nrctremp := 440944;
  v_dados(v_dados.last()).vr_vllanmto := 26366.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18512518;
  v_dados(v_dados.last()).vr_nrctremp := 429136;
  v_dados(v_dados.last()).vr_vllanmto := 30.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18519873;
  v_dados(v_dados.last()).vr_nrctremp := 429538;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18558585;
  v_dados(v_dados.last()).vr_nrctremp := 432076;
  v_dados(v_dados.last()).vr_vllanmto := 12.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18568610;
  v_dados(v_dados.last()).vr_nrctremp := 432720;
  v_dados(v_dados.last()).vr_vllanmto := 23.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18575773;
  v_dados(v_dados.last()).vr_nrctremp := 433062;
  v_dados(v_dados.last()).vr_vllanmto := 10.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18578438;
  v_dados(v_dados.last()).vr_nrctremp := 433223;
  v_dados(v_dados.last()).vr_vllanmto := 20.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18579370;
  v_dados(v_dados.last()).vr_nrctremp := 433244;
  v_dados(v_dados.last()).vr_vllanmto := 28.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18639879;
  v_dados(v_dados.last()).vr_nrctremp := 441257;
  v_dados(v_dados.last()).vr_vllanmto := 36.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18640400;
  v_dados(v_dados.last()).vr_nrctremp := 442116;
  v_dados(v_dados.last()).vr_vllanmto := 32.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18682227;
  v_dados(v_dados.last()).vr_nrctremp := 439794;
  v_dados(v_dados.last()).vr_vllanmto := 26.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18696503;
  v_dados(v_dados.last()).vr_nrctremp := 439913;
  v_dados(v_dados.last()).vr_vllanmto := 22.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18712657;
  v_dados(v_dados.last()).vr_nrctremp := 440839;
  v_dados(v_dados.last()).vr_vllanmto := 19.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18732437;
  v_dados(v_dados.last()).vr_nrctremp := 441777;
  v_dados(v_dados.last()).vr_vllanmto := 19.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18745032;
  v_dados(v_dados.last()).vr_nrctremp := 442542;
  v_dados(v_dados.last()).vr_vllanmto := 10.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18750079;
  v_dados(v_dados.last()).vr_nrctremp := 442746;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18750761;
  v_dados(v_dados.last()).vr_nrctremp := 442770;
  v_dados(v_dados.last()).vr_vllanmto := 18.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18751660;
  v_dados(v_dados.last()).vr_nrctremp := 443319;
  v_dados(v_dados.last()).vr_vllanmto := 18.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 18761194;
  v_dados(v_dados.last()).vr_nrctremp := 443346;
  v_dados(v_dados.last()).vr_vllanmto := 18.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 39489;
  v_dados(v_dados.last()).vr_nrctremp := 100056;
  v_dados(v_dados.last()).vr_vllanmto := 32.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 196754;
  v_dados(v_dados.last()).vr_nrctremp := 72364;
  v_dados(v_dados.last()).vr_vllanmto := 234.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 12;
  v_dados(v_dados.last()).vr_nrdconta := 196754;
  v_dados(v_dados.last()).vr_nrctremp := 84017;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 5046.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 3905;
  v_dados(v_dados.last()).vr_nrctremp := 300931;
  v_dados(v_dados.last()).vr_vllanmto := 1523.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 8222;
  v_dados(v_dados.last()).vr_nrctremp := 325976;
  v_dados(v_dados.last()).vr_vllanmto := 25.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 9350;
  v_dados(v_dados.last()).vr_nrctremp := 358996;
  v_dados(v_dados.last()).vr_vllanmto := 21.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 9482;
  v_dados(v_dados.last()).vr_nrctremp := 330466;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14613;
  v_dados(v_dados.last()).vr_nrctremp := 345704;
  v_dados(v_dados.last()).vr_vllanmto := 15.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15458;
  v_dados(v_dados.last()).vr_nrctremp := 278607;
  v_dados(v_dados.last()).vr_vllanmto := 17.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18180;
  v_dados(v_dados.last()).vr_nrctremp := 287995;
  v_dados(v_dados.last()).vr_vllanmto := 21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 9428.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 23388;
  v_dados(v_dados.last()).vr_nrctremp := 359423;
  v_dados(v_dados.last()).vr_vllanmto := 17.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26590;
  v_dados(v_dados.last()).vr_nrctremp := 347599;
  v_dados(v_dados.last()).vr_vllanmto := 11.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26670;
  v_dados(v_dados.last()).vr_nrctremp := 342212;
  v_dados(v_dados.last()).vr_vllanmto := 14.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 31275;
  v_dados(v_dados.last()).vr_nrctremp := 162267;
  v_dados(v_dados.last()).vr_vllanmto := 17.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 31682;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 1316.99;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 32123;
  v_dados(v_dados.last()).vr_nrctremp := 296829;
  v_dados(v_dados.last()).vr_vllanmto := 39.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 33472;
  v_dados(v_dados.last()).vr_nrctremp := 327976;
  v_dados(v_dados.last()).vr_vllanmto := 10.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 35270;
  v_dados(v_dados.last()).vr_nrctremp := 175671;
  v_dados(v_dados.last()).vr_vllanmto := 25.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 35599;
  v_dados(v_dados.last()).vr_nrctremp := 303991;
  v_dados(v_dados.last()).vr_vllanmto := 502.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 44164;
  v_dados(v_dados.last()).vr_nrctremp := 218873;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 44407;
  v_dados(v_dados.last()).vr_nrctremp := 315258;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 44423;
  v_dados(v_dados.last()).vr_nrctremp := 325947;
  v_dados(v_dados.last()).vr_vllanmto := 14.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 47260;
  v_dados(v_dados.last()).vr_nrctremp := 280688;
  v_dados(v_dados.last()).vr_vllanmto := 16.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 56154;
  v_dados(v_dados.last()).vr_nrctremp := 298112;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 58530;
  v_dados(v_dados.last()).vr_nrctremp := 349374;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 60658;
  v_dados(v_dados.last()).vr_nrctremp := 148221;
  v_dados(v_dados.last()).vr_vllanmto := 12.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61751;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 3722.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61760;
  v_dados(v_dados.last()).vr_nrctremp := 274745;
  v_dados(v_dados.last()).vr_vllanmto := 85.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66532;
  v_dados(v_dados.last()).vr_nrctremp := 238051;
  v_dados(v_dados.last()).vr_vllanmto := 12.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66605;
  v_dados(v_dados.last()).vr_nrctremp := 331690;
  v_dados(v_dados.last()).vr_vllanmto := 32781.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66672;
  v_dados(v_dados.last()).vr_nrctremp := 294352;
  v_dados(v_dados.last()).vr_vllanmto := 11.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66800;
  v_dados(v_dados.last()).vr_nrctremp := 356452;
  v_dados(v_dados.last()).vr_vllanmto := 15.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66826;
  v_dados(v_dados.last()).vr_nrctremp := 284580;
  v_dados(v_dados.last()).vr_vllanmto := 11099.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 67261;
  v_dados(v_dados.last()).vr_nrctremp := 291731;
  v_dados(v_dados.last()).vr_vllanmto := 14.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 68616;
  v_dados(v_dados.last()).vr_nrctremp := 300883;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 70386;
  v_dados(v_dados.last()).vr_nrctremp := 315031;
  v_dados(v_dados.last()).vr_vllanmto := 11.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 70866;
  v_dados(v_dados.last()).vr_nrctremp := 353771;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 75132;
  v_dados(v_dados.last()).vr_nrctremp := 359021;
  v_dados(v_dados.last()).vr_vllanmto := 13.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 76961;
  v_dados(v_dados.last()).vr_nrctremp := 328737;
  v_dados(v_dados.last()).vr_vllanmto := 14.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78638;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 69.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78727;
  v_dados(v_dados.last()).vr_nrctremp := 283429;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 79448;
  v_dados(v_dados.last()).vr_nrctremp := 314754;
  v_dados(v_dados.last()).vr_vllanmto := 270.9;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 80250;
  v_dados(v_dados.last()).vr_nrctremp := 330113;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 80349;
  v_dados(v_dados.last()).vr_nrctremp := 351614;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 85561;
  v_dados(v_dados.last()).vr_nrctremp := 276706;
  v_dados(v_dados.last()).vr_vllanmto := 16.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 86126;
  v_dados(v_dados.last()).vr_nrctremp := 355878;
  v_dados(v_dados.last()).vr_vllanmto := 17.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 90360;
  v_dados(v_dados.last()).vr_nrctremp := 71345;
  v_dados(v_dados.last()).vr_vllanmto := 1361.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 91189;
  v_dados(v_dados.last()).vr_nrctremp := 298106;
  v_dados(v_dados.last()).vr_vllanmto := 27.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92380;
  v_dados(v_dados.last()).vr_nrctremp := 316572;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92410;
  v_dados(v_dados.last()).vr_nrctremp := 242872;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 93165;
  v_dados(v_dados.last()).vr_nrctremp := 305633;
  v_dados(v_dados.last()).vr_vllanmto := 10.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 94730;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 1866.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 95141;
  v_dados(v_dados.last()).vr_nrctremp := 276915;
  v_dados(v_dados.last()).vr_vllanmto := 30.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 95737;
  v_dados(v_dados.last()).vr_nrctremp := 345745;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 96202;
  v_dados(v_dados.last()).vr_nrctremp := 349943;
  v_dados(v_dados.last()).vr_vllanmto := 18.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 100986;
  v_dados(v_dados.last()).vr_nrctremp := 351676;
  v_dados(v_dados.last()).vr_vllanmto := 29.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 101320;
  v_dados(v_dados.last()).vr_nrctremp := 325281;
  v_dados(v_dados.last()).vr_vllanmto := 12.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 103608;
  v_dados(v_dados.last()).vr_nrctremp := 314824;
  v_dados(v_dados.last()).vr_vllanmto := 14.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 103691;
  v_dados(v_dados.last()).vr_nrctremp := 302626;
  v_dados(v_dados.last()).vr_vllanmto := 13.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 105015;
  v_dados(v_dados.last()).vr_nrctremp := 261154;
  v_dados(v_dados.last()).vr_vllanmto := 20.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116491;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 3190.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 67611;
  v_dados(v_dados.last()).vr_vllanmto := 1602.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 247445;
  v_dados(v_dados.last()).vr_vllanmto := 52.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 298187;
  v_dados(v_dados.last()).vr_vllanmto := 99.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 120618;
  v_dados(v_dados.last()).vr_nrctremp := 327711;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 124982;
  v_dados(v_dados.last()).vr_nrctremp := 348793;
  v_dados(v_dados.last()).vr_vllanmto := 36.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 128317;
  v_dados(v_dados.last()).vr_nrctremp := 262491;
  v_dados(v_dados.last()).vr_vllanmto := 24.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 128333;
  v_dados(v_dados.last()).vr_nrctremp := 174807;
  v_dados(v_dados.last()).vr_vllanmto := 3233.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 130923;
  v_dados(v_dados.last()).vr_nrctremp := 305091;
  v_dados(v_dados.last()).vr_vllanmto := 44207.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 131091;
  v_dados(v_dados.last()).vr_nrctremp := 264793;
  v_dados(v_dados.last()).vr_vllanmto := 12.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 133043;
  v_dados(v_dados.last()).vr_nrctremp := 219930;
  v_dados(v_dados.last()).vr_vllanmto := 15.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 133051;
  v_dados(v_dados.last()).vr_nrctremp := 348846;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 134546;
  v_dados(v_dados.last()).vr_nrctremp := 302408;
  v_dados(v_dados.last()).vr_vllanmto := 15.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 135810;
  v_dados(v_dados.last()).vr_nrctremp := 314531;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136050;
  v_dados(v_dados.last()).vr_nrctremp := 168147;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136956;
  v_dados(v_dados.last()).vr_nrctremp := 115239;
  v_dados(v_dados.last()).vr_vllanmto := 41.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136956;
  v_dados(v_dados.last()).vr_nrctremp := 261434;
  v_dados(v_dados.last()).vr_vllanmto := 12.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 137804;
  v_dados(v_dados.last()).vr_nrctremp := 252706;
  v_dados(v_dados.last()).vr_vllanmto := 11.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 138207;
  v_dados(v_dados.last()).vr_nrctremp := 320510;
  v_dados(v_dados.last()).vr_vllanmto := 26.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 138223;
  v_dados(v_dados.last()).vr_nrctremp := 204399;
  v_dados(v_dados.last()).vr_vllanmto := 1243.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 139025;
  v_dados(v_dados.last()).vr_nrctremp := 187057;
  v_dados(v_dados.last()).vr_vllanmto := 16.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 139025;
  v_dados(v_dados.last()).vr_nrctremp := 341948;
  v_dados(v_dados.last()).vr_vllanmto := 14.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 139505;
  v_dados(v_dados.last()).vr_nrctremp := 359480;
  v_dados(v_dados.last()).vr_vllanmto := 69.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 140163;
  v_dados(v_dados.last()).vr_nrctremp := 338901;
  v_dados(v_dados.last()).vr_vllanmto := 14.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 140600;
  v_dados(v_dados.last()).vr_nrctremp := 269375;
  v_dados(v_dados.last()).vr_vllanmto := 14.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 140856;
  v_dados(v_dados.last()).vr_nrctremp := 165756;
  v_dados(v_dados.last()).vr_vllanmto := 13.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141119;
  v_dados(v_dados.last()).vr_nrctremp := 274882;
  v_dados(v_dados.last()).vr_vllanmto := 13.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141119;
  v_dados(v_dados.last()).vr_nrctremp := 276901;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141119;
  v_dados(v_dados.last()).vr_nrctremp := 279765;
  v_dados(v_dados.last()).vr_vllanmto := 19.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141119;
  v_dados(v_dados.last()).vr_nrctremp := 283956;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141496;
  v_dados(v_dados.last()).vr_nrctremp := 255202;
  v_dados(v_dados.last()).vr_vllanmto := 1095.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141631;
  v_dados(v_dados.last()).vr_nrctremp := 349917;
  v_dados(v_dados.last()).vr_vllanmto := 12.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 141976;
  v_dados(v_dados.last()).vr_nrctremp := 236257;
  v_dados(v_dados.last()).vr_vllanmto := 43.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 142565;
  v_dados(v_dados.last()).vr_nrctremp := 313991;
  v_dados(v_dados.last()).vr_vllanmto := 17.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 142611;
  v_dados(v_dados.last()).vr_nrctremp := 348713;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143294;
  v_dados(v_dados.last()).vr_nrctremp := 106135;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143367;
  v_dados(v_dados.last()).vr_nrctremp := 66735;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143367;
  v_dados(v_dados.last()).vr_nrctremp := 91148;
  v_dados(v_dados.last()).vr_vllanmto := 10.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143367;
  v_dados(v_dados.last()).vr_nrctremp := 355010;
  v_dados(v_dados.last()).vr_vllanmto := 11.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143782;
  v_dados(v_dados.last()).vr_nrctremp := 212459;
  v_dados(v_dados.last()).vr_vllanmto := 19.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 144231;
  v_dados(v_dados.last()).vr_nrctremp := 86096;
  v_dados(v_dados.last()).vr_vllanmto := 22.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 144762;
  v_dados(v_dados.last()).vr_nrctremp := 313396;
  v_dados(v_dados.last()).vr_vllanmto := 36.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 144843;
  v_dados(v_dados.last()).vr_nrctremp := 313769;
  v_dados(v_dados.last()).vr_vllanmto := 17.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145319;
  v_dados(v_dados.last()).vr_nrctremp := 333521;
  v_dados(v_dados.last()).vr_vllanmto := 26.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145530;
  v_dados(v_dados.last()).vr_nrctremp := 235307;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145637;
  v_dados(v_dados.last()).vr_nrctremp := 286829;
  v_dados(v_dados.last()).vr_vllanmto := 10.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145742;
  v_dados(v_dados.last()).vr_nrctremp := 269860;
  v_dados(v_dados.last()).vr_vllanmto := 12.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146013;
  v_dados(v_dados.last()).vr_nrctremp := 209282;
  v_dados(v_dados.last()).vr_vllanmto := 12.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146021;
  v_dados(v_dados.last()).vr_nrctremp := 353519;
  v_dados(v_dados.last()).vr_vllanmto := 16.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146374;
  v_dados(v_dados.last()).vr_nrctremp := 288598;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146625;
  v_dados(v_dados.last()).vr_nrctremp := 356035;
  v_dados(v_dados.last()).vr_vllanmto := 21.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 147664;
  v_dados(v_dados.last()).vr_nrctremp := 191788;
  v_dados(v_dados.last()).vr_vllanmto := 13.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 147818;
  v_dados(v_dados.last()).vr_nrctremp := 332987;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149535;
  v_dados(v_dados.last()).vr_nrctremp := 330867;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149632;
  v_dados(v_dados.last()).vr_nrctremp := 273460;
  v_dados(v_dados.last()).vr_vllanmto := 19.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149853;
  v_dados(v_dados.last()).vr_nrctremp := 244797;
  v_dados(v_dados.last()).vr_vllanmto := 31.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149969;
  v_dados(v_dados.last()).vr_nrctremp := 316972;
  v_dados(v_dados.last()).vr_vllanmto := 44.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149969;
  v_dados(v_dados.last()).vr_nrctremp := 332861;
  v_dados(v_dados.last()).vr_vllanmto := 32.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150479;
  v_dados(v_dados.last()).vr_nrctremp := 275838;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150550;
  v_dados(v_dados.last()).vr_nrctremp := 146498;
  v_dados(v_dados.last()).vr_vllanmto := 16.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150967;
  v_dados(v_dados.last()).vr_nrctremp := 175748;
  v_dados(v_dados.last()).vr_vllanmto := 21.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 151114;
  v_dados(v_dados.last()).vr_nrctremp := 340928;
  v_dados(v_dados.last()).vr_vllanmto := 24.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 151394;
  v_dados(v_dados.last()).vr_nrctremp := 338752;
  v_dados(v_dados.last()).vr_vllanmto := 18.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 152463;
  v_dados(v_dados.last()).vr_nrctremp := 238102;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 152803;
  v_dados(v_dados.last()).vr_nrctremp := 321654;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153346;
  v_dados(v_dados.last()).vr_nrctremp := 253723;
  v_dados(v_dados.last()).vr_vllanmto := 14.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153346;
  v_dados(v_dados.last()).vr_nrctremp := 298812;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153397;
  v_dados(v_dados.last()).vr_nrctremp := 135768;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153397;
  v_dados(v_dados.last()).vr_nrctremp := 278865;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153605;
  v_dados(v_dados.last()).vr_nrctremp := 335412;
  v_dados(v_dados.last()).vr_vllanmto := 17.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154075;
  v_dados(v_dados.last()).vr_nrctremp := 332665;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154105;
  v_dados(v_dados.last()).vr_nrctremp := 332658;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154512;
  v_dados(v_dados.last()).vr_nrctremp := 235865;
  v_dados(v_dados.last()).vr_vllanmto := 14.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154512;
  v_dados(v_dados.last()).vr_nrctremp := 257639;
  v_dados(v_dados.last()).vr_vllanmto := 17.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154512;
  v_dados(v_dados.last()).vr_nrctremp := 345820;
  v_dados(v_dados.last()).vr_vllanmto := 21.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 245701;
  v_dados(v_dados.last()).vr_vllanmto := 117.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154725;
  v_dados(v_dados.last()).vr_nrctremp := 314592;
  v_dados(v_dados.last()).vr_vllanmto := 116.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 155187;
  v_dados(v_dados.last()).vr_nrctremp := 341233;
  v_dados(v_dados.last()).vr_vllanmto := 13.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 155608;
  v_dados(v_dados.last()).vr_nrctremp := 311610;
  v_dados(v_dados.last()).vr_vllanmto := 145.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 155624;
  v_dados(v_dados.last()).vr_nrctremp := 359215;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156272;
  v_dados(v_dados.last()).vr_nrctremp := 210406;
  v_dados(v_dados.last()).vr_vllanmto := 45.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156680;
  v_dados(v_dados.last()).vr_nrctremp := 284309;
  v_dados(v_dados.last()).vr_vllanmto := 48.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156850;
  v_dados(v_dados.last()).vr_nrctremp := 197038;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 157287;
  v_dados(v_dados.last()).vr_nrctremp := 262694;
  v_dados(v_dados.last()).vr_vllanmto := 31.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 157830;
  v_dados(v_dados.last()).vr_nrctremp := 322396;
  v_dados(v_dados.last()).vr_vllanmto := 31.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 159115;
  v_dados(v_dados.last()).vr_nrctremp := 233853;
  v_dados(v_dados.last()).vr_vllanmto := 78.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160318;
  v_dados(v_dados.last()).vr_nrctremp := 327746;
  v_dados(v_dados.last()).vr_vllanmto := 15.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160318;
  v_dados(v_dados.last()).vr_nrctremp := 337210;
  v_dados(v_dados.last()).vr_vllanmto := 11.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160644;
  v_dados(v_dados.last()).vr_nrctremp := 65833;
  v_dados(v_dados.last()).vr_vllanmto := 1880.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160644;
  v_dados(v_dados.last()).vr_nrctremp := 188123;
  v_dados(v_dados.last()).vr_vllanmto := 43.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160644;
  v_dados(v_dados.last()).vr_nrctremp := 279361;
  v_dados(v_dados.last()).vr_vllanmto := 20.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 161284;
  v_dados(v_dados.last()).vr_nrctremp := 313316;
  v_dados(v_dados.last()).vr_vllanmto := 38.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 161640;
  v_dados(v_dados.last()).vr_nrctremp := 335435;
  v_dados(v_dados.last()).vr_vllanmto := 38.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163171;
  v_dados(v_dados.last()).vr_nrctremp := 314443;
  v_dados(v_dados.last()).vr_vllanmto := 29.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163376;
  v_dados(v_dados.last()).vr_nrctremp := 264492;
  v_dados(v_dados.last()).vr_vllanmto := 14.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163384;
  v_dados(v_dados.last()).vr_nrctremp := 199142;
  v_dados(v_dados.last()).vr_vllanmto := 27.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163651;
  v_dados(v_dados.last()).vr_nrctremp := 266022;
  v_dados(v_dados.last()).vr_vllanmto := 10.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163872;
  v_dados(v_dados.last()).vr_nrctremp := 110555;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 166677;
  v_dados(v_dados.last()).vr_nrctremp := 347588;
  v_dados(v_dados.last()).vr_vllanmto := 19.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167193;
  v_dados(v_dados.last()).vr_nrctremp := 265127;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167193;
  v_dados(v_dados.last()).vr_nrctremp := 292560;
  v_dados(v_dados.last()).vr_vllanmto := 19.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167495;
  v_dados(v_dados.last()).vr_nrctremp := 345754;
  v_dados(v_dados.last()).vr_vllanmto := 33.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167924;
  v_dados(v_dados.last()).vr_nrctremp := 175206;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 168190;
  v_dados(v_dados.last()).vr_nrctremp := 312546;
  v_dados(v_dados.last()).vr_vllanmto := 11.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170097;
  v_dados(v_dados.last()).vr_nrctremp := 236919;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170305;
  v_dados(v_dados.last()).vr_nrctremp := 346993;
  v_dados(v_dados.last()).vr_vllanmto := 11.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170488;
  v_dados(v_dados.last()).vr_nrctremp := 252797;
  v_dados(v_dados.last()).vr_vllanmto := 2576.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 171700;
  v_dados(v_dados.last()).vr_nrctremp := 324072;
  v_dados(v_dados.last()).vr_vllanmto := 11.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 171824;
  v_dados(v_dados.last()).vr_nrctremp := 142019;
  v_dados(v_dados.last()).vr_vllanmto := 13.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 171921;
  v_dados(v_dados.last()).vr_nrctremp := 124332;
  v_dados(v_dados.last()).vr_vllanmto := 107.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 171921;
  v_dados(v_dados.last()).vr_nrctremp := 124334;
  v_dados(v_dados.last()).vr_vllanmto := 48.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172022;
  v_dados(v_dados.last()).vr_nrctremp := 301654;
  v_dados(v_dados.last()).vr_vllanmto := 33.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172189;
  v_dados(v_dados.last()).vr_nrctremp := 336431;
  v_dados(v_dados.last()).vr_vllanmto := 16.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172421;
  v_dados(v_dados.last()).vr_nrctremp := 252268;
  v_dados(v_dados.last()).vr_vllanmto := 13.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172448;
  v_dados(v_dados.last()).vr_nrctremp := 303281;
  v_dados(v_dados.last()).vr_vllanmto := 18.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172804;
  v_dados(v_dados.last()).vr_nrctremp := 325045;
  v_dados(v_dados.last()).vr_vllanmto := 29.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172855;
  v_dados(v_dados.last()).vr_nrctremp := 329245;
  v_dados(v_dados.last()).vr_vllanmto := 24.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 230666;
  v_dados(v_dados.last()).vr_vllanmto := 175.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 248810;
  v_dados(v_dados.last()).vr_vllanmto := 45.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 254372;
  v_dados(v_dados.last()).vr_vllanmto := 2065.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 273151;
  v_dados(v_dados.last()).vr_vllanmto := 55.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 287913;
  v_dados(v_dados.last()).vr_vllanmto := 70.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172871;
  v_dados(v_dados.last()).vr_nrctremp := 309165;
  v_dados(v_dados.last()).vr_vllanmto := 138.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 174033;
  v_dados(v_dados.last()).vr_nrctremp := 273104;
  v_dados(v_dados.last()).vr_vllanmto := 140.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 174866;
  v_dados(v_dados.last()).vr_nrctremp := 305367;
  v_dados(v_dados.last()).vr_vllanmto := 20.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 175455;
  v_dados(v_dados.last()).vr_nrctremp := 167766;
  v_dados(v_dados.last()).vr_vllanmto := 11.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 175498;
  v_dados(v_dados.last()).vr_nrctremp := 295718;
  v_dados(v_dados.last()).vr_vllanmto := 20.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 177881;
  v_dados(v_dados.last()).vr_nrctremp := 242315;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179922;
  v_dados(v_dados.last()).vr_nrctremp := 196857;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 181617;
  v_dados(v_dados.last()).vr_nrctremp := 286610;
  v_dados(v_dados.last()).vr_vllanmto := 10.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 182958;
  v_dados(v_dados.last()).vr_nrctremp := 101588;
  v_dados(v_dados.last()).vr_vllanmto := 17.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 183024;
  v_dados(v_dados.last()).vr_nrctremp := 342862;
  v_dados(v_dados.last()).vr_vllanmto := 16.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 183822;
  v_dados(v_dados.last()).vr_nrctremp := 245338;
  v_dados(v_dados.last()).vr_vllanmto := 21.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184349;
  v_dados(v_dados.last()).vr_nrctremp := 262671;
  v_dados(v_dados.last()).vr_vllanmto := 43.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184349;
  v_dados(v_dados.last()).vr_nrctremp := 302724;
  v_dados(v_dados.last()).vr_vllanmto := 134;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 247626;
  v_dados(v_dados.last()).vr_vllanmto := 414.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184381;
  v_dados(v_dados.last()).vr_nrctremp := 299304;
  v_dados(v_dados.last()).vr_vllanmto := 96.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184390;
  v_dados(v_dados.last()).vr_nrctremp := 286467;
  v_dados(v_dados.last()).vr_vllanmto := 190.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 184810;
  v_dados(v_dados.last()).vr_nrctremp := 302094;
  v_dados(v_dados.last()).vr_vllanmto := 53.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185272;
  v_dados(v_dados.last()).vr_nrctremp := 139153;
  v_dados(v_dados.last()).vr_vllanmto := 102.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185426;
  v_dados(v_dados.last()).vr_nrctremp := 242044;
  v_dados(v_dados.last()).vr_vllanmto := 38.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185485;
  v_dados(v_dados.last()).vr_nrctremp := 317939;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185531;
  v_dados(v_dados.last()).vr_nrctremp := 205263;
  v_dados(v_dados.last()).vr_vllanmto := 1142.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185574;
  v_dados(v_dados.last()).vr_nrctremp := 286328;
  v_dados(v_dados.last()).vr_vllanmto := 350.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185825;
  v_dados(v_dados.last()).vr_nrctremp := 233245;
  v_dados(v_dados.last()).vr_vllanmto := 23.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185825;
  v_dados(v_dados.last()).vr_nrctremp := 237814;
  v_dados(v_dados.last()).vr_vllanmto := 31.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185833;
  v_dados(v_dados.last()).vr_nrctremp := 264660;
  v_dados(v_dados.last()).vr_vllanmto := 105.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 114018;
  v_dados(v_dados.last()).vr_vllanmto := 30.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 130951;
  v_dados(v_dados.last()).vr_vllanmto := 21.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 174443;
  v_dados(v_dados.last()).vr_vllanmto := 40.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185930;
  v_dados(v_dados.last()).vr_nrctremp := 283372;
  v_dados(v_dados.last()).vr_vllanmto := 23.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185957;
  v_dados(v_dados.last()).vr_nrctremp := 337321;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185981;
  v_dados(v_dados.last()).vr_nrctremp := 271143;
  v_dados(v_dados.last()).vr_vllanmto := 45.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186198;
  v_dados(v_dados.last()).vr_nrctremp := 283202;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186201;
  v_dados(v_dados.last()).vr_nrctremp := 68975;
  v_dados(v_dados.last()).vr_vllanmto := 96.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186244;
  v_dados(v_dados.last()).vr_nrctremp := 278887;
  v_dados(v_dados.last()).vr_vllanmto := 178.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186481;
  v_dados(v_dados.last()).vr_nrctremp := 296021;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186511;
  v_dados(v_dados.last()).vr_nrctremp := 90119;
  v_dados(v_dados.last()).vr_vllanmto := 49.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186740;
  v_dados(v_dados.last()).vr_nrctremp := 308515;
  v_dados(v_dados.last()).vr_vllanmto := 12912.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186902;
  v_dados(v_dados.last()).vr_nrctremp := 92977;
  v_dados(v_dados.last()).vr_vllanmto := 154.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187143;
  v_dados(v_dados.last()).vr_nrctremp := 132407;
  v_dados(v_dados.last()).vr_vllanmto := 128.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187143;
  v_dados(v_dados.last()).vr_nrctremp := 295344;
  v_dados(v_dados.last()).vr_vllanmto := 63.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187160;
  v_dados(v_dados.last()).vr_nrctremp := 244065;
  v_dados(v_dados.last()).vr_vllanmto := 34700.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187232;
  v_dados(v_dados.last()).vr_nrctremp := 285000;
  v_dados(v_dados.last()).vr_vllanmto := 45.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187372;
  v_dados(v_dados.last()).vr_nrctremp := 102721;
  v_dados(v_dados.last()).vr_vllanmto := 45.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187372;
  v_dados(v_dados.last()).vr_nrctremp := 287693;
  v_dados(v_dados.last()).vr_vllanmto := 97.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 184919;
  v_dados(v_dados.last()).vr_vllanmto := 21.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 274702;
  v_dados(v_dados.last()).vr_vllanmto := 22.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

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
  v_dados(v_dados.last()).vr_nrdconta := 187895;
  v_dados(v_dados.last()).vr_nrctremp := 333099;
  v_dados(v_dados.last()).vr_vllanmto := 32.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 238369;
  v_dados(v_dados.last()).vr_vllanmto := 7908.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 268418;
  v_dados(v_dados.last()).vr_vllanmto := 518.59;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 824.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139845;
  v_dados(v_dados.last()).vr_vllanmto := 293.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 148826;
  v_dados(v_dados.last()).vr_vllanmto := 248.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 187546;
  v_dados(v_dados.last()).vr_vllanmto := 612.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 202660;
  v_dados(v_dados.last()).vr_vllanmto := 240.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 284704;
  v_dados(v_dados.last()).vr_vllanmto := 400.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188115;
  v_dados(v_dados.last()).vr_nrctremp := 266788;
  v_dados(v_dados.last()).vr_vllanmto := 106.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188158;
  v_dados(v_dados.last()).vr_nrctremp := 299560;
  v_dados(v_dados.last()).vr_vllanmto := 177.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188433;
  v_dados(v_dados.last()).vr_nrctremp := 268186;
  v_dados(v_dados.last()).vr_vllanmto := 731.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188557;
  v_dados(v_dados.last()).vr_nrctremp := 280380;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188620;
  v_dados(v_dados.last()).vr_nrctremp := 90707;
  v_dados(v_dados.last()).vr_vllanmto := 237.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188719;
  v_dados(v_dados.last()).vr_nrctremp := 254965;
  v_dados(v_dados.last()).vr_vllanmto := 341.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188727;
  v_dados(v_dados.last()).vr_nrctremp := 309516;
  v_dados(v_dados.last()).vr_vllanmto := 36.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189154;
  v_dados(v_dados.last()).vr_nrctremp := 321304;
  v_dados(v_dados.last()).vr_vllanmto := 12.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189499;
  v_dados(v_dados.last()).vr_nrctremp := 305824;
  v_dados(v_dados.last()).vr_vllanmto := 53.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189499;
  v_dados(v_dados.last()).vr_nrctremp := 319229;
  v_dados(v_dados.last()).vr_vllanmto := 14.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189693;
  v_dados(v_dados.last()).vr_nrctremp := 116388;
  v_dados(v_dados.last()).vr_vllanmto := 15.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189790;
  v_dados(v_dados.last()).vr_nrctremp := 212748;
  v_dados(v_dados.last()).vr_vllanmto := 470.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 189790;
  v_dados(v_dados.last()).vr_nrctremp := 231817;
  v_dados(v_dados.last()).vr_vllanmto := 76.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190047;
  v_dados(v_dados.last()).vr_nrctremp := 334284;
  v_dados(v_dados.last()).vr_vllanmto := 15.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190098;
  v_dados(v_dados.last()).vr_nrctremp := 229054;
  v_dados(v_dados.last()).vr_vllanmto := 13.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190136;
  v_dados(v_dados.last()).vr_nrctremp := 117890;
  v_dados(v_dados.last()).vr_vllanmto := 149.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190136;
  v_dados(v_dados.last()).vr_nrctremp := 263805;
  v_dados(v_dados.last()).vr_vllanmto := 54.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 190934;
  v_dados(v_dados.last()).vr_nrctremp := 259798;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192350;
  v_dados(v_dados.last()).vr_nrctremp := 213885;
  v_dados(v_dados.last()).vr_vllanmto := 26727.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192520;
  v_dados(v_dados.last()).vr_nrctremp := 165359;
  v_dados(v_dados.last()).vr_vllanmto := 13.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192635;
  v_dados(v_dados.last()).vr_nrctremp := 312500;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192694;
  v_dados(v_dados.last()).vr_nrctremp := 313457;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192902;
  v_dados(v_dados.last()).vr_nrctremp := 87507;
  v_dados(v_dados.last()).vr_vllanmto := 5429.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192929;
  v_dados(v_dados.last()).vr_nrctremp := 351987;
  v_dados(v_dados.last()).vr_vllanmto := 18.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193240;
  v_dados(v_dados.last()).vr_nrctremp := 247072;
  v_dados(v_dados.last()).vr_vllanmto := 165.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193364;
  v_dados(v_dados.last()).vr_nrctremp := 306333;
  v_dados(v_dados.last()).vr_vllanmto := 73.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193518;
  v_dados(v_dados.last()).vr_nrctremp := 91698;
  v_dados(v_dados.last()).vr_vllanmto := 182.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 194042;
  v_dados(v_dados.last()).vr_nrctremp := 342119;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 196584;
  v_dados(v_dados.last()).vr_nrctremp := 302114;
  v_dados(v_dados.last()).vr_vllanmto := 387.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 200123;
  v_dados(v_dados.last()).vr_nrctremp := 268540;
  v_dados(v_dados.last()).vr_vllanmto := 12.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 201308;
  v_dados(v_dados.last()).vr_nrctremp := 241591;
  v_dados(v_dados.last()).vr_vllanmto := 20.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 201308;
  v_dados(v_dados.last()).vr_nrctremp := 347170;
  v_dados(v_dados.last()).vr_vllanmto := 20.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 206504;
  v_dados(v_dados.last()).vr_nrctremp := 309078;
  v_dados(v_dados.last()).vr_vllanmto := 12.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 206725;
  v_dados(v_dados.last()).vr_nrctremp := 353581;
  v_dados(v_dados.last()).vr_vllanmto := 15.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 207144;
  v_dados(v_dados.last()).vr_nrctremp := 264792;
  v_dados(v_dados.last()).vr_vllanmto := 14.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211524;
  v_dados(v_dados.last()).vr_nrctremp := 265988;
  v_dados(v_dados.last()).vr_vllanmto := 26.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 213063;
  v_dados(v_dados.last()).vr_nrctremp := 324131;
  v_dados(v_dados.last()).vr_vllanmto := 12.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 213365;
  v_dados(v_dados.last()).vr_nrctremp := 195606;
  v_dados(v_dados.last()).vr_vllanmto := 3623.45;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 214256;
  v_dados(v_dados.last()).vr_nrctremp := 228191;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 215864;
  v_dados(v_dados.last()).vr_nrctremp := 57728;
  v_dados(v_dados.last()).vr_vllanmto := 12.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 215902;
  v_dados(v_dados.last()).vr_nrctremp := 340858;
  v_dados(v_dados.last()).vr_vllanmto := 23106.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 216909;
  v_dados(v_dados.last()).vr_nrctremp := 316836;
  v_dados(v_dados.last()).vr_vllanmto := 20.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 218294;
  v_dados(v_dados.last()).vr_nrctremp := 342568;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 218448;
  v_dados(v_dados.last()).vr_nrctremp := 354190;
  v_dados(v_dados.last()).vr_vllanmto := 26.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 219223;
  v_dados(v_dados.last()).vr_nrctremp := 282054;
  v_dados(v_dados.last()).vr_vllanmto := 14.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 219428;
  v_dados(v_dados.last()).vr_nrctremp := 287865;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 219673;
  v_dados(v_dados.last()).vr_nrctremp := 252951;
  v_dados(v_dados.last()).vr_vllanmto := 10.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 222046;
  v_dados(v_dados.last()).vr_nrctremp := 292342;
  v_dados(v_dados.last()).vr_vllanmto := 513.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 222186;
  v_dados(v_dados.last()).vr_nrctremp := 324040;
  v_dados(v_dados.last()).vr_vllanmto := 19.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 224090;
  v_dados(v_dados.last()).vr_nrctremp := 287739;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 226327;
  v_dados(v_dados.last()).vr_nrctremp := 345163;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 227137;
  v_dados(v_dados.last()).vr_nrctremp := 307524;
  v_dados(v_dados.last()).vr_vllanmto := 26.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 229083;
  v_dados(v_dados.last()).vr_nrctremp := 288206;
  v_dados(v_dados.last()).vr_vllanmto := 792.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 231436;
  v_dados(v_dados.last()).vr_nrctremp := 295605;
  v_dados(v_dados.last()).vr_vllanmto := 298.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 231592;
  v_dados(v_dados.last()).vr_nrctremp := 134611;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 234117;
  v_dados(v_dados.last()).vr_nrctremp := 286386;
  v_dados(v_dados.last()).vr_vllanmto := 18.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 234346;
  v_dados(v_dados.last()).vr_nrctremp := 251505;
  v_dados(v_dados.last()).vr_vllanmto := 13.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 237752;
  v_dados(v_dados.last()).vr_nrctremp := 339433;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240133;
  v_dados(v_dados.last()).vr_nrctremp := 229691;
  v_dados(v_dados.last()).vr_vllanmto := 15.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 241652;
  v_dados(v_dados.last()).vr_nrctremp := 200267;
  v_dados(v_dados.last()).vr_vllanmto := 12.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 241938;
  v_dados(v_dados.last()).vr_nrctremp := 264227;
  v_dados(v_dados.last()).vr_vllanmto := 18.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141207;
  v_dados(v_dados.last()).vr_vllanmto := 1406.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242080;
  v_dados(v_dados.last()).vr_nrctremp := 141760;
  v_dados(v_dados.last()).vr_vllanmto := 313.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242136;
  v_dados(v_dados.last()).vr_nrctremp := 335316;
  v_dados(v_dados.last()).vr_vllanmto := 15.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 244783;
  v_dados(v_dados.last()).vr_nrctremp := 337205;
  v_dados(v_dados.last()).vr_vllanmto := 12.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 245402;
  v_dados(v_dados.last()).vr_nrctremp := 327781;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 247170;
  v_dados(v_dados.last()).vr_nrctremp := 341687;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 247596;
  v_dados(v_dados.last()).vr_nrctremp := 319391;
  v_dados(v_dados.last()).vr_vllanmto := 18.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 247618;
  v_dados(v_dados.last()).vr_nrctremp := 287608;
  v_dados(v_dados.last()).vr_vllanmto := 15.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 247642;
  v_dados(v_dados.last()).vr_nrctremp := 322556;
  v_dados(v_dados.last()).vr_vllanmto := 25.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248053;
  v_dados(v_dados.last()).vr_nrctremp := 319947;
  v_dados(v_dados.last()).vr_vllanmto := 10.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 105884;
  v_dados(v_dados.last()).vr_vllanmto := 4065.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 2351.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 249475;
  v_dados(v_dados.last()).vr_nrctremp := 291676;
  v_dados(v_dados.last()).vr_vllanmto := 15.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 253057;
  v_dados(v_dados.last()).vr_nrctremp := 94143;
  v_dados(v_dados.last()).vr_vllanmto := 1883.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 253510;
  v_dados(v_dados.last()).vr_nrctremp := 233903;
  v_dados(v_dados.last()).vr_vllanmto := 10.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 255300;
  v_dados(v_dados.last()).vr_nrctremp := 57141;
  v_dados(v_dados.last()).vr_vllanmto := 18010.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 255300;
  v_dados(v_dados.last()).vr_nrctremp := 358083;
  v_dados(v_dados.last()).vr_vllanmto := 15.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 257214;
  v_dados(v_dados.last()).vr_nrctremp := 145047;
  v_dados(v_dados.last()).vr_vllanmto := 14.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 260355;
  v_dados(v_dados.last()).vr_nrctremp := 229337;
  v_dados(v_dados.last()).vr_vllanmto := 18.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261122;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 100.56;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 50935;
  v_dados(v_dados.last()).vr_vllanmto := 72.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 192919;
  v_dados(v_dados.last()).vr_vllanmto := 22.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261580;
  v_dados(v_dados.last()).vr_nrctremp := 238468;
  v_dados(v_dados.last()).vr_vllanmto := 38.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261688;
  v_dados(v_dados.last()).vr_nrctremp := 291487;
  v_dados(v_dados.last()).vr_vllanmto := 16.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 262951;
  v_dados(v_dados.last()).vr_nrctremp := 330380;
  v_dados(v_dados.last()).vr_vllanmto := 21.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264032;
  v_dados(v_dados.last()).vr_nrctremp := 107394;
  v_dados(v_dados.last()).vr_vllanmto := 14.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264768;
  v_dados(v_dados.last()).vr_nrctremp := 322768;
  v_dados(v_dados.last()).vr_vllanmto := 20.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142242;
  v_dados(v_dados.last()).vr_vllanmto := 234.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 55.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 153126;
  v_dados(v_dados.last()).vr_vllanmto := 34.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 192497;
  v_dados(v_dados.last()).vr_vllanmto := 35.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 265187;
  v_dados(v_dados.last()).vr_nrctremp := 255306;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 266280;
  v_dados(v_dados.last()).vr_nrctremp := 332289;
  v_dados(v_dados.last()).vr_vllanmto := 10.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 267023;
  v_dados(v_dados.last()).vr_nrctremp := 341693;
  v_dados(v_dados.last()).vr_vllanmto := 14.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 269913;
  v_dados(v_dados.last()).vr_nrctremp := 68956;
  v_dados(v_dados.last()).vr_vllanmto := 1331.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 270741;
  v_dados(v_dados.last()).vr_nrctremp := 322206;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272094;
  v_dados(v_dados.last()).vr_nrctremp := 229581;
  v_dados(v_dados.last()).vr_vllanmto := 86.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272116;
  v_dados(v_dados.last()).vr_nrctremp := 252189;
  v_dados(v_dados.last()).vr_vllanmto := 705.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272361;
  v_dados(v_dados.last()).vr_nrctremp := 117990;
  v_dados(v_dados.last()).vr_vllanmto := 1134.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272361;
  v_dados(v_dados.last()).vr_nrctremp := 247428;
  v_dados(v_dados.last()).vr_vllanmto := 5047.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273309;
  v_dados(v_dados.last()).vr_nrctremp := 197758;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273724;
  v_dados(v_dados.last()).vr_nrctremp := 123203;
  v_dados(v_dados.last()).vr_vllanmto := 13.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273821;
  v_dados(v_dados.last()).vr_nrctremp := 296354;
  v_dados(v_dados.last()).vr_vllanmto := 66.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273970;
  v_dados(v_dados.last()).vr_nrctremp := 273508;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 274321;
  v_dados(v_dados.last()).vr_nrctremp := 166688;
  v_dados(v_dados.last()).vr_vllanmto := 10.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 275379;
  v_dados(v_dados.last()).vr_nrctremp := 262808;
  v_dados(v_dados.last()).vr_vllanmto := 15.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 198109;
  v_dados(v_dados.last()).vr_vllanmto := 35.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 278874;
  v_dados(v_dados.last()).vr_nrctremp := 346702;
  v_dados(v_dados.last()).vr_vllanmto := 12.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 279072;
  v_dados(v_dados.last()).vr_nrctremp := 342782;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 279072;
  v_dados(v_dados.last()).vr_nrctremp := 358228;
  v_dados(v_dados.last()).vr_vllanmto := 28.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 279293;
  v_dados(v_dados.last()).vr_nrctremp := 266531;
  v_dados(v_dados.last()).vr_vllanmto := 38.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 280836;
  v_dados(v_dados.last()).vr_nrctremp := 274491;
  v_dados(v_dados.last()).vr_vllanmto := 12.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 280844;
  v_dados(v_dados.last()).vr_nrctremp := 270046;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 282855;
  v_dados(v_dados.last()).vr_nrctremp := 299509;
  v_dados(v_dados.last()).vr_vllanmto := 16.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 285072;
  v_dados(v_dados.last()).vr_nrctremp := 320937;
  v_dados(v_dados.last()).vr_vllanmto := 13.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 286540;
  v_dados(v_dados.last()).vr_nrctremp := 356033;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287296;
  v_dados(v_dados.last()).vr_nrctremp := 261596;
  v_dados(v_dados.last()).vr_vllanmto := 17.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287784;
  v_dados(v_dados.last()).vr_nrctremp := 115984;
  v_dados(v_dados.last()).vr_vllanmto := 13.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287784;
  v_dados(v_dados.last()).vr_nrctremp := 336308;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 288322;
  v_dados(v_dados.last()).vr_nrctremp := 322754;
  v_dados(v_dados.last()).vr_vllanmto := 10.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 288640;
  v_dados(v_dados.last()).vr_nrctremp := 238673;
  v_dados(v_dados.last()).vr_vllanmto := 12.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289094;
  v_dados(v_dados.last()).vr_nrctremp := 227800;
  v_dados(v_dados.last()).vr_vllanmto := 2928.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289426;
  v_dados(v_dados.last()).vr_nrctremp := 321687;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 290785;
  v_dados(v_dados.last()).vr_nrctremp := 230651;
  v_dados(v_dados.last()).vr_vllanmto := 11.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 291854;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 3305.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 295159;
  v_dados(v_dados.last()).vr_nrctremp := 298273;
  v_dados(v_dados.last()).vr_vllanmto := 16.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 297283;
  v_dados(v_dados.last()).vr_nrctremp := 218923;
  v_dados(v_dados.last()).vr_vllanmto := 57.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 297453;
  v_dados(v_dados.last()).vr_nrctremp := 285312;
  v_dados(v_dados.last()).vr_vllanmto := 2365.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 298549;
  v_dados(v_dados.last()).vr_nrctremp := 306995;
  v_dados(v_dados.last()).vr_vllanmto := 11.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299090;
  v_dados(v_dados.last()).vr_nrctremp := 117044;
  v_dados(v_dados.last()).vr_vllanmto := 74.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299596;
  v_dados(v_dados.last()).vr_nrctremp := 266459;
  v_dados(v_dados.last()).vr_vllanmto := 208.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 76421;
  v_dados(v_dados.last()).vr_vllanmto := 3478.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 77074;
  v_dados(v_dados.last()).vr_vllanmto := 2236.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 318060;
  v_dados(v_dados.last()).vr_nrctremp := 338833;
  v_dados(v_dados.last()).vr_vllanmto := 16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 318612;
  v_dados(v_dados.last()).vr_nrctremp := 332981;
  v_dados(v_dados.last()).vr_vllanmto := 35.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 319880;
  v_dados(v_dados.last()).vr_nrctremp := 269381;
  v_dados(v_dados.last()).vr_vllanmto := 23.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 319880;
  v_dados(v_dados.last()).vr_nrctremp := 307965;
  v_dados(v_dados.last()).vr_vllanmto := 13.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 322369;
  v_dados(v_dados.last()).vr_nrctremp := 251569;
  v_dados(v_dados.last()).vr_vllanmto := 21.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 322890;
  v_dados(v_dados.last()).vr_nrctremp := 307689;
  v_dados(v_dados.last()).vr_vllanmto := 17.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 323004;
  v_dados(v_dados.last()).vr_nrctremp := 148733;
  v_dados(v_dados.last()).vr_vllanmto := 11.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 323004;
  v_dados(v_dados.last()).vr_nrctremp := 233112;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 323292;
  v_dados(v_dados.last()).vr_nrctremp := 310486;
  v_dados(v_dados.last()).vr_vllanmto := 24.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 325759;
  v_dados(v_dados.last()).vr_nrctremp := 277727;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 326305;
  v_dados(v_dados.last()).vr_nrctremp := 290966;
  v_dados(v_dados.last()).vr_vllanmto := 13.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 326305;
  v_dados(v_dados.last()).vr_nrctremp := 356062;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328014;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 1676.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328693;
  v_dados(v_dados.last()).vr_nrctremp := 254732;
  v_dados(v_dados.last()).vr_vllanmto := 27.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 329010;
  v_dados(v_dados.last()).vr_nrctremp := 277019;
  v_dados(v_dados.last()).vr_vllanmto := 21.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 331317;
  v_dados(v_dados.last()).vr_nrctremp := 343745;
  v_dados(v_dados.last()).vr_vllanmto := 10.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 334685;
  v_dados(v_dados.last()).vr_nrctremp := 111025;
  v_dados(v_dados.last()).vr_vllanmto := 362.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 336360;
  v_dados(v_dados.last()).vr_nrctremp := 357416;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 344192;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 4299.81;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 345814;
  v_dados(v_dados.last()).vr_nrctremp := 264176;
  v_dados(v_dados.last()).vr_vllanmto := 11.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 349054;
  v_dados(v_dados.last()).vr_nrctremp := 354299;
  v_dados(v_dados.last()).vr_vllanmto := 11.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 349798;
  v_dados(v_dados.last()).vr_nrctremp := 240715;
  v_dados(v_dados.last()).vr_vllanmto := 309.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350605;
  v_dados(v_dados.last()).vr_nrctremp := 233793;
  v_dados(v_dados.last()).vr_vllanmto := 10.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350893;
  v_dados(v_dados.last()).vr_nrctremp := 146914;
  v_dados(v_dados.last()).vr_vllanmto := 114.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350893;
  v_dados(v_dados.last()).vr_nrctremp := 240061;
  v_dados(v_dados.last()).vr_vllanmto := 42.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 351296;
  v_dados(v_dados.last()).vr_nrctremp := 207634;
  v_dados(v_dados.last()).vr_vllanmto := 13.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 359238;
  v_dados(v_dados.last()).vr_nrctremp := 274385;
  v_dados(v_dados.last()).vr_vllanmto := 342.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 361194;
  v_dados(v_dados.last()).vr_nrctremp := 308561;
  v_dados(v_dados.last()).vr_vllanmto := 10.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 362344;
  v_dados(v_dados.last()).vr_nrctremp := 303438;
  v_dados(v_dados.last()).vr_vllanmto := 20814.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 364037;
  v_dados(v_dados.last()).vr_nrctremp := 296728;
  v_dados(v_dados.last()).vr_vllanmto := 13.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 364533;
  v_dados(v_dados.last()).vr_nrctremp := 326821;
  v_dados(v_dados.last()).vr_vllanmto := 16.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 375349;
  v_dados(v_dados.last()).vr_nrctremp := 285247;
  v_dados(v_dados.last()).vr_vllanmto := 11.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376264;
  v_dados(v_dados.last()).vr_nrctremp := 353223;
  v_dados(v_dados.last()).vr_vllanmto := 28.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376264;
  v_dados(v_dados.last()).vr_nrctremp := 356861;
  v_dados(v_dados.last()).vr_vllanmto := 15.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376639;
  v_dados(v_dados.last()).vr_nrctremp := 359222;
  v_dados(v_dados.last()).vr_vllanmto := 12.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376744;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 10428.02;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 163160;
  v_dados(v_dados.last()).vr_vllanmto := 79.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 300625;
  v_dados(v_dados.last()).vr_vllanmto := 709.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 383007;
  v_dados(v_dados.last()).vr_nrctremp := 104758;
  v_dados(v_dados.last()).vr_vllanmto := 4752.22;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 384305;
  v_dados(v_dados.last()).vr_nrctremp := 232543;
  v_dados(v_dados.last()).vr_vllanmto := 11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 387282;
  v_dados(v_dados.last()).vr_nrctremp := 355408;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 387746;
  v_dados(v_dados.last()).vr_nrctremp := 351143;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 388181;
  v_dados(v_dados.last()).vr_nrctremp := 268428;
  v_dados(v_dados.last()).vr_vllanmto := 13.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 409570;
  v_dados(v_dados.last()).vr_nrctremp := 340173;
  v_dados(v_dados.last()).vr_vllanmto := 23.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 410047;
  v_dados(v_dados.last()).vr_nrctremp := 157762;
  v_dados(v_dados.last()).vr_vllanmto := 10.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 410977;
  v_dados(v_dados.last()).vr_nrctremp := 307659;
  v_dados(v_dados.last()).vr_vllanmto := 11.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 415383;
  v_dados(v_dados.last()).vr_nrctremp := 307818;
  v_dados(v_dados.last()).vr_vllanmto := 150.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 416606;
  v_dados(v_dados.last()).vr_nrctremp := 179261;
  v_dados(v_dados.last()).vr_vllanmto := 522.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 418307;
  v_dados(v_dados.last()).vr_nrctremp := 338255;
  v_dados(v_dados.last()).vr_vllanmto := 11519.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 418854;
  v_dados(v_dados.last()).vr_nrctremp := 196967;
  v_dados(v_dados.last()).vr_vllanmto := 107.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 3076.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 1155.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 421049;
  v_dados(v_dados.last()).vr_nrctremp := 267916;
  v_dados(v_dados.last()).vr_vllanmto := 12.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 421120;
  v_dados(v_dados.last()).vr_nrctremp := 342820;
  v_dados(v_dados.last()).vr_vllanmto := 19.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 421120;
  v_dados(v_dados.last()).vr_nrctremp := 343275;
  v_dados(v_dados.last()).vr_vllanmto := 19.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 421200;
  v_dados(v_dados.last()).vr_nrctremp := 237821;
  v_dados(v_dados.last()).vr_vllanmto := 11.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 426261;
  v_dados(v_dados.last()).vr_nrctremp := 255926;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 427420;
  v_dados(v_dados.last()).vr_nrctremp := 167789;
  v_dados(v_dados.last()).vr_vllanmto := 109.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 427420;
  v_dados(v_dados.last()).vr_nrctremp := 336549;
  v_dados(v_dados.last()).vr_vllanmto := 239.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 434957;
  v_dados(v_dados.last()).vr_nrctremp := 354744;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 435007;
  v_dados(v_dados.last()).vr_nrctremp := 343565;
  v_dados(v_dados.last()).vr_vllanmto := 14.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 435090;
  v_dados(v_dados.last()).vr_nrctremp := 305094;
  v_dados(v_dados.last()).vr_vllanmto := 49.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 438685;
  v_dados(v_dados.last()).vr_nrctremp := 305715;
  v_dados(v_dados.last()).vr_vllanmto := 13.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 441376;
  v_dados(v_dados.last()).vr_nrctremp := 62504;
  v_dados(v_dados.last()).vr_vllanmto := 13.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445517;
  v_dados(v_dados.last()).vr_nrctremp := 256438;
  v_dados(v_dados.last()).vr_vllanmto := 345.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 802.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 253030;
  v_dados(v_dados.last()).vr_vllanmto := 931.66;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445606;
  v_dados(v_dados.last()).vr_nrctremp := 296389;
  v_dados(v_dados.last()).vr_vllanmto := 13.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 448826;
  v_dados(v_dados.last()).vr_nrctremp := 346280;
  v_dados(v_dados.last()).vr_vllanmto := 52919.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 449806;
  v_dados(v_dados.last()).vr_nrctremp := 354083;
  v_dados(v_dados.last()).vr_vllanmto := 12.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 451088;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 2045.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 452602;
  v_dados(v_dados.last()).vr_nrctremp := 352555;
  v_dados(v_dados.last()).vr_vllanmto := 54.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 455849;
  v_dados(v_dados.last()).vr_nrctremp := 278103;
  v_dados(v_dados.last()).vr_vllanmto := 19.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 456551;
  v_dados(v_dados.last()).vr_nrctremp := 339309;
  v_dados(v_dados.last()).vr_vllanmto := 13.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 456560;
  v_dados(v_dados.last()).vr_nrctremp := 330485;
  v_dados(v_dados.last()).vr_vllanmto := 25.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 460303;
  v_dados(v_dados.last()).vr_nrctremp := 294436;
  v_dados(v_dados.last()).vr_vllanmto := 63.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 461709;
  v_dados(v_dados.last()).vr_nrctremp := 333085;
  v_dados(v_dados.last()).vr_vllanmto := 41.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 19.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 734.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462160;
  v_dados(v_dados.last()).vr_nrctremp := 321244;
  v_dados(v_dados.last()).vr_vllanmto := 15.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 463329;
  v_dados(v_dados.last()).vr_nrctremp := 269042;
  v_dados(v_dados.last()).vr_vllanmto := 76.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 465453;
  v_dados(v_dados.last()).vr_nrctremp := 349799;
  v_dados(v_dados.last()).vr_vllanmto := 12.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 466026;
  v_dados(v_dados.last()).vr_nrctremp := 197207;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 466026;
  v_dados(v_dados.last()).vr_nrctremp := 264011;
  v_dados(v_dados.last()).vr_vllanmto := 10.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 466026;
  v_dados(v_dados.last()).vr_nrctremp := 296358;
  v_dados(v_dados.last()).vr_vllanmto := 16.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467367;
  v_dados(v_dados.last()).vr_nrctremp := 149121;
  v_dados(v_dados.last()).vr_vllanmto := 77.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467367;
  v_dados(v_dados.last()).vr_nrctremp := 241384;
  v_dados(v_dados.last()).vr_vllanmto := 52.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467448;
  v_dados(v_dados.last()).vr_nrctremp := 73978;
  v_dados(v_dados.last()).vr_vllanmto := 213.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 467448;
  v_dados(v_dados.last()).vr_nrctremp := 116408;
  v_dados(v_dados.last()).vr_vllanmto := 67.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 471291;
  v_dados(v_dados.last()).vr_nrctremp := 282785;
  v_dados(v_dados.last()).vr_vllanmto := 66.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 475025;
  v_dados(v_dados.last()).vr_nrctremp := 319297;
  v_dados(v_dados.last()).vr_vllanmto := 14.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 479454;
  v_dados(v_dados.last()).vr_nrctremp := 305938;
  v_dados(v_dados.last()).vr_vllanmto := 27.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480517;
  v_dados(v_dados.last()).vr_nrctremp := 209089;
  v_dados(v_dados.last()).vr_vllanmto := 1445.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480568;
  v_dados(v_dados.last()).vr_nrctremp := 289660;
  v_dados(v_dados.last()).vr_vllanmto := 213.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 485217;
  v_dados(v_dados.last()).vr_nrctremp := 303855;
  v_dados(v_dados.last()).vr_vllanmto := 95.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 485217;
  v_dados(v_dados.last()).vr_nrctremp := 351293;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 486540;
  v_dados(v_dados.last()).vr_nrctremp := 355730;
  v_dados(v_dados.last()).vr_vllanmto := 11.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 486604;
  v_dados(v_dados.last()).vr_nrctremp := 360014;
  v_dados(v_dados.last()).vr_vllanmto := 15.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 493368;
  v_dados(v_dados.last()).vr_nrctremp := 241573;
  v_dados(v_dados.last()).vr_vllanmto := 13.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 493376;
  v_dados(v_dados.last()).vr_nrctremp := 304312;
  v_dados(v_dados.last()).vr_vllanmto := 25.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 494283;
  v_dados(v_dados.last()).vr_nrctremp := 358862;
  v_dados(v_dados.last()).vr_vllanmto := 13.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 495310;
  v_dados(v_dados.last()).vr_nrctremp := 313323;
  v_dados(v_dados.last()).vr_vllanmto := 20.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 497819;
  v_dados(v_dados.last()).vr_nrctremp := 313816;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 498297;
  v_dados(v_dados.last()).vr_nrctremp := 273326;
  v_dados(v_dados.last()).vr_vllanmto := 45.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 498815;
  v_dados(v_dados.last()).vr_nrctremp := 289873;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 499862;
  v_dados(v_dados.last()).vr_nrctremp := 202250;
  v_dados(v_dados.last()).vr_vllanmto := 21.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 499862;
  v_dados(v_dados.last()).vr_nrctremp := 242253;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 501786;
  v_dados(v_dados.last()).vr_nrctremp := 312885;
  v_dados(v_dados.last()).vr_vllanmto := 13.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 503789;
  v_dados(v_dados.last()).vr_nrctremp := 347017;
  v_dados(v_dados.last()).vr_vllanmto := 25.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 506427;
  v_dados(v_dados.last()).vr_nrctremp := 326992;
  v_dados(v_dados.last()).vr_vllanmto := 11.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 141142;
  v_dados(v_dados.last()).vr_vllanmto := 507.31;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 150785;
  v_dados(v_dados.last()).vr_vllanmto := 507.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 165366;
  v_dados(v_dados.last()).vr_vllanmto := 138.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 185908;
  v_dados(v_dados.last()).vr_vllanmto := 158.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 194673;
  v_dados(v_dados.last()).vr_vllanmto := 149.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 230274;
  v_dados(v_dados.last()).vr_vllanmto := 339.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 512958;
  v_dados(v_dados.last()).vr_nrctremp := 352152;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 516384;
  v_dados(v_dados.last()).vr_nrctremp := 307628;
  v_dados(v_dados.last()).vr_vllanmto := 37.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 517160;
  v_dados(v_dados.last()).vr_nrctremp := 306965;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 517399;
  v_dados(v_dados.last()).vr_nrctremp := 262464;
  v_dados(v_dados.last()).vr_vllanmto := 199.14;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 518573;
  v_dados(v_dados.last()).vr_nrctremp := 239737;
  v_dados(v_dados.last()).vr_vllanmto := 157.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521140;
  v_dados(v_dados.last()).vr_nrctremp := 254210;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521256;
  v_dados(v_dados.last()).vr_nrctremp := 338817;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521345;
  v_dados(v_dados.last()).vr_nrctremp := 358010;
  v_dados(v_dados.last()).vr_vllanmto := 24.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 523666;
  v_dados(v_dados.last()).vr_nrctremp := 336741;
  v_dados(v_dados.last()).vr_vllanmto := 28.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 10364.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 526789;
  v_dados(v_dados.last()).vr_nrctremp := 334314;
  v_dados(v_dados.last()).vr_vllanmto := 10.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 527491;
  v_dados(v_dados.last()).vr_nrctremp := 309972;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 532711;
  v_dados(v_dados.last()).vr_nrctremp := 216332;
  v_dados(v_dados.last()).vr_vllanmto := 251.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 532924;
  v_dados(v_dados.last()).vr_nrctremp := 288495;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 145861;
  v_dados(v_dados.last()).vr_vllanmto := 1622.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 253534;
  v_dados(v_dados.last()).vr_vllanmto := 398.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 534013;
  v_dados(v_dados.last()).vr_nrctremp := 290708;
  v_dados(v_dados.last()).vr_vllanmto := 903.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 535710;
  v_dados(v_dados.last()).vr_nrctremp := 283864;
  v_dados(v_dados.last()).vr_vllanmto := 28.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 539899;
  v_dados(v_dados.last()).vr_nrctremp := 250086;
  v_dados(v_dados.last()).vr_vllanmto := 2222.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 541311;
  v_dados(v_dados.last()).vr_nrctremp := 322034;
  v_dados(v_dados.last()).vr_vllanmto := 11.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 541567;
  v_dados(v_dados.last()).vr_nrctremp := 346343;
  v_dados(v_dados.last()).vr_vllanmto := 20.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 543144;
  v_dados(v_dados.last()).vr_nrctremp := 210362;
  v_dados(v_dados.last()).vr_vllanmto := 1233.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 543713;
  v_dados(v_dados.last()).vr_nrctremp := 357861;
  v_dados(v_dados.last()).vr_vllanmto := 16.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 544396;
  v_dados(v_dados.last()).vr_nrctremp := 349801;
  v_dados(v_dados.last()).vr_vllanmto := 25.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 546887;
  v_dados(v_dados.last()).vr_nrctremp := 248763;
  v_dados(v_dados.last()).vr_vllanmto := 50.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548685;
  v_dados(v_dados.last()).vr_nrctremp := 354062;
  v_dados(v_dados.last()).vr_vllanmto := 16.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 549266;
  v_dados(v_dados.last()).vr_nrctremp := 250370;
  v_dados(v_dados.last()).vr_vllanmto := 15.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 550108;
  v_dados(v_dados.last()).vr_nrctremp := 346405;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 551058;
  v_dados(v_dados.last()).vr_nrctremp := 300648;
  v_dados(v_dados.last()).vr_vllanmto := 598.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 551325;
  v_dados(v_dados.last()).vr_nrctremp := 328356;
  v_dados(v_dados.last()).vr_vllanmto := 12.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 551538;
  v_dados(v_dados.last()).vr_nrctremp := 261412;
  v_dados(v_dados.last()).vr_vllanmto := 1071.73;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 552488;
  v_dados(v_dados.last()).vr_nrctremp := 312583;
  v_dados(v_dados.last()).vr_vllanmto := 21.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 553964;
  v_dados(v_dados.last()).vr_nrctremp := 340506;
  v_dados(v_dados.last()).vr_vllanmto := 13.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 556254;
  v_dados(v_dados.last()).vr_nrctremp := 298087;
  v_dados(v_dados.last()).vr_vllanmto := 122.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 559865;
  v_dados(v_dados.last()).vr_nrctremp := 220482;
  v_dados(v_dados.last()).vr_vllanmto := 169.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 563498;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 1317.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565610;
  v_dados(v_dados.last()).vr_nrctremp := 287462;
  v_dados(v_dados.last()).vr_vllanmto := 18.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565849;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 920.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572314;
  v_dados(v_dados.last()).vr_nrctremp := 246657;
  v_dados(v_dados.last()).vr_vllanmto := 19.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572314;
  v_dados(v_dados.last()).vr_nrctremp := 346275;
  v_dados(v_dados.last()).vr_vllanmto := 12.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

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
  v_dados(v_dados.last()).vr_vllanmto := 4994.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 573027;
  v_dados(v_dados.last()).vr_nrctremp := 121298;
  v_dados(v_dados.last()).vr_vllanmto := 17.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 577090;
  v_dados(v_dados.last()).vr_nrctremp := 198976;
  v_dados(v_dados.last()).vr_vllanmto := 259.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 582042;
  v_dados(v_dados.last()).vr_nrctremp := 166819;
  v_dados(v_dados.last()).vr_vllanmto := 3907.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 585203;
  v_dados(v_dados.last()).vr_nrctremp := 279742;
  v_dados(v_dados.last()).vr_vllanmto := 11.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 585823;
  v_dados(v_dados.last()).vr_nrctremp := 356502;
  v_dados(v_dados.last()).vr_vllanmto := 11.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 585920;
  v_dados(v_dados.last()).vr_nrctremp := 299823;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 590169;
  v_dados(v_dados.last()).vr_nrctremp := 289199;
  v_dados(v_dados.last()).vr_vllanmto := 14.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 590983;
  v_dados(v_dados.last()).vr_nrctremp := 259371;
  v_dados(v_dados.last()).vr_vllanmto := 442.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 592781;
  v_dados(v_dados.last()).vr_nrctremp := 271052;
  v_dados(v_dados.last()).vr_vllanmto := 1916.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 599670;
  v_dados(v_dados.last()).vr_nrctremp := 315071;
  v_dados(v_dados.last()).vr_vllanmto := 10.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 601063;
  v_dados(v_dados.last()).vr_nrctremp := 261659;
  v_dados(v_dados.last()).vr_vllanmto := 16.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 606243;
  v_dados(v_dados.last()).vr_nrctremp := 346012;
  v_dados(v_dados.last()).vr_vllanmto := 26.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 606839;
  v_dados(v_dados.last()).vr_nrctremp := 337606;
  v_dados(v_dados.last()).vr_vllanmto := 15.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 607053;
  v_dados(v_dados.last()).vr_nrctremp := 299818;
  v_dados(v_dados.last()).vr_vllanmto := 28.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 610895;
  v_dados(v_dados.last()).vr_nrctremp := 227415;
  v_dados(v_dados.last()).vr_vllanmto := 2046.55;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 611301;
  v_dados(v_dados.last()).vr_nrctremp := 318423;
  v_dados(v_dados.last()).vr_vllanmto := 208.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 811.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 615366;
  v_dados(v_dados.last()).vr_nrctremp := 295571;
  v_dados(v_dados.last()).vr_vllanmto := 292.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 616346;
  v_dados(v_dados.last()).vr_nrctremp := 137941;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 616591;
  v_dados(v_dados.last()).vr_nrctremp := 339307;
  v_dados(v_dados.last()).vr_vllanmto := 10.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 618810;
  v_dados(v_dados.last()).vr_nrctremp := 244539;
  v_dados(v_dados.last()).vr_vllanmto := 40.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 620793;
  v_dados(v_dados.last()).vr_nrctremp := 275288;
  v_dados(v_dados.last()).vr_vllanmto := 13.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 625299;
  v_dados(v_dados.last()).vr_nrctremp := 256774;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 626368;
  v_dados(v_dados.last()).vr_nrctremp := 315289;
  v_dados(v_dados.last()).vr_vllanmto := 29.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 626368;
  v_dados(v_dados.last()).vr_nrctremp := 333794;
  v_dados(v_dados.last()).vr_vllanmto := 17.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 632937;
  v_dados(v_dados.last()).vr_nrctremp := 328288;
  v_dados(v_dados.last()).vr_vllanmto := 39.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638579;
  v_dados(v_dados.last()).vr_nrctremp := 250085;
  v_dados(v_dados.last()).vr_vllanmto := 348.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 639958;
  v_dados(v_dados.last()).vr_nrctremp := 240582;
  v_dados(v_dados.last()).vr_vllanmto := 293.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 641740;
  v_dados(v_dados.last()).vr_nrctremp := 327661;
  v_dados(v_dados.last()).vr_vllanmto := 25.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647527;
  v_dados(v_dados.last()).vr_nrctremp := 152360;
  v_dados(v_dados.last()).vr_vllanmto := 563.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647527;
  v_dados(v_dados.last()).vr_nrctremp := 191578;
  v_dados(v_dados.last()).vr_vllanmto := 507.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 647845;
  v_dados(v_dados.last()).vr_nrctremp := 192882;
  v_dados(v_dados.last()).vr_vllanmto := 1528.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 648418;
  v_dados(v_dados.last()).vr_nrctremp := 315699;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 648418;
  v_dados(v_dados.last()).vr_nrctremp := 319946;
  v_dados(v_dados.last()).vr_vllanmto := 19.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 648833;
  v_dados(v_dados.last()).vr_nrctremp := 260453;
  v_dados(v_dados.last()).vr_vllanmto := 89.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 649856;
  v_dados(v_dados.last()).vr_nrctremp := 259911;
  v_dados(v_dados.last()).vr_vllanmto := 40.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 650773;
  v_dados(v_dados.last()).vr_nrctremp := 209265;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 652610;
  v_dados(v_dados.last()).vr_nrctremp := 212819;
  v_dados(v_dados.last()).vr_vllanmto := 1264.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 662569;
  v_dados(v_dados.last()).vr_nrctremp := 160854;
  v_dados(v_dados.last()).vr_vllanmto := 139.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663930;
  v_dados(v_dados.last()).vr_nrctremp := 304608;
  v_dados(v_dados.last()).vr_vllanmto := 995.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663980;
  v_dados(v_dados.last()).vr_nrctremp := 335401;
  v_dados(v_dados.last()).vr_vllanmto := 12.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 666114;
  v_dados(v_dados.last()).vr_nrctremp := 297874;
  v_dados(v_dados.last()).vr_vllanmto := 21.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 667340;
  v_dados(v_dados.last()).vr_nrctremp := 293904;
  v_dados(v_dados.last()).vr_vllanmto := 50.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668680;
  v_dados(v_dados.last()).vr_nrctremp := 318751;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 669555;
  v_dados(v_dados.last()).vr_nrctremp := 313260;
  v_dados(v_dados.last()).vr_vllanmto := 100.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 672130;
  v_dados(v_dados.last()).vr_nrctremp := 166378;
  v_dados(v_dados.last()).vr_vllanmto := 12.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 677132;
  v_dados(v_dados.last()).vr_nrctremp := 170004;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 678856;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 5352.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 680818;
  v_dados(v_dados.last()).vr_nrctremp := 354556;
  v_dados(v_dados.last()).vr_vllanmto := 25.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 680940;
  v_dados(v_dados.last()).vr_nrctremp := 317433;
  v_dados(v_dados.last()).vr_vllanmto := 22.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 681105;
  v_dados(v_dados.last()).vr_nrctremp := 264146;
  v_dados(v_dados.last()).vr_vllanmto := 184.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 682292;
  v_dados(v_dados.last()).vr_nrctremp := 325886;
  v_dados(v_dados.last()).vr_vllanmto := 15.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 688274;
  v_dados(v_dados.last()).vr_nrctremp := 346567;
  v_dados(v_dados.last()).vr_vllanmto := 102.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 688274;
  v_dados(v_dados.last()).vr_nrctremp := 348179;
  v_dados(v_dados.last()).vr_vllanmto := 21.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 688274;
  v_dados(v_dados.last()).vr_nrctremp := 348225;
  v_dados(v_dados.last()).vr_vllanmto := 29.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 689211;
  v_dados(v_dados.last()).vr_nrctremp := 323684;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 689947;
  v_dados(v_dados.last()).vr_nrctremp := 313383;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 692328;
  v_dados(v_dados.last()).vr_nrctremp := 315004;
  v_dados(v_dados.last()).vr_vllanmto := 119.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 696374;
  v_dados(v_dados.last()).vr_nrctremp := 225993;
  v_dados(v_dados.last()).vr_vllanmto := 10.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 1327.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 292212;
  v_dados(v_dados.last()).vr_vllanmto := 674.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 699497;
  v_dados(v_dados.last()).vr_nrctremp := 229817;
  v_dados(v_dados.last()).vr_vllanmto := 15.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 701467;
  v_dados(v_dados.last()).vr_nrctremp := 327127;
  v_dados(v_dados.last()).vr_vllanmto := 16.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 701564;
  v_dados(v_dados.last()).vr_nrctremp := 351979;
  v_dados(v_dados.last()).vr_vllanmto := 36.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 702390;
  v_dados(v_dados.last()).vr_nrctremp := 240134;
  v_dados(v_dados.last()).vr_vllanmto := 37.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 703729;
  v_dados(v_dados.last()).vr_nrctremp := 358840;
  v_dados(v_dados.last()).vr_vllanmto := 15.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 705926;
  v_dados(v_dados.last()).vr_nrctremp := 245304;
  v_dados(v_dados.last()).vr_vllanmto := 1731.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 708607;
  v_dados(v_dados.last()).vr_nrctremp := 347990;
  v_dados(v_dados.last()).vr_vllanmto := 15.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 709972;
  v_dados(v_dados.last()).vr_nrctremp := 350023;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 713201;
  v_dados(v_dados.last()).vr_nrctremp := 352171;
  v_dados(v_dados.last()).vr_vllanmto := 18.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 716391;
  v_dados(v_dados.last()).vr_nrctremp := 285975;
  v_dados(v_dados.last()).vr_vllanmto := 61.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 718319;
  v_dados(v_dados.last()).vr_nrctremp := 186780;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 723452;
  v_dados(v_dados.last()).vr_nrctremp := 222216;
  v_dados(v_dados.last()).vr_vllanmto := 9116.4;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 735310;
  v_dados(v_dados.last()).vr_nrctremp := 289846;
  v_dados(v_dados.last()).vr_vllanmto := 13.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 740233;
  v_dados(v_dados.last()).vr_nrctremp := 340491;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 741370;
  v_dados(v_dados.last()).vr_nrctremp := 284004;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 741450;
  v_dados(v_dados.last()).vr_nrctremp := 344546;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 749630;
  v_dados(v_dados.last()).vr_nrctremp := 306964;
  v_dados(v_dados.last()).vr_vllanmto := 13.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 750271;
  v_dados(v_dados.last()).vr_nrctremp := 340723;
  v_dados(v_dados.last()).vr_vllanmto := 13.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 754528;
  v_dados(v_dados.last()).vr_nrctremp := 261384;
  v_dados(v_dados.last()).vr_vllanmto := 1629.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 756229;
  v_dados(v_dados.last()).vr_nrctremp := 349384;
  v_dados(v_dados.last()).vr_vllanmto := 17.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 764043;
  v_dados(v_dados.last()).vr_nrctremp := 338079;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 765465;
  v_dados(v_dados.last()).vr_nrctremp := 309224;
  v_dados(v_dados.last()).vr_vllanmto := 18.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 767310;
  v_dados(v_dados.last()).vr_nrctremp := 324166;
  v_dados(v_dados.last()).vr_vllanmto := 14.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 770124;
  v_dados(v_dados.last()).vr_nrctremp := 356398;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 779199;
  v_dados(v_dados.last()).vr_nrctremp := 342438;
  v_dados(v_dados.last()).vr_vllanmto := 15.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 786012;
  v_dados(v_dados.last()).vr_nrctremp := 359666;
  v_dados(v_dados.last()).vr_vllanmto := 13.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14135043;
  v_dados(v_dados.last()).vr_nrctremp := 303642;
  v_dados(v_dados.last()).vr_vllanmto := 794.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14154080;
  v_dados(v_dados.last()).vr_nrctremp := 291115;
  v_dados(v_dados.last()).vr_vllanmto := 244.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14185652;
  v_dados(v_dados.last()).vr_nrctremp := 331370;
  v_dados(v_dados.last()).vr_vllanmto := 10.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14224259;
  v_dados(v_dados.last()).vr_nrctremp := 176904;
  v_dados(v_dados.last()).vr_vllanmto := 1631.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14224259;
  v_dados(v_dados.last()).vr_nrctremp := 176905;
  v_dados(v_dados.last()).vr_vllanmto := 1574.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 241295;
  v_dados(v_dados.last()).vr_vllanmto := 2449.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 290158;
  v_dados(v_dados.last()).vr_vllanmto := 215.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14601524;
  v_dados(v_dados.last()).vr_nrctremp := 201815;
  v_dados(v_dados.last()).vr_vllanmto := 549.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14602733;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 1005.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14605325;
  v_dados(v_dados.last()).vr_nrctremp := 341943;
  v_dados(v_dados.last()).vr_vllanmto := 12.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14616084;
  v_dados(v_dados.last()).vr_nrctremp := 294867;
  v_dados(v_dados.last()).vr_vllanmto := 695.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14620294;
  v_dados(v_dados.last()).vr_nrctremp := 352891;
  v_dados(v_dados.last()).vr_vllanmto := 14.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14625660;
  v_dados(v_dados.last()).vr_nrctremp := 291689;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14682206;
  v_dados(v_dados.last()).vr_nrctremp := 286780;
  v_dados(v_dados.last()).vr_vllanmto := 96.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14722720;
  v_dados(v_dados.last()).vr_nrctremp := 200765;
  v_dados(v_dados.last()).vr_vllanmto := 2992.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14723220;
  v_dados(v_dados.last()).vr_nrctremp := 268898;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14725835;
  v_dados(v_dados.last()).vr_nrctremp := 198301;
  v_dados(v_dados.last()).vr_vllanmto := 11.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14740702;
  v_dados(v_dados.last()).vr_nrctremp := 225274;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14771675;
  v_dados(v_dados.last()).vr_nrctremp := 240186;
  v_dados(v_dados.last()).vr_vllanmto := 7667.31;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14792656;
  v_dados(v_dados.last()).vr_nrctremp := 234156;
  v_dados(v_dados.last()).vr_vllanmto := 1729.8;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14840324;
  v_dados(v_dados.last()).vr_nrctremp := 278852;
  v_dados(v_dados.last()).vr_vllanmto := 244.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14851199;
  v_dados(v_dados.last()).vr_nrctremp := 203894;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14914646;
  v_dados(v_dados.last()).vr_nrctremp := 353834;
  v_dados(v_dados.last()).vr_vllanmto := 15.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14922177;
  v_dados(v_dados.last()).vr_nrctremp := 359685;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 209246;
  v_dados(v_dados.last()).vr_vllanmto := 197.76;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 238463;
  v_dados(v_dados.last()).vr_vllanmto := 482.52;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 267064;
  v_dados(v_dados.last()).vr_vllanmto := 398.76;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15016935;
  v_dados(v_dados.last()).vr_nrctremp := 297585;
  v_dados(v_dados.last()).vr_vllanmto := 12.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 215815;
  v_dados(v_dados.last()).vr_vllanmto := 1554.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 219069;
  v_dados(v_dados.last()).vr_vllanmto := 1862.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15053075;
  v_dados(v_dados.last()).vr_nrctremp := 247863;
  v_dados(v_dados.last()).vr_vllanmto := 581;
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
  v_dados(v_dados.last()).vr_vllanmto := 287.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15108929;
  v_dados(v_dados.last()).vr_nrctremp := 330299;
  v_dados(v_dados.last()).vr_vllanmto := 11.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15133486;
  v_dados(v_dados.last()).vr_nrctremp := 297537;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15166201;
  v_dados(v_dados.last()).vr_nrctremp := 306790;
  v_dados(v_dados.last()).vr_vllanmto := 89.34;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15205681;
  v_dados(v_dados.last()).vr_nrctremp := 220654;
  v_dados(v_dados.last()).vr_vllanmto := 33.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15209199;
  v_dados(v_dados.last()).vr_nrctremp := 220834;
  v_dados(v_dados.last()).vr_vllanmto := 14.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15224945;
  v_dados(v_dados.last()).vr_nrctremp := 289503;
  v_dados(v_dados.last()).vr_vllanmto := 18.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15241882;
  v_dados(v_dados.last()).vr_nrctremp := 222548;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15245357;
  v_dados(v_dados.last()).vr_nrctremp := 222416;
  v_dados(v_dados.last()).vr_vllanmto := 23.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15266761;
  v_dados(v_dados.last()).vr_nrctremp := 305186;
  v_dados(v_dados.last()).vr_vllanmto := 125.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15273903;
  v_dados(v_dados.last()).vr_nrctremp := 339659;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15319954;
  v_dados(v_dados.last()).vr_nrctremp := 343433;
  v_dados(v_dados.last()).vr_vllanmto := 16.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15340805;
  v_dados(v_dados.last()).vr_nrctremp := 321201;
  v_dados(v_dados.last()).vr_vllanmto := 36.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15358933;
  v_dados(v_dados.last()).vr_nrctremp := 262210;
  v_dados(v_dados.last()).vr_vllanmto := 29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15377660;
  v_dados(v_dados.last()).vr_nrctremp := 280792;
  v_dados(v_dados.last()).vr_vllanmto := 1556.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15395286;
  v_dados(v_dados.last()).vr_nrctremp := 310314;
  v_dados(v_dados.last()).vr_vllanmto := 16.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 230219;
  v_dados(v_dados.last()).vr_vllanmto := 330.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 275871;
  v_dados(v_dados.last()).vr_vllanmto := 102.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15401790;
  v_dados(v_dados.last()).vr_nrctremp := 306655;
  v_dados(v_dados.last()).vr_vllanmto := 32.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15409007;
  v_dados(v_dados.last()).vr_nrctremp := 230711;
  v_dados(v_dados.last()).vr_vllanmto := 422.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15409007;
  v_dados(v_dados.last()).vr_nrctremp := 273783;
  v_dados(v_dados.last()).vr_vllanmto := 164.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15440125;
  v_dados(v_dados.last()).vr_nrctremp := 240660;
  v_dados(v_dados.last()).vr_vllanmto := 12354.62;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15455149;
  v_dados(v_dados.last()).vr_nrctremp := 348248;
  v_dados(v_dados.last()).vr_vllanmto := 20.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15459870;
  v_dados(v_dados.last()).vr_nrctremp := 327617;
  v_dados(v_dados.last()).vr_vllanmto := 21.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15501710;
  v_dados(v_dados.last()).vr_nrctremp := 265084;
  v_dados(v_dados.last()).vr_vllanmto := 213.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15541010;
  v_dados(v_dados.last()).vr_nrctremp := 314150;
  v_dados(v_dados.last()).vr_vllanmto := 515.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15544389;
  v_dados(v_dados.last()).vr_nrctremp := 282609;
  v_dados(v_dados.last()).vr_vllanmto := 22.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15548457;
  v_dados(v_dados.last()).vr_nrctremp := 255285;
  v_dados(v_dados.last()).vr_vllanmto := 42380.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15548457;
  v_dados(v_dados.last()).vr_nrctremp := 347606;
  v_dados(v_dados.last()).vr_vllanmto := 142955.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15577791;
  v_dados(v_dados.last()).vr_nrctremp := 238348;
  v_dados(v_dados.last()).vr_vllanmto := 27960.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15581322;
  v_dados(v_dados.last()).vr_nrctremp := 342817;
  v_dados(v_dados.last()).vr_vllanmto := 16.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15630960;
  v_dados(v_dados.last()).vr_nrctremp := 241402;
  v_dados(v_dados.last()).vr_vllanmto := 13.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15659933;
  v_dados(v_dados.last()).vr_nrctremp := 342141;
  v_dados(v_dados.last()).vr_vllanmto := 17.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15685233;
  v_dados(v_dados.last()).vr_nrctremp := 266075;
  v_dados(v_dados.last()).vr_vllanmto := 17943.3;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15710530;
  v_dados(v_dados.last()).vr_nrctremp := 288622;
  v_dados(v_dados.last()).vr_vllanmto := 250.51;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 245466;
  v_dados(v_dados.last()).vr_vllanmto := 1542.56;
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
  v_dados(v_dados.last()).vr_vllanmto := 66.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 295195;
  v_dados(v_dados.last()).vr_vllanmto := 481.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 298678;
  v_dados(v_dados.last()).vr_vllanmto := 352.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15742962;
  v_dados(v_dados.last()).vr_nrctremp := 252687;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15745619;
  v_dados(v_dados.last()).vr_nrctremp := 246681;
  v_dados(v_dados.last()).vr_vllanmto := 40.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15754634;
  v_dados(v_dados.last()).vr_nrctremp := 320296;
  v_dados(v_dados.last()).vr_vllanmto := 14.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15759970;
  v_dados(v_dados.last()).vr_nrctremp := 246683;
  v_dados(v_dados.last()).vr_vllanmto := 19.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15759970;
  v_dados(v_dados.last()).vr_nrctremp := 315005;
  v_dados(v_dados.last()).vr_vllanmto := 11.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15765482;
  v_dados(v_dados.last()).vr_nrctremp := 347437;
  v_dados(v_dados.last()).vr_vllanmto := 10.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15770630;
  v_dados(v_dados.last()).vr_nrctremp := 248940;
  v_dados(v_dados.last()).vr_vllanmto := 13.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15807363;
  v_dados(v_dados.last()).vr_nrctremp := 350165;
  v_dados(v_dados.last()).vr_vllanmto := 27.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15823822;
  v_dados(v_dados.last()).vr_nrctremp := 350345;
  v_dados(v_dados.last()).vr_vllanmto := 11.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15849309;
  v_dados(v_dados.last()).vr_nrctremp := 250564;
  v_dados(v_dados.last()).vr_vllanmto := 10.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15880940;
  v_dados(v_dados.last()).vr_nrctremp := 263864;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15889017;
  v_dados(v_dados.last()).vr_nrctremp := 305117;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15905756;
  v_dados(v_dados.last()).vr_nrctremp := 348250;
  v_dados(v_dados.last()).vr_vllanmto := 23.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15940349;
  v_dados(v_dados.last()).vr_nrctremp := 254682;
  v_dados(v_dados.last()).vr_vllanmto := 17517.05;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15956725;
  v_dados(v_dados.last()).vr_nrctremp := 337673;
  v_dados(v_dados.last()).vr_vllanmto := 23028.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15975177;
  v_dados(v_dados.last()).vr_nrctremp := 256196;
  v_dados(v_dados.last()).vr_vllanmto := 16.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15979580;
  v_dados(v_dados.last()).vr_nrctremp := 342611;
  v_dados(v_dados.last()).vr_vllanmto := 13.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16007174;
  v_dados(v_dados.last()).vr_nrctremp := 257774;
  v_dados(v_dados.last()).vr_vllanmto := 21.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16013859;
  v_dados(v_dados.last()).vr_nrctremp := 280042;
  v_dados(v_dados.last()).vr_vllanmto := 36.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16018311;
  v_dados(v_dados.last()).vr_nrctremp := 258541;
  v_dados(v_dados.last()).vr_vllanmto := 69.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16036301;
  v_dados(v_dados.last()).vr_nrctremp := 260828;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16095260;
  v_dados(v_dados.last()).vr_nrctremp := 262218;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16118790;
  v_dados(v_dados.last()).vr_nrctremp := 264780;
  v_dados(v_dados.last()).vr_vllanmto := 1329.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16148312;
  v_dados(v_dados.last()).vr_nrctremp := 264341;
  v_dados(v_dados.last()).vr_vllanmto := 10.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16158660;
  v_dados(v_dados.last()).vr_nrctremp := 264849;
  v_dados(v_dados.last()).vr_vllanmto := 24.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16158660;
  v_dados(v_dados.last()).vr_nrctremp := 303854;
  v_dados(v_dados.last()).vr_vllanmto := 16.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16160550;
  v_dados(v_dados.last()).vr_nrctremp := 314110;
  v_dados(v_dados.last()).vr_vllanmto := 36.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16190793;
  v_dados(v_dados.last()).vr_nrctremp := 280221;
  v_dados(v_dados.last()).vr_vllanmto := 20.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16190793;
  v_dados(v_dados.last()).vr_nrctremp := 350950;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16200780;
  v_dados(v_dados.last()).vr_nrctremp := 353132;
  v_dados(v_dados.last()).vr_vllanmto := 13.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16206398;
  v_dados(v_dados.last()).vr_nrctremp := 305786;
  v_dados(v_dados.last()).vr_vllanmto := 10.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16210107;
  v_dados(v_dados.last()).vr_nrctremp := 276225;
  v_dados(v_dados.last()).vr_vllanmto := 130.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16216628;
  v_dados(v_dados.last()).vr_nrctremp := 272673;
  v_dados(v_dados.last()).vr_vllanmto := 28789.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16222091;
  v_dados(v_dados.last()).vr_nrctremp := 313705;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16222105;
  v_dados(v_dados.last()).vr_nrctremp := 283548;
  v_dados(v_dados.last()).vr_vllanmto := 12.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16230396;
  v_dados(v_dados.last()).vr_nrctremp := 267618;
  v_dados(v_dados.last()).vr_vllanmto := 18.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16235843;
  v_dados(v_dados.last()).vr_nrctremp := 267821;
  v_dados(v_dados.last()).vr_vllanmto := 20.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16244826;
  v_dados(v_dados.last()).vr_nrctremp := 267932;
  v_dados(v_dados.last()).vr_vllanmto := 21.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16250559;
  v_dados(v_dados.last()).vr_nrctremp := 281788;
  v_dados(v_dados.last()).vr_vllanmto := 12893.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16255054;
  v_dados(v_dados.last()).vr_nrctremp := 298283;
  v_dados(v_dados.last()).vr_vllanmto := 10.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16257324;
  v_dados(v_dados.last()).vr_nrctremp := 268640;
  v_dados(v_dados.last()).vr_vllanmto := 1864.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16281012;
  v_dados(v_dados.last()).vr_nrctremp := 319401;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16297520;
  v_dados(v_dados.last()).vr_nrctremp := 357300;
  v_dados(v_dados.last()).vr_vllanmto := 33.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16337760;
  v_dados(v_dados.last()).vr_nrctremp := 286889;
  v_dados(v_dados.last()).vr_vllanmto := 465.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16350430;
  v_dados(v_dados.last()).vr_nrctremp := 279936;
  v_dados(v_dados.last()).vr_vllanmto := 55.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16350430;
  v_dados(v_dados.last()).vr_nrctremp := 280386;
  v_dados(v_dados.last()).vr_vllanmto := 26.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16395115;
  v_dados(v_dados.last()).vr_nrctremp := 338759;
  v_dados(v_dados.last()).vr_vllanmto := 12.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16400445;
  v_dados(v_dados.last()).vr_nrctremp := 327448;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16411536;
  v_dados(v_dados.last()).vr_nrctremp := 274828;
  v_dados(v_dados.last()).vr_vllanmto := 27603.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16416546;
  v_dados(v_dados.last()).vr_nrctremp := 332260;
  v_dados(v_dados.last()).vr_vllanmto := 10.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16440226;
  v_dados(v_dados.last()).vr_nrctremp := 276387;
  v_dados(v_dados.last()).vr_vllanmto := 24.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16441974;
  v_dados(v_dados.last()).vr_nrctremp := 276164;
  v_dados(v_dados.last()).vr_vllanmto := 14.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16443721;
  v_dados(v_dados.last()).vr_nrctremp := 339934;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16445244;
  v_dados(v_dados.last()).vr_nrctremp := 276311;
  v_dados(v_dados.last()).vr_vllanmto := 13.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16448057;
  v_dados(v_dados.last()).vr_nrctremp := 276346;
  v_dados(v_dados.last()).vr_vllanmto := 42871;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278653;
  v_dados(v_dados.last()).vr_vllanmto := 33.46;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 2074.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16491130;
  v_dados(v_dados.last()).vr_nrctremp := 278584;
  v_dados(v_dados.last()).vr_vllanmto := 10.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16530667;
  v_dados(v_dados.last()).vr_nrctremp := 279611;
  v_dados(v_dados.last()).vr_vllanmto := 1272.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16539311;
  v_dados(v_dados.last()).vr_nrctremp := 280213;
  v_dados(v_dados.last()).vr_vllanmto := 41.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16539311;
  v_dados(v_dados.last()).vr_nrctremp := 303129;
  v_dados(v_dados.last()).vr_vllanmto := 12.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16539311;
  v_dados(v_dados.last()).vr_nrctremp := 358358;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16561031;
  v_dados(v_dados.last()).vr_nrctremp := 295168;
  v_dados(v_dados.last()).vr_vllanmto := 18.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16574397;
  v_dados(v_dados.last()).vr_nrctremp := 338716;
  v_dados(v_dados.last()).vr_vllanmto := 10.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16596188;
  v_dados(v_dados.last()).vr_nrctremp := 282370;
  v_dados(v_dados.last()).vr_vllanmto := 12.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16596544;
  v_dados(v_dados.last()).vr_nrctremp := 353613;
  v_dados(v_dados.last()).vr_vllanmto := 15.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16604423;
  v_dados(v_dados.last()).vr_nrctremp := 282908;
  v_dados(v_dados.last()).vr_vllanmto := 27.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16624068;
  v_dados(v_dados.last()).vr_nrctremp := 323318;
  v_dados(v_dados.last()).vr_vllanmto := 12.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16643470;
  v_dados(v_dados.last()).vr_nrctremp := 285851;
  v_dados(v_dados.last()).vr_vllanmto := 12.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16706382;
  v_dados(v_dados.last()).vr_nrctremp := 287145;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16714318;
  v_dados(v_dados.last()).vr_nrctremp := 286841;
  v_dados(v_dados.last()).vr_vllanmto := 11.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16738586;
  v_dados(v_dados.last()).vr_nrctremp := 287882;
  v_dados(v_dados.last()).vr_vllanmto := 10.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16744349;
  v_dados(v_dados.last()).vr_nrctremp := 288036;
  v_dados(v_dados.last()).vr_vllanmto := 200.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16744349;
  v_dados(v_dados.last()).vr_nrctremp := 302386;
  v_dados(v_dados.last()).vr_vllanmto := 276.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16746090;
  v_dados(v_dados.last()).vr_nrctremp := 288570;
  v_dados(v_dados.last()).vr_vllanmto := 15.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16766245;
  v_dados(v_dados.last()).vr_nrctremp := 345132;
  v_dados(v_dados.last()).vr_vllanmto := 15.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16772814;
  v_dados(v_dados.last()).vr_nrctremp := 327530;
  v_dados(v_dados.last()).vr_vllanmto := 21.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16791517;
  v_dados(v_dados.last()).vr_nrctremp := 313594;
  v_dados(v_dados.last()).vr_vllanmto := 12.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16796578;
  v_dados(v_dados.last()).vr_nrctremp := 290817;
  v_dados(v_dados.last()).vr_vllanmto := 89.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16829417;
  v_dados(v_dados.last()).vr_nrctremp := 291230;
  v_dados(v_dados.last()).vr_vllanmto := 30.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16861566;
  v_dados(v_dados.last()).vr_nrctremp := 292409;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16884574;
  v_dados(v_dados.last()).vr_nrctremp := 296003;
  v_dados(v_dados.last()).vr_vllanmto := 17.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16889045;
  v_dados(v_dados.last()).vr_nrctremp := 293529;
  v_dados(v_dados.last()).vr_vllanmto := 35.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16900219;
  v_dados(v_dados.last()).vr_nrctremp := 312918;
  v_dados(v_dados.last()).vr_vllanmto := 20.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16904974;
  v_dados(v_dados.last()).vr_nrctremp := 338282;
  v_dados(v_dados.last()).vr_vllanmto := 10.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16912233;
  v_dados(v_dados.last()).vr_nrctremp := 300294;
  v_dados(v_dados.last()).vr_vllanmto := 35.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16919882;
  v_dados(v_dados.last()).vr_nrctremp := 294398;
  v_dados(v_dados.last()).vr_vllanmto := 1185.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16954327;
  v_dados(v_dados.last()).vr_nrctremp := 327658;
  v_dados(v_dados.last()).vr_vllanmto := 27.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16956923;
  v_dados(v_dados.last()).vr_nrctremp := 295725;
  v_dados(v_dados.last()).vr_vllanmto := 16.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16957466;
  v_dados(v_dados.last()).vr_nrctremp := 296998;
  v_dados(v_dados.last()).vr_vllanmto := 10.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16957962;
  v_dados(v_dados.last()).vr_nrctremp := 295964;
  v_dados(v_dados.last()).vr_vllanmto := 20.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16998626;
  v_dados(v_dados.last()).vr_nrctremp := 326258;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16998626;
  v_dados(v_dados.last()).vr_nrctremp := 350150;
  v_dados(v_dados.last()).vr_vllanmto := 12.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17006325;
  v_dados(v_dados.last()).vr_nrctremp := 336516;
  v_dados(v_dados.last()).vr_vllanmto := 14.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17022428;
  v_dados(v_dados.last()).vr_nrctremp := 343806;
  v_dados(v_dados.last()).vr_vllanmto := 10.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17028205;
  v_dados(v_dados.last()).vr_nrctremp := 331935;
  v_dados(v_dados.last()).vr_vllanmto := 10.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17035856;
  v_dados(v_dados.last()).vr_nrctremp := 312550;
  v_dados(v_dados.last()).vr_vllanmto := 357.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17043441;
  v_dados(v_dados.last()).vr_nrctremp := 298796;
  v_dados(v_dados.last()).vr_vllanmto := 90677.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17048958;
  v_dados(v_dados.last()).vr_nrctremp := 318419;
  v_dados(v_dados.last()).vr_vllanmto := 397.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17056462;
  v_dados(v_dados.last()).vr_nrctremp := 316770;
  v_dados(v_dados.last()).vr_vllanmto := 29.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17058724;
  v_dados(v_dados.last()).vr_nrctremp := 299370;
  v_dados(v_dados.last()).vr_vllanmto := 13.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17093163;
  v_dados(v_dados.last()).vr_nrctremp := 337793;
  v_dados(v_dados.last()).vr_vllanmto := 14.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17100275;
  v_dados(v_dados.last()).vr_nrctremp := 304869;
  v_dados(v_dados.last()).vr_vllanmto := 14.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17118433;
  v_dados(v_dados.last()).vr_nrctremp := 301392;
  v_dados(v_dados.last()).vr_vllanmto := 12.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17136733;
  v_dados(v_dados.last()).vr_nrctremp := 302270;
  v_dados(v_dados.last()).vr_vllanmto := 1655.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17146780;
  v_dados(v_dados.last()).vr_nrctremp := 326978;
  v_dados(v_dados.last()).vr_vllanmto := 45652.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17177120;
  v_dados(v_dados.last()).vr_nrctremp := 303303;
  v_dados(v_dados.last()).vr_vllanmto := 36.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17223849;
  v_dados(v_dados.last()).vr_nrctremp := 304842;
  v_dados(v_dados.last()).vr_vllanmto := 10.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17269598;
  v_dados(v_dados.last()).vr_nrctremp := 308749;
  v_dados(v_dados.last()).vr_vllanmto := 41.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17345871;
  v_dados(v_dados.last()).vr_nrctremp := 311394;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17345880;
  v_dados(v_dados.last()).vr_nrctremp := 309336;
  v_dados(v_dados.last()).vr_vllanmto := 512.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17357225;
  v_dados(v_dados.last()).vr_nrctremp := 309800;
  v_dados(v_dados.last()).vr_vllanmto := 13.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17381452;
  v_dados(v_dados.last()).vr_nrctremp := 312637;
  v_dados(v_dados.last()).vr_vllanmto := 11.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17409829;
  v_dados(v_dados.last()).vr_nrctremp := 312025;
  v_dados(v_dados.last()).vr_vllanmto := 10.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17444012;
  v_dados(v_dados.last()).vr_nrctremp := 315537;
  v_dados(v_dados.last()).vr_vllanmto := 21.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17444012;
  v_dados(v_dados.last()).vr_nrctremp := 356639;
  v_dados(v_dados.last()).vr_vllanmto := 15.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17456282;
  v_dados(v_dados.last()).vr_nrctremp := 314605;
  v_dados(v_dados.last()).vr_vllanmto := 13.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17456282;
  v_dados(v_dados.last()).vr_nrctremp := 323717;
  v_dados(v_dados.last()).vr_vllanmto := 12.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17460506;
  v_dados(v_dados.last()).vr_nrctremp := 353895;
  v_dados(v_dados.last()).vr_vllanmto := 10.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17476348;
  v_dados(v_dados.last()).vr_nrctremp := 319165;
  v_dados(v_dados.last()).vr_vllanmto := 20.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17477824;
  v_dados(v_dados.last()).vr_nrctremp := 350847;
  v_dados(v_dados.last()).vr_vllanmto := 849.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17482984;
  v_dados(v_dados.last()).vr_nrctremp := 317294;
  v_dados(v_dados.last()).vr_vllanmto := 19.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17512379;
  v_dados(v_dados.last()).vr_nrctremp := 317861;
  v_dados(v_dados.last()).vr_vllanmto := 17.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17521963;
  v_dados(v_dados.last()).vr_nrctremp := 316349;
  v_dados(v_dados.last()).vr_vllanmto := 17.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17537045;
  v_dados(v_dados.last()).vr_nrctremp := 354747;
  v_dados(v_dados.last()).vr_vllanmto := 13.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17547415;
  v_dados(v_dados.last()).vr_nrctremp := 322170;
  v_dados(v_dados.last()).vr_vllanmto := 14.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17598486;
  v_dados(v_dados.last()).vr_nrctremp := 331905;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17599296;
  v_dados(v_dados.last()).vr_nrctremp := 321686;
  v_dados(v_dados.last()).vr_vllanmto := 11.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17599296;
  v_dados(v_dados.last()).vr_nrctremp := 326594;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17617731;
  v_dados(v_dados.last()).vr_nrctremp := 346203;
  v_dados(v_dados.last()).vr_vllanmto := 15.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17622182;
  v_dados(v_dados.last()).vr_nrctremp := 320697;
  v_dados(v_dados.last()).vr_vllanmto := 26.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17623278;
  v_dados(v_dados.last()).vr_nrctremp := 333073;
  v_dados(v_dados.last()).vr_vllanmto := 18.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17631769;
  v_dados(v_dados.last()).vr_nrctremp := 320008;
  v_dados(v_dados.last()).vr_vllanmto := 10.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17632099;
  v_dados(v_dados.last()).vr_nrctremp := 357985;
  v_dados(v_dados.last()).vr_vllanmto := 10.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17633591;
  v_dados(v_dados.last()).vr_nrctremp := 328134;
  v_dados(v_dados.last()).vr_vllanmto := 13.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17633591;
  v_dados(v_dados.last()).vr_nrctremp := 355755;
  v_dados(v_dados.last()).vr_vllanmto := 94.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17640814;
  v_dados(v_dados.last()).vr_nrctremp := 347263;
  v_dados(v_dados.last()).vr_vllanmto := 31.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17660254;
  v_dados(v_dados.last()).vr_nrctremp := 321404;
  v_dados(v_dados.last()).vr_vllanmto := 10.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17722799;
  v_dados(v_dados.last()).vr_nrctremp := 327477;
  v_dados(v_dados.last()).vr_vllanmto := 31.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17722799;
  v_dados(v_dados.last()).vr_nrctremp := 327479;
  v_dados(v_dados.last()).vr_vllanmto := 24.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17729521;
  v_dados(v_dados.last()).vr_nrctremp := 323638;
  v_dados(v_dados.last()).vr_vllanmto := 20.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17734525;
  v_dados(v_dados.last()).vr_nrctremp := 323823;
  v_dados(v_dados.last()).vr_vllanmto := 22.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17742536;
  v_dados(v_dados.last()).vr_nrctremp := 326231;
  v_dados(v_dados.last()).vr_vllanmto := 22.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17765340;
  v_dados(v_dados.last()).vr_nrctremp := 348752;
  v_dados(v_dados.last()).vr_vllanmto := 30.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17769787;
  v_dados(v_dados.last()).vr_nrctremp := 330116;
  v_dados(v_dados.last()).vr_vllanmto := 27.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17769787;
  v_dados(v_dados.last()).vr_nrctremp := 330118;
  v_dados(v_dados.last()).vr_vllanmto := 20.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17769787;
  v_dados(v_dados.last()).vr_nrctremp := 330865;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17772915;
  v_dados(v_dados.last()).vr_nrctremp := 328581;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17808529;
  v_dados(v_dados.last()).vr_nrctremp := 326677;
  v_dados(v_dados.last()).vr_vllanmto := 12.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17816319;
  v_dados(v_dados.last()).vr_nrctremp := 327040;
  v_dados(v_dados.last()).vr_vllanmto := 22.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17816432;
  v_dados(v_dados.last()).vr_nrctremp := 337979;
  v_dados(v_dados.last()).vr_vllanmto := 12.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17829402;
  v_dados(v_dados.last()).vr_nrctremp := 330208;
  v_dados(v_dados.last()).vr_vllanmto := 10.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17829402;
  v_dados(v_dados.last()).vr_nrctremp := 340353;
  v_dados(v_dados.last()).vr_vllanmto := 36.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17839017;
  v_dados(v_dados.last()).vr_nrctremp := 332387;
  v_dados(v_dados.last()).vr_vllanmto := 19.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17841771;
  v_dados(v_dados.last()).vr_nrctremp := 354319;
  v_dados(v_dados.last()).vr_vllanmto := 32.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17884268;
  v_dados(v_dados.last()).vr_nrctremp := 335291;
  v_dados(v_dados.last()).vr_vllanmto := 18.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17884268;
  v_dados(v_dados.last()).vr_nrctremp := 338134;
  v_dados(v_dados.last()).vr_vllanmto := 17.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17908213;
  v_dados(v_dados.last()).vr_nrctremp := 340515;
  v_dados(v_dados.last()).vr_vllanmto := 26.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17908213;
  v_dados(v_dados.last()).vr_nrctremp := 340529;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17915007;
  v_dados(v_dados.last()).vr_nrctremp := 330565;
  v_dados(v_dados.last()).vr_vllanmto := 19.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17964750;
  v_dados(v_dados.last()).vr_nrctremp := 335453;
  v_dados(v_dados.last()).vr_vllanmto := 36.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17987300;
  v_dados(v_dados.last()).vr_nrctremp := 333328;
  v_dados(v_dados.last()).vr_vllanmto := 30.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17987300;
  v_dados(v_dados.last()).vr_nrctremp := 341874;
  v_dados(v_dados.last()).vr_vllanmto := 12.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18019986;
  v_dados(v_dados.last()).vr_nrctremp := 351867;
  v_dados(v_dados.last()).vr_vllanmto := 19.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18156487;
  v_dados(v_dados.last()).vr_nrctremp := 339580;
  v_dados(v_dados.last()).vr_vllanmto := 15.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18163866;
  v_dados(v_dados.last()).vr_nrctremp := 341420;
  v_dados(v_dados.last()).vr_vllanmto := 10.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18236685;
  v_dados(v_dados.last()).vr_nrctremp := 344786;
  v_dados(v_dados.last()).vr_vllanmto := 11.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18240720;
  v_dados(v_dados.last()).vr_nrctremp := 351759;
  v_dados(v_dados.last()).vr_vllanmto := 25.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18268650;
  v_dados(v_dados.last()).vr_nrctremp := 344382;
  v_dados(v_dados.last()).vr_vllanmto := 16.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18347436;
  v_dados(v_dados.last()).vr_nrctremp := 346490;
  v_dados(v_dados.last()).vr_vllanmto := 16.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18358063;
  v_dados(v_dados.last()).vr_nrctremp := 346686;
  v_dados(v_dados.last()).vr_vllanmto := 16.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18377130;
  v_dados(v_dados.last()).vr_nrctremp := 347382;
  v_dados(v_dados.last()).vr_vllanmto := 12.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18392989;
  v_dados(v_dados.last()).vr_nrctremp := 348327;
  v_dados(v_dados.last()).vr_vllanmto := 14.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18392989;
  v_dados(v_dados.last()).vr_nrctremp := 348330;
  v_dados(v_dados.last()).vr_vllanmto := 10.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18393519;
  v_dados(v_dados.last()).vr_nrctremp := 347757;
  v_dados(v_dados.last()).vr_vllanmto := 12.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18405517;
  v_dados(v_dados.last()).vr_nrctremp := 357431;
  v_dados(v_dados.last()).vr_vllanmto := 41.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18408028;
  v_dados(v_dados.last()).vr_nrctremp := 355393;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18418279;
  v_dados(v_dados.last()).vr_nrctremp := 348986;
  v_dados(v_dados.last()).vr_vllanmto := 17.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18424732;
  v_dados(v_dados.last()).vr_nrctremp := 348879;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18443354;
  v_dados(v_dados.last()).vr_nrctremp := 356983;
  v_dados(v_dados.last()).vr_vllanmto := 104185.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18455085;
  v_dados(v_dados.last()).vr_nrctremp := 350156;
  v_dados(v_dados.last()).vr_vllanmto := 18.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18472524;
  v_dados(v_dados.last()).vr_nrctremp := 358066;
  v_dados(v_dados.last()).vr_vllanmto := 24.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18479804;
  v_dados(v_dados.last()).vr_nrctremp := 350688;
  v_dados(v_dados.last()).vr_vllanmto := 16696.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18479804;
  v_dados(v_dados.last()).vr_nrctremp := 350692;
  v_dados(v_dados.last()).vr_vllanmto := 17393.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18479804;
  v_dados(v_dados.last()).vr_nrctremp := 350695;
  v_dados(v_dados.last()).vr_vllanmto := 12801.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18479804;
  v_dados(v_dados.last()).vr_nrctremp := 358982;
  v_dados(v_dados.last()).vr_vllanmto := 27.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18522130;
  v_dados(v_dados.last()).vr_nrctremp := 351974;
  v_dados(v_dados.last()).vr_vllanmto := 10.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18529887;
  v_dados(v_dados.last()).vr_nrctremp := 354594;
  v_dados(v_dados.last()).vr_vllanmto := 33.77;
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
  v_dados(v_dados.last()).vr_nrdconta := 18540520;
  v_dados(v_dados.last()).vr_nrctremp := 359184;
  v_dados(v_dados.last()).vr_vllanmto := 11.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18547419;
  v_dados(v_dados.last()).vr_nrctremp := 357313;
  v_dados(v_dados.last()).vr_vllanmto := 17.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18548563;
  v_dados(v_dados.last()).vr_nrctremp := 352939;
  v_dados(v_dados.last()).vr_vllanmto := 16.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18550231;
  v_dados(v_dados.last()).vr_nrctremp := 354263;
  v_dados(v_dados.last()).vr_vllanmto := 36.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18554725;
  v_dados(v_dados.last()).vr_nrctremp := 354604;
  v_dados(v_dados.last()).vr_vllanmto := 20.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18578721;
  v_dados(v_dados.last()).vr_nrctremp := 353931;
  v_dados(v_dados.last()).vr_vllanmto := 45.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18578926;
  v_dados(v_dados.last()).vr_nrctremp := 354155;
  v_dados(v_dados.last()).vr_vllanmto := 16.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18578926;
  v_dados(v_dados.last()).vr_nrctremp := 354162;
  v_dados(v_dados.last()).vr_vllanmto := 11.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18600921;
  v_dados(v_dados.last()).vr_nrctremp := 354971;
  v_dados(v_dados.last()).vr_vllanmto := 89462.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18600921;
  v_dados(v_dados.last()).vr_nrctremp := 358739;
  v_dados(v_dados.last()).vr_vllanmto := 37.15;
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
  v_dados(v_dados.last()).vr_nrdconta := 18620736;
  v_dados(v_dados.last()).vr_nrctremp := 355663;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18623972;
  v_dados(v_dados.last()).vr_nrctremp := 356105;
  v_dados(v_dados.last()).vr_vllanmto := 10.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18633625;
  v_dados(v_dados.last()).vr_nrctremp := 356379;
  v_dados(v_dados.last()).vr_vllanmto := 13.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18652956;
  v_dados(v_dados.last()).vr_nrctremp := 358955;
  v_dados(v_dados.last()).vr_vllanmto := 17.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18657184;
  v_dados(v_dados.last()).vr_nrctremp := 358102;
  v_dados(v_dados.last()).vr_vllanmto := 195277.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18745865;
  v_dados(v_dados.last()).vr_nrctremp := 359802;
  v_dados(v_dados.last()).vr_vllanmto := 10.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18874843;
  v_dados(v_dados.last()).vr_nrctremp := 364272;
  v_dados(v_dados.last()).vr_vllanmto := 4180.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 7480;
  v_dados(v_dados.last()).vr_nrctremp := 153202;
  v_dados(v_dados.last()).vr_vllanmto := 15.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 10120;
  v_dados(v_dados.last()).vr_nrctremp := 77028;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 25321;
  v_dados(v_dados.last()).vr_nrctremp := 84338;
  v_dados(v_dados.last()).vr_vllanmto := 36.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 32247;
  v_dados(v_dados.last()).vr_nrctremp := 57479;
  v_dados(v_dados.last()).vr_vllanmto := 11933.48;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 47023;
  v_dados(v_dados.last()).vr_nrctremp := 140688;
  v_dados(v_dados.last()).vr_vllanmto := 24.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 80950;
  v_dados(v_dados.last()).vr_nrctremp := 38185;
  v_dados(v_dados.last()).vr_vllanmto := 22155.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 88463;
  v_dados(v_dados.last()).vr_nrctremp := 115450;
  v_dados(v_dados.last()).vr_vllanmto := 12.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 106704;
  v_dados(v_dados.last()).vr_nrctremp := 44726;
  v_dados(v_dados.last()).vr_vllanmto := 12.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 107603;
  v_dados(v_dados.last()).vr_nrctremp := 130382;
  v_dados(v_dados.last()).vr_vllanmto := 10.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 112399;
  v_dados(v_dados.last()).vr_nrctremp := 156341;
  v_dados(v_dados.last()).vr_vllanmto := 14.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 128104;
  v_dados(v_dados.last()).vr_nrctremp := 134093;
  v_dados(v_dados.last()).vr_vllanmto := 14.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 130036;
  v_dados(v_dados.last()).vr_nrctremp := 75961;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 131245;
  v_dados(v_dados.last()).vr_nrctremp := 144074;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 131873;
  v_dados(v_dados.last()).vr_nrctremp := 98090;
  v_dados(v_dados.last()).vr_vllanmto := 168.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 145491;
  v_dados(v_dados.last()).vr_nrctremp := 111029;
  v_dados(v_dados.last()).vr_vllanmto := 23.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 162094;
  v_dados(v_dados.last()).vr_nrctremp := 133342;
  v_dados(v_dados.last()).vr_vllanmto := 25.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 166316;
  v_dados(v_dados.last()).vr_nrctremp := 145593;
  v_dados(v_dados.last()).vr_vllanmto := 11.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 166871;
  v_dados(v_dados.last()).vr_nrctremp := 139948;
  v_dados(v_dados.last()).vr_vllanmto := 27.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 173550;
  v_dados(v_dados.last()).vr_nrctremp := 158364;
  v_dados(v_dados.last()).vr_vllanmto := 10.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 176940;
  v_dados(v_dados.last()).vr_nrctremp := 127620;
  v_dados(v_dados.last()).vr_vllanmto := 13.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 185140;
  v_dados(v_dados.last()).vr_nrctremp := 142023;
  v_dados(v_dados.last()).vr_vllanmto := 17.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 212393;
  v_dados(v_dados.last()).vr_nrctremp := 136872;
  v_dados(v_dados.last()).vr_vllanmto := 18.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 215481;
  v_dados(v_dados.last()).vr_nrctremp := 159694;
  v_dados(v_dados.last()).vr_vllanmto := 20.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 221317;
  v_dados(v_dados.last()).vr_nrctremp := 155710;
  v_dados(v_dados.last()).vr_vllanmto := 19.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 225045;
  v_dados(v_dados.last()).vr_nrctremp := 158985;
  v_dados(v_dados.last()).vr_vllanmto := 25.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 229059;
  v_dados(v_dados.last()).vr_nrctremp := 35468;
  v_dados(v_dados.last()).vr_vllanmto := 79.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 264539;
  v_dados(v_dados.last()).vr_nrctremp := 80922;
  v_dados(v_dados.last()).vr_vllanmto := 1747.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 277150;
  v_dados(v_dados.last()).vr_nrctremp := 42448;
  v_dados(v_dados.last()).vr_vllanmto := 976.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 278076;
  v_dados(v_dados.last()).vr_nrctremp := 117072;
  v_dados(v_dados.last()).vr_vllanmto := 15.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 281417;
  v_dados(v_dados.last()).vr_nrctremp := 42281;
  v_dados(v_dados.last()).vr_vllanmto := 87.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 281417;
  v_dados(v_dados.last()).vr_nrctremp := 49691;
  v_dados(v_dados.last()).vr_vllanmto := 38.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 332461;
  v_dados(v_dados.last()).vr_nrctremp := 45846;
  v_dados(v_dados.last()).vr_vllanmto := 18.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 332836;
  v_dados(v_dados.last()).vr_nrctremp := 92139;
  v_dados(v_dados.last()).vr_vllanmto := 11.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 333425;
  v_dados(v_dados.last()).vr_nrctremp := 51196;
  v_dados(v_dados.last()).vr_vllanmto := 10.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 333816;
  v_dados(v_dados.last()).vr_nrctremp := 67729;
  v_dados(v_dados.last()).vr_vllanmto := 27.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 334278;
  v_dados(v_dados.last()).vr_nrctremp := 108638;
  v_dados(v_dados.last()).vr_vllanmto := 12439.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 350508;
  v_dados(v_dados.last()).vr_nrctremp := 106560;
  v_dados(v_dados.last()).vr_vllanmto := 31.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 360929;
  v_dados(v_dados.last()).vr_nrctremp := 62245;
  v_dados(v_dados.last()).vr_vllanmto := 2665.61;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 360929;
  v_dados(v_dados.last()).vr_nrctremp := 73782;
  v_dados(v_dados.last()).vr_vllanmto := 5629.6;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 363286;
  v_dados(v_dados.last()).vr_nrctremp := 77990;
  v_dados(v_dados.last()).vr_vllanmto := 2711.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 366064;
  v_dados(v_dados.last()).vr_nrctremp := 97216;
  v_dados(v_dados.last()).vr_vllanmto := 15457.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 391530;
  v_dados(v_dados.last()).vr_nrctremp := 133217;
  v_dados(v_dados.last()).vr_vllanmto := 10.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 406465;
  v_dados(v_dados.last()).vr_nrctremp := 152180;
  v_dados(v_dados.last()).vr_vllanmto := 14.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 415170;
  v_dados(v_dados.last()).vr_nrctremp := 147184;
  v_dados(v_dados.last()).vr_vllanmto := 16.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 415324;
  v_dados(v_dados.last()).vr_nrctremp := 131807;
  v_dados(v_dados.last()).vr_vllanmto := 15.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 415820;
  v_dados(v_dados.last()).vr_nrctremp := 150450;
  v_dados(v_dados.last()).vr_vllanmto := 31.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 428965;
  v_dados(v_dados.last()).vr_nrctremp := 144975;
  v_dados(v_dados.last()).vr_vllanmto := 10.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 430480;
  v_dados(v_dados.last()).vr_nrctremp := 153760;
  v_dados(v_dados.last()).vr_vllanmto := 14.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 440736;
  v_dados(v_dados.last()).vr_nrctremp := 130493;
  v_dados(v_dados.last()).vr_vllanmto := 11.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 444928;
  v_dados(v_dados.last()).vr_nrctremp := 152074;
  v_dados(v_dados.last()).vr_vllanmto := 11.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 472000;
  v_dados(v_dados.last()).vr_nrctremp := 145847;
  v_dados(v_dados.last()).vr_vllanmto := 19.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 478431;
  v_dados(v_dados.last()).vr_nrctremp := 152328;
  v_dados(v_dados.last()).vr_vllanmto := 242.83;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 478431;
  v_dados(v_dados.last()).vr_nrctremp := 160251;
  v_dados(v_dados.last()).vr_vllanmto := 230.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14548798;
  v_dados(v_dados.last()).vr_nrctremp := 110120;
  v_dados(v_dados.last()).vr_vllanmto := 11.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14717042;
  v_dados(v_dados.last()).vr_nrctremp := 160300;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14799367;
  v_dados(v_dados.last()).vr_nrctremp := 67446;
  v_dados(v_dados.last()).vr_vllanmto := 87.66;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15060691;
  v_dados(v_dados.last()).vr_nrctremp := 135713;
  v_dados(v_dados.last()).vr_vllanmto := 17.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15367061;
  v_dados(v_dados.last()).vr_nrctremp := 98058;
  v_dados(v_dados.last()).vr_vllanmto := 2095.56;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15463842;
  v_dados(v_dados.last()).vr_nrctremp := 146748;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15467309;
  v_dados(v_dados.last()).vr_nrctremp := 146366;
  v_dados(v_dados.last()).vr_vllanmto := 17.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15469174;
  v_dados(v_dados.last()).vr_nrctremp := 162045;
  v_dados(v_dados.last()).vr_vllanmto := 16.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15469751;
  v_dados(v_dados.last()).vr_nrctremp := 99358;
  v_dados(v_dados.last()).vr_vllanmto := 24.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15472167;
  v_dados(v_dados.last()).vr_nrctremp := 110702;
  v_dados(v_dados.last()).vr_vllanmto := 12.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15477622;
  v_dados(v_dados.last()).vr_nrctremp := 120195;
  v_dados(v_dados.last()).vr_vllanmto := 11.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15490378;
  v_dados(v_dados.last()).vr_nrctremp := 108330;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15490475;
  v_dados(v_dados.last()).vr_nrctremp := 126373;
  v_dados(v_dados.last()).vr_vllanmto := 20572.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15494837;
  v_dados(v_dados.last()).vr_nrctremp := 129721;
  v_dados(v_dados.last()).vr_vllanmto := 12.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15494870;
  v_dados(v_dados.last()).vr_nrctremp := 119378;
  v_dados(v_dados.last()).vr_vllanmto := 14.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15502082;
  v_dados(v_dados.last()).vr_nrctremp := 97453;
  v_dados(v_dados.last()).vr_vllanmto := 14.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15503704;
  v_dados(v_dados.last()).vr_nrctremp := 116772;
  v_dados(v_dados.last()).vr_vllanmto := 28.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15510174;
  v_dados(v_dados.last()).vr_nrctremp := 112870;
  v_dados(v_dados.last()).vr_vllanmto := 15.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15510190;
  v_dados(v_dados.last()).vr_nrctremp := 139546;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15511995;
  v_dados(v_dados.last()).vr_nrctremp := 102566;
  v_dados(v_dados.last()).vr_vllanmto := 105.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15512100;
  v_dados(v_dados.last()).vr_nrctremp := 102852;
  v_dados(v_dados.last()).vr_vllanmto := 83.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15512223;
  v_dados(v_dados.last()).vr_nrctremp := 111548;
  v_dados(v_dados.last()).vr_vllanmto := 12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15512258;
  v_dados(v_dados.last()).vr_nrctremp := 123119;
  v_dados(v_dados.last()).vr_vllanmto := 12.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15583180;
  v_dados(v_dados.last()).vr_nrctremp := 127838;
  v_dados(v_dados.last()).vr_vllanmto := 12.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15683788;
  v_dados(v_dados.last()).vr_nrctremp := 130679;
  v_dados(v_dados.last()).vr_vllanmto := 14.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15701107;
  v_dados(v_dados.last()).vr_nrctremp := 125027;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15721779;
  v_dados(v_dados.last()).vr_nrctremp := 120051;
  v_dados(v_dados.last()).vr_vllanmto := 10.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15759113;
  v_dados(v_dados.last()).vr_nrctremp := 123580;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15827607;
  v_dados(v_dados.last()).vr_nrctremp := 107083;
  v_dados(v_dados.last()).vr_vllanmto := 2275.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15832406;
  v_dados(v_dados.last()).vr_nrctremp := 115583;
  v_dados(v_dados.last()).vr_vllanmto := 12.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15865100;
  v_dados(v_dados.last()).vr_nrctremp := 122891;
  v_dados(v_dados.last()).vr_vllanmto := 24.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15890791;
  v_dados(v_dados.last()).vr_nrctremp := 120199;
  v_dados(v_dados.last()).vr_vllanmto := 16.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 16150490;
  v_dados(v_dados.last()).vr_nrctremp := 155688;
  v_dados(v_dados.last()).vr_vllanmto := 12.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 16201353;
  v_dados(v_dados.last()).vr_nrctremp := 107408;
  v_dados(v_dados.last()).vr_vllanmto := 2585.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 16280806;
  v_dados(v_dados.last()).vr_nrctremp := 138223;
  v_dados(v_dados.last()).vr_vllanmto := 12.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 16299949;
  v_dados(v_dados.last()).vr_nrctremp := 147767;
  v_dados(v_dados.last()).vr_vllanmto := 13.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 16423186;
  v_dados(v_dados.last()).vr_nrctremp := 127166;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 17833892;
  v_dados(v_dados.last()).vr_nrctremp := 161060;
  v_dados(v_dados.last()).vr_vllanmto := 14.06;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 18257224;
  v_dados(v_dados.last()).vr_nrctremp := 152446;
  v_dados(v_dados.last()).vr_vllanmto := 14.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 18657796;
  v_dados(v_dados.last()).vr_nrctremp := 161105;
  v_dados(v_dados.last()).vr_vllanmto := 12.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 18750540;
  v_dados(v_dados.last()).vr_nrctremp := 163124;
  v_dados(v_dados.last()).vr_vllanmto := 15.82;
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

    IF rw_crapass.saldo_contrato > 0 THEN
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
