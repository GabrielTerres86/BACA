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
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2023895;
    v_dados(v_dados.last()).vr_vllanmto := 4077.87;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9990100;
    v_dados(v_dados.last()).vr_nrctremp := 2784147;
    v_dados(v_dados.last()).vr_vllanmto := 3210.85;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710091;
    v_dados(v_dados.last()).vr_nrctremp := 3935842;
    v_dados(v_dados.last()).vr_vllanmto := 595.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8624780;
    v_dados(v_dados.last()).vr_nrctremp := 5555185;
    v_dados(v_dados.last()).vr_vllanmto := 287.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12981877;
    v_dados(v_dados.last()).vr_nrctremp := 5200658;
    v_dados(v_dados.last()).vr_vllanmto := 258.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873632;
    v_dados(v_dados.last()).vr_nrctremp := 4085979;
    v_dados(v_dados.last()).vr_vllanmto := 227.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 221.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 189.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6496571;
    v_dados(v_dados.last()).vr_nrctremp := 5461206;
    v_dados(v_dados.last()).vr_vllanmto := 181.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10831150;
    v_dados(v_dados.last()).vr_nrctremp := 4571633;
    v_dados(v_dados.last()).vr_vllanmto := 137.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8684413;
    v_dados(v_dados.last()).vr_nrctremp := 5323281;
    v_dados(v_dados.last()).vr_vllanmto := 132.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9519947;
    v_dados(v_dados.last()).vr_nrctremp := 5962529;
    v_dados(v_dados.last()).vr_vllanmto := 123.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 122.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11484080;
    v_dados(v_dados.last()).vr_nrctremp := 4741094;
    v_dados(v_dados.last()).vr_vllanmto := 117.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8401411;
    v_dados(v_dados.last()).vr_nrctremp := 5235619;
    v_dados(v_dados.last()).vr_vllanmto := 115.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7669437;
    v_dados(v_dados.last()).vr_nrctremp := 2507640;
    v_dados(v_dados.last()).vr_vllanmto := 110.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80170781;
    v_dados(v_dados.last()).vr_nrctremp := 3472408;
    v_dados(v_dados.last()).vr_vllanmto := 101.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13923595;
    v_dados(v_dados.last()).vr_nrctremp := 5022137;
    v_dados(v_dados.last()).vr_vllanmto := 98.57;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10465537;
    v_dados(v_dados.last()).vr_nrctremp := 4476841;
    v_dados(v_dados.last()).vr_vllanmto := 81.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7214014;
    v_dados(v_dados.last()).vr_nrctremp := 5235680;
    v_dados(v_dados.last()).vr_vllanmto := 78.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10412670;
    v_dados(v_dados.last()).vr_nrctremp := 4140383;
    v_dados(v_dados.last()).vr_vllanmto := 67.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11369248;
    v_dados(v_dados.last()).vr_nrctremp := 3542693;
    v_dados(v_dados.last()).vr_vllanmto := 66.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12784630;
    v_dados(v_dados.last()).vr_nrctremp := 5782397;
    v_dados(v_dados.last()).vr_vllanmto := 61.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9210750;
    v_dados(v_dados.last()).vr_nrctremp := 4338371;
    v_dados(v_dados.last()).vr_vllanmto := 59.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3721124;
    v_dados(v_dados.last()).vr_nrctremp := 4816442;
    v_dados(v_dados.last()).vr_vllanmto := 48.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13702297;
    v_dados(v_dados.last()).vr_nrctremp := 5833525;
    v_dados(v_dados.last()).vr_vllanmto := 45.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10487662;
    v_dados(v_dados.last()).vr_nrctremp := 3932268;
    v_dados(v_dados.last()).vr_vllanmto := 36.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12711586;
    v_dados(v_dados.last()).vr_nrctremp := 5748667;
    v_dados(v_dados.last()).vr_vllanmto := 33.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10654445;
    v_dados(v_dados.last()).vr_nrctremp := 3046625;
    v_dados(v_dados.last()).vr_vllanmto := 32.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7471955;
    v_dados(v_dados.last()).vr_nrctremp := 5750249;
    v_dados(v_dados.last()).vr_vllanmto := 29.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11766522;
    v_dados(v_dados.last()).vr_nrctremp := 5500927;
    v_dados(v_dados.last()).vr_vllanmto := 28.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12390917;
    v_dados(v_dados.last()).vr_nrctremp := 5369641;
    v_dados(v_dados.last()).vr_vllanmto := 25.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266578;
    v_dados(v_dados.last()).vr_nrctremp := 4829270;
    v_dados(v_dados.last()).vr_vllanmto := 25.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6940650;
    v_dados(v_dados.last()).vr_nrctremp := 5785223;
    v_dados(v_dados.last()).vr_vllanmto := 24.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8830797;
    v_dados(v_dados.last()).vr_nrctremp := 5758179;
    v_dados(v_dados.last()).vr_vllanmto := 24.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11106360;
    v_dados(v_dados.last()).vr_nrctremp := 5896423;
    v_dados(v_dados.last()).vr_vllanmto := 21.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13440241;
    v_dados(v_dados.last()).vr_nrctremp := 4672702;
    v_dados(v_dados.last()).vr_vllanmto := 21.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7326327;
    v_dados(v_dados.last()).vr_nrctremp := 5933181;
    v_dados(v_dados.last()).vr_vllanmto := 19.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13739425;
    v_dados(v_dados.last()).vr_nrctremp := 5531174;
    v_dados(v_dados.last()).vr_vllanmto := 19.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3761240;
    v_dados(v_dados.last()).vr_nrctremp := 4898751;
    v_dados(v_dados.last()).vr_vllanmto := 19.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11956186;
    v_dados(v_dados.last()).vr_nrctremp := 6018525;
    v_dados(v_dados.last()).vr_vllanmto := 18.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13594958;
    v_dados(v_dados.last()).vr_nrctremp := 5789885;
    v_dados(v_dados.last()).vr_vllanmto := 17.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12825212;
    v_dados(v_dados.last()).vr_nrctremp := 4576380;
    v_dados(v_dados.last()).vr_vllanmto := 17.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13298216;
    v_dados(v_dados.last()).vr_nrctremp := 4662710;
    v_dados(v_dados.last()).vr_vllanmto := 17.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13581155;
    v_dados(v_dados.last()).vr_nrctremp := 5533233;
    v_dados(v_dados.last()).vr_vllanmto := 17.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11836199;
    v_dados(v_dados.last()).vr_nrctremp := 5938584;
    v_dados(v_dados.last()).vr_vllanmto := 17.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6942032;
    v_dados(v_dados.last()).vr_nrctremp := 5953798;
    v_dados(v_dados.last()).vr_vllanmto := 15.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3790622;
    v_dados(v_dados.last()).vr_nrctremp := 4307968;
    v_dados(v_dados.last()).vr_vllanmto := 2.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389404;
    v_dados(v_dados.last()).vr_nrctremp := 4250955;
    v_dados(v_dados.last()).vr_vllanmto := 1.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8707642;
    v_dados(v_dados.last()).vr_nrctremp := 3430425;
    v_dados(v_dados.last()).vr_vllanmto := .16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12979236;
    v_dados(v_dados.last()).vr_nrctremp := 4161519;
    v_dados(v_dados.last()).vr_vllanmto := 15.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6319572;
    v_dados(v_dados.last()).vr_nrctremp := 4108542;
    v_dados(v_dados.last()).vr_vllanmto := 15.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3626628;
    v_dados(v_dados.last()).vr_nrctremp := 4308386;
    v_dados(v_dados.last()).vr_vllanmto := 15.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9626352;
    v_dados(v_dados.last()).vr_nrctremp := 4898022;
    v_dados(v_dados.last()).vr_vllanmto := 16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9958070;
    v_dados(v_dados.last()).vr_nrctremp := 5848326;
    v_dados(v_dados.last()).vr_vllanmto := 16.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3189310;
    v_dados(v_dados.last()).vr_vllanmto := 18.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2984628;
    v_dados(v_dados.last()).vr_nrctremp := 4935932;
    v_dados(v_dados.last()).vr_vllanmto := 18.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11009993;
    v_dados(v_dados.last()).vr_nrctremp := 4901511;
    v_dados(v_dados.last()).vr_vllanmto := 18.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8907315;
    v_dados(v_dados.last()).vr_nrctremp := 3627786;
    v_dados(v_dados.last()).vr_vllanmto := 18.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12397253;
    v_dados(v_dados.last()).vr_nrctremp := 3600273;
    v_dados(v_dados.last()).vr_vllanmto := 19.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116967;
    v_dados(v_dados.last()).vr_nrctremp := 4348356;
    v_dados(v_dados.last()).vr_vllanmto := 20.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601977;
    v_dados(v_dados.last()).vr_nrctremp := 4029953;
    v_dados(v_dados.last()).vr_vllanmto := 20.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10278630;
    v_dados(v_dados.last()).vr_nrctremp := 4778376;
    v_dados(v_dados.last()).vr_vllanmto := 20.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12720828;
    v_dados(v_dados.last()).vr_nrctremp := 3995814;
    v_dados(v_dados.last()).vr_vllanmto := 20.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13659030;
    v_dados(v_dados.last()).vr_nrctremp := 4663143;
    v_dados(v_dados.last()).vr_vllanmto := 21.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12383708;
    v_dados(v_dados.last()).vr_nrctremp := 3578578;
    v_dados(v_dados.last()).vr_vllanmto := 22.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4378452;
    v_dados(v_dados.last()).vr_vllanmto := 22.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12603210;
    v_dados(v_dados.last()).vr_nrctremp := 5914762;
    v_dados(v_dados.last()).vr_vllanmto := 23.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9768076;
    v_dados(v_dados.last()).vr_nrctremp := 5068501;
    v_dados(v_dados.last()).vr_vllanmto := 24.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3628280;
    v_dados(v_dados.last()).vr_nrctremp := 3965338;
    v_dados(v_dados.last()).vr_vllanmto := 24.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12541265;
    v_dados(v_dados.last()).vr_nrctremp := 3760813;
    v_dados(v_dados.last()).vr_vllanmto := 25.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := 25.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11889195;
    v_dados(v_dados.last()).vr_nrctremp := 3521680;
    v_dados(v_dados.last()).vr_vllanmto := 26.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4024341;
    v_dados(v_dados.last()).vr_vllanmto := 27.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12653411;
    v_dados(v_dados.last()).vr_nrctremp := 5256736;
    v_dados(v_dados.last()).vr_vllanmto := 27.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6786430;
    v_dados(v_dados.last()).vr_nrctremp := 4774963;
    v_dados(v_dados.last()).vr_vllanmto := 28.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4038250;
    v_dados(v_dados.last()).vr_vllanmto := 28.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035734;
    v_dados(v_dados.last()).vr_nrctremp := 3758256;
    v_dados(v_dados.last()).vr_vllanmto := 29.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12419940;
    v_dados(v_dados.last()).vr_nrctremp := 3618344;
    v_dados(v_dados.last()).vr_vllanmto := 29.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10204547;
    v_dados(v_dados.last()).vr_nrctremp := 4635900;
    v_dados(v_dados.last()).vr_vllanmto := 29.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7206895;
    v_dados(v_dados.last()).vr_nrctremp := 5170845;
    v_dados(v_dados.last()).vr_vllanmto := 29.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7864825;
    v_dados(v_dados.last()).vr_nrctremp := 4564568;
    v_dados(v_dados.last()).vr_vllanmto := 29.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3190820;
    v_dados(v_dados.last()).vr_nrctremp := 4222544;
    v_dados(v_dados.last()).vr_vllanmto := 30.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11786345;
    v_dados(v_dados.last()).vr_nrctremp := 4680798;
    v_dados(v_dados.last()).vr_vllanmto := 31.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 31.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 3170921;
    v_dados(v_dados.last()).vr_vllanmto := 33.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939478;
    v_dados(v_dados.last()).vr_vllanmto := 34.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12422320;
    v_dados(v_dados.last()).vr_nrctremp := 3615395;
    v_dados(v_dados.last()).vr_vllanmto := 34.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 3742862;
    v_dados(v_dados.last()).vr_vllanmto := 34.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12731498;
    v_dados(v_dados.last()).vr_nrctremp := 4141397;
    v_dados(v_dados.last()).vr_vllanmto := 35.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10645292;
    v_dados(v_dados.last()).vr_nrctremp := 4312871;
    v_dados(v_dados.last()).vr_vllanmto := 35.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12724009;
    v_dados(v_dados.last()).vr_nrctremp := 3932327;
    v_dados(v_dados.last()).vr_vllanmto := 35.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12420085;
    v_dados(v_dados.last()).vr_nrctremp := 3621331;
    v_dados(v_dados.last()).vr_vllanmto := 35.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12582565;
    v_dados(v_dados.last()).vr_nrctremp := 3986201;
    v_dados(v_dados.last()).vr_vllanmto := 37.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3990688;
    v_dados(v_dados.last()).vr_vllanmto := 39.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11951605;
    v_dados(v_dados.last()).vr_nrctremp := 4745153;
    v_dados(v_dados.last()).vr_vllanmto := 39.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10400354;
    v_dados(v_dados.last()).vr_nrctremp := 5541382;
    v_dados(v_dados.last()).vr_vllanmto := 40.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 41.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80029990;
    v_dados(v_dados.last()).vr_nrctremp := 5354239;
    v_dados(v_dados.last()).vr_vllanmto := 42.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13246003;
    v_dados(v_dados.last()).vr_nrctremp := 4375937;
    v_dados(v_dados.last()).vr_vllanmto := 42.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739103;
    v_dados(v_dados.last()).vr_nrctremp := 4441023;
    v_dados(v_dados.last()).vr_vllanmto := 43.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3521109;
    v_dados(v_dados.last()).vr_nrctremp := 5592146;
    v_dados(v_dados.last()).vr_vllanmto := 44.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14074320;
    v_dados(v_dados.last()).vr_nrctremp := 5086593;
    v_dados(v_dados.last()).vr_vllanmto := 45.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8637733;
    v_dados(v_dados.last()).vr_nrctremp := 4101609;
    v_dados(v_dados.last()).vr_vllanmto := 49.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10464816;
    v_dados(v_dados.last()).vr_nrctremp := 4511327;
    v_dados(v_dados.last()).vr_vllanmto := 50.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617008;
    v_dados(v_dados.last()).vr_nrctremp := 3827456;
    v_dados(v_dados.last()).vr_vllanmto := 50.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 50.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 4164558;
    v_dados(v_dados.last()).vr_vllanmto := 51.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194371;
    v_dados(v_dados.last()).vr_nrctremp := 3700170;
    v_dados(v_dados.last()).vr_vllanmto := 52.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875638;
    v_dados(v_dados.last()).vr_nrctremp := 5414111;
    v_dados(v_dados.last()).vr_vllanmto := 53.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 54.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12239470;
    v_dados(v_dados.last()).vr_nrctremp := 3436180;
    v_dados(v_dados.last()).vr_vllanmto := 57.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12591424;
    v_dados(v_dados.last()).vr_nrctremp := 3799822;
    v_dados(v_dados.last()).vr_vllanmto := 58.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80173870;
    v_dados(v_dados.last()).vr_nrctremp := 2955468;
    v_dados(v_dados.last()).vr_vllanmto := 59.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476651;
    v_dados(v_dados.last()).vr_nrctremp := 4558023;
    v_dados(v_dados.last()).vr_vllanmto := 59.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 61.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14419394;
    v_dados(v_dados.last()).vr_nrctremp := 5573717;
    v_dados(v_dados.last()).vr_vllanmto := 64.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80431135;
    v_dados(v_dados.last()).vr_nrctremp := 1901589;
    v_dados(v_dados.last()).vr_vllanmto := 65.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9064397;
    v_dados(v_dados.last()).vr_nrctremp := 4784897;
    v_dados(v_dados.last()).vr_vllanmto := 67.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773367;
    v_dados(v_dados.last()).vr_nrctremp := 3170781;
    v_dados(v_dados.last()).vr_vllanmto := 72.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10637753;
    v_dados(v_dados.last()).vr_nrctremp := 4453483;
    v_dados(v_dados.last()).vr_vllanmto := 73.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3231886;
    v_dados(v_dados.last()).vr_vllanmto := 75.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7434928;
    v_dados(v_dados.last()).vr_nrctremp := 2955176;
    v_dados(v_dados.last()).vr_vllanmto := 76.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712643;
    v_dados(v_dados.last()).vr_nrctremp := 3098270;
    v_dados(v_dados.last()).vr_vllanmto := 78.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193081;
    v_dados(v_dados.last()).vr_nrctremp := 2102720;
    v_dados(v_dados.last()).vr_vllanmto := 82.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12325570;
    v_dados(v_dados.last()).vr_nrctremp := 3599984;
    v_dados(v_dados.last()).vr_vllanmto := 83.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9790900;
    v_dados(v_dados.last()).vr_nrctremp := 3831349;
    v_dados(v_dados.last()).vr_vllanmto := 85.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4829674;
    v_dados(v_dados.last()).vr_vllanmto := 88.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873853;
    v_dados(v_dados.last()).vr_nrctremp := 4082058;
    v_dados(v_dados.last()).vr_vllanmto := 90.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10609377;
    v_dados(v_dados.last()).vr_nrctremp := 2005092;
    v_dados(v_dados.last()).vr_vllanmto := 94.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8060266;
    v_dados(v_dados.last()).vr_nrctremp := 4800878;
    v_dados(v_dados.last()).vr_vllanmto := 95.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 100.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190449;
    v_dados(v_dados.last()).vr_nrctremp := 3932307;
    v_dados(v_dados.last()).vr_vllanmto := 101.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7187068;
    v_dados(v_dados.last()).vr_nrctremp := 4810669;
    v_dados(v_dados.last()).vr_vllanmto := 115.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10567925;
    v_dados(v_dados.last()).vr_nrctremp := 2955546;
    v_dados(v_dados.last()).vr_vllanmto := 137.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 139.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10006001;
    v_dados(v_dados.last()).vr_nrctremp := 3077352;
    v_dados(v_dados.last()).vr_vllanmto := 141.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 141.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425737;
    v_dados(v_dados.last()).vr_nrctremp := 3860454;
    v_dados(v_dados.last()).vr_vllanmto := 158.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101062;
    v_dados(v_dados.last()).vr_nrctremp := 2955278;
    v_dados(v_dados.last()).vr_vllanmto := 172.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80334768;
    v_dados(v_dados.last()).vr_nrctremp := 3858963;
    v_dados(v_dados.last()).vr_vllanmto := 209.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 212.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356380;
    v_dados(v_dados.last()).vr_nrctremp := 4642262;
    v_dados(v_dados.last()).vr_vllanmto := 213.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8171645;
    v_dados(v_dados.last()).vr_nrctremp := 4644755;
    v_dados(v_dados.last()).vr_vllanmto := 275.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80340873;
    v_dados(v_dados.last()).vr_nrctremp := 2955797;
    v_dados(v_dados.last()).vr_vllanmto := 398.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861579;
    v_dados(v_dados.last()).vr_nrctremp := 3067139;
    v_dados(v_dados.last()).vr_vllanmto := 498.9;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6935915;
    v_dados(v_dados.last()).vr_nrctremp := 2991942;
    v_dados(v_dados.last()).vr_vllanmto := 519.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6941478;
    v_dados(v_dados.last()).vr_nrctremp := 6052968;
    v_dados(v_dados.last()).vr_vllanmto := 2797.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;
	
	v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11484080;
    v_dados(v_dados.last()).vr_nrctremp := 4741094;
    v_dados(v_dados.last()).vr_vllanmto := 2738.89;
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
