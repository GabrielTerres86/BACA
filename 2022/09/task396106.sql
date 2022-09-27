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
  v_dados(v_dados.last()).vr_vllanmto := 53.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80346871;
  v_dados(v_dados.last()).vr_nrctremp := 2024567;
  v_dados(v_dados.last()).vr_vllanmto := 18.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80241247;
  v_dados(v_dados.last()).vr_nrctremp := 2046910;
  v_dados(v_dados.last()).vr_vllanmto := 67.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9325743;
  v_dados(v_dados.last()).vr_nrctremp := 2073818;
  v_dados(v_dados.last()).vr_vllanmto := 1962.24;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9990100;
  v_dados(v_dados.last()).vr_nrctremp := 2784147;
  v_dados(v_dados.last()).vr_vllanmto := 128.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8840598;
  v_dados(v_dados.last()).vr_nrctremp := 2955363;
  v_dados(v_dados.last()).vr_vllanmto := 32.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7652704;
  v_dados(v_dados.last()).vr_nrctremp := 2955374;
  v_dados(v_dados.last()).vr_vllanmto := 112.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9082530;
  v_dados(v_dados.last()).vr_nrctremp := 2955578;
  v_dados(v_dados.last()).vr_vllanmto := .65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80336272;
  v_dados(v_dados.last()).vr_nrctremp := 3067399;
  v_dados(v_dados.last()).vr_vllanmto := 123.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10819967;
  v_dados(v_dados.last()).vr_nrctremp := 3159652;
  v_dados(v_dados.last()).vr_vllanmto := 270.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10886176;
  v_dados(v_dados.last()).vr_nrctremp := 3174348;
  v_dados(v_dados.last()).vr_vllanmto := 27.84;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11691700;
  v_dados(v_dados.last()).vr_nrctremp := 3235912;
  v_dados(v_dados.last()).vr_vllanmto := 14.96;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12074233;
  v_dados(v_dados.last()).vr_nrctremp := 3255681;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12103721;
  v_dados(v_dados.last()).vr_nrctremp := 3289303;
  v_dados(v_dados.last()).vr_vllanmto := 9.86;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12123730;
  v_dados(v_dados.last()).vr_nrctremp := 3315152;
  v_dados(v_dados.last()).vr_vllanmto := 52.81;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 3421230;
  v_dados(v_dados.last()).vr_vllanmto := 20.57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12019178;
  v_dados(v_dados.last()).vr_nrctremp := 3430704;
  v_dados(v_dados.last()).vr_vllanmto := 19.26;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12035734;
  v_dados(v_dados.last()).vr_nrctremp := 3434461;
  v_dados(v_dados.last()).vr_vllanmto := 14.57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12300349;
  v_dados(v_dados.last()).vr_nrctremp := 3504420;
  v_dados(v_dados.last()).vr_vllanmto := 8.57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12316628;
  v_dados(v_dados.last()).vr_nrctremp := 3510982;
  v_dados(v_dados.last()).vr_vllanmto := 13.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12383708;
  v_dados(v_dados.last()).vr_nrctremp := 3578578;
  v_dados(v_dados.last()).vr_vllanmto := 14.72;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389080;
  v_dados(v_dados.last()).vr_nrctremp := 3584084;
  v_dados(v_dados.last()).vr_vllanmto := 17.36;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12325570;
  v_dados(v_dados.last()).vr_nrctremp := 3599984;
  v_dados(v_dados.last()).vr_vllanmto := 3.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12424579;
  v_dados(v_dados.last()).vr_nrctremp := 3618246;
  v_dados(v_dados.last()).vr_vllanmto := 6.55;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8907315;
  v_dados(v_dados.last()).vr_nrctremp := 3627786;
  v_dados(v_dados.last()).vr_vllanmto := 28.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12305804;
  v_dados(v_dados.last()).vr_nrctremp := 3656154;
  v_dados(v_dados.last()).vr_vllanmto := 18.43;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12520365;
  v_dados(v_dados.last()).vr_nrctremp := 3726902;
  v_dados(v_dados.last()).vr_vllanmto := 66.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12557889;
  v_dados(v_dados.last()).vr_nrctremp := 3762595;
  v_dados(v_dados.last()).vr_vllanmto := 38.75;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12568457;
  v_dados(v_dados.last()).vr_nrctremp := 3774764;
  v_dados(v_dados.last()).vr_vllanmto := 45.8;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12572713;
  v_dados(v_dados.last()).vr_nrctremp := 3795640;
  v_dados(v_dados.last()).vr_vllanmto := 35.11;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12594750;
  v_dados(v_dados.last()).vr_nrctremp := 3807129;
  v_dados(v_dados.last()).vr_vllanmto := 9.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12560448;
  v_dados(v_dados.last()).vr_nrctremp := 3815167;
  v_dados(v_dados.last()).vr_vllanmto := 2.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12637106;
  v_dados(v_dados.last()).vr_nrctremp := 3868680;
  v_dados(v_dados.last()).vr_vllanmto := 25.55;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2297060;
  v_dados(v_dados.last()).vr_nrctremp := 3889867;
  v_dados(v_dados.last()).vr_vllanmto := 172.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12690392;
  v_dados(v_dados.last()).vr_nrctremp := 3897211;
  v_dados(v_dados.last()).vr_vllanmto := 23.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 3902365;
  v_dados(v_dados.last()).vr_vllanmto := .72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11768614;
  v_dados(v_dados.last()).vr_nrctremp := 3920052;
  v_dados(v_dados.last()).vr_vllanmto := 2.35;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12724009;
  v_dados(v_dados.last()).vr_nrctremp := 3932359;
  v_dados(v_dados.last()).vr_vllanmto := 6.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 1.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12700860;
  v_dados(v_dados.last()).vr_nrctremp := 3939431;
  v_dados(v_dados.last()).vr_vllanmto := 8.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12582565;
  v_dados(v_dados.last()).vr_nrctremp := 3986201;
  v_dados(v_dados.last()).vr_vllanmto := 45.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2297060;
  v_dados(v_dados.last()).vr_nrctremp := 3990203;
  v_dados(v_dados.last()).vr_vllanmto := 2772.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8058717;
  v_dados(v_dados.last()).vr_nrctremp := 3990688;
  v_dados(v_dados.last()).vr_vllanmto := 42;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12716200;
  v_dados(v_dados.last()).vr_nrctremp := 3996934;
  v_dados(v_dados.last()).vr_vllanmto := 29.02;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12701521;
  v_dados(v_dados.last()).vr_nrctremp := 3997739;
  v_dados(v_dados.last()).vr_vllanmto := 48.33;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12462888;
  v_dados(v_dados.last()).vr_nrctremp := 4022402;
  v_dados(v_dados.last()).vr_vllanmto := 37.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12744786;
  v_dados(v_dados.last()).vr_nrctremp := 4024341;
  v_dados(v_dados.last()).vr_vllanmto := 2.48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12737640;
  v_dados(v_dados.last()).vr_nrctremp := 4038250;
  v_dados(v_dados.last()).vr_vllanmto := 83.95;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12741450;
  v_dados(v_dados.last()).vr_nrctremp := 4107091;
  v_dados(v_dados.last()).vr_vllanmto := 83.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 4118776;
  v_dados(v_dados.last()).vr_vllanmto := 2.38;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12371297;
  v_dados(v_dados.last()).vr_nrctremp := 4139299;
  v_dados(v_dados.last()).vr_vllanmto := 3.48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12979236;
  v_dados(v_dados.last()).vr_nrctremp := 4161519;
  v_dados(v_dados.last()).vr_vllanmto := 1.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7668058;
  v_dados(v_dados.last()).vr_nrctremp := 4183670;
  v_dados(v_dados.last()).vr_vllanmto := 3.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8164509;
  v_dados(v_dados.last()).vr_nrctremp := 4193531;
  v_dados(v_dados.last()).vr_vllanmto := 8.21;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13029568;
  v_dados(v_dados.last()).vr_nrctremp := 4201717;
  v_dados(v_dados.last()).vr_vllanmto := 21.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13029568;
  v_dados(v_dados.last()).vr_nrctremp := 4212320;
  v_dados(v_dados.last()).vr_vllanmto := 3.91;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8719705;
  v_dados(v_dados.last()).vr_nrctremp := 4222466;
  v_dados(v_dados.last()).vr_vllanmto := 4.5;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12741450;
  v_dados(v_dados.last()).vr_nrctremp := 4226847;
  v_dados(v_dados.last()).vr_vllanmto := 18.23;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13063928;
  v_dados(v_dados.last()).vr_nrctremp := 4229100;
  v_dados(v_dados.last()).vr_vllanmto := 4.76;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10275860;
  v_dados(v_dados.last()).vr_nrctremp := 4241038;
  v_dados(v_dados.last()).vr_vllanmto := 12.02;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12953563;
  v_dados(v_dados.last()).vr_nrctremp := 4243776;
  v_dados(v_dados.last()).vr_vllanmto := 20.7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12412902;
  v_dados(v_dados.last()).vr_nrctremp := 4244848;
  v_dados(v_dados.last()).vr_vllanmto := 6.51;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13087525;
  v_dados(v_dados.last()).vr_nrctremp := 4248623;
  v_dados(v_dados.last()).vr_vllanmto := 1.11;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389404;
  v_dados(v_dados.last()).vr_nrctremp := 4250955;
  v_dados(v_dados.last()).vr_vllanmto := 25.79;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 4251082;
  v_dados(v_dados.last()).vr_vllanmto := 7.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10491970;
  v_dados(v_dados.last()).vr_nrctremp := 4253223;
  v_dados(v_dados.last()).vr_vllanmto := 6.28;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12817678;
  v_dados(v_dados.last()).vr_nrctremp := 4256682;
  v_dados(v_dados.last()).vr_vllanmto := 38.99;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13119478;
  v_dados(v_dados.last()).vr_nrctremp := 4265318;
  v_dados(v_dados.last()).vr_vllanmto := 14.36;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13065661;
  v_dados(v_dados.last()).vr_nrctremp := 4267714;
  v_dados(v_dados.last()).vr_vllanmto := 19.47;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13133039;
  v_dados(v_dados.last()).vr_nrctremp := 4273075;
  v_dados(v_dados.last()).vr_vllanmto := 23.62;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11875283;
  v_dados(v_dados.last()).vr_nrctremp := 4276059;
  v_dados(v_dados.last()).vr_vllanmto := 7.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13131044;
  v_dados(v_dados.last()).vr_nrctremp := 4277909;
  v_dados(v_dados.last()).vr_vllanmto := 1.32;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12407836;
  v_dados(v_dados.last()).vr_nrctremp := 4297701;
  v_dados(v_dados.last()).vr_vllanmto := 1.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10799850;
  v_dados(v_dados.last()).vr_nrctremp := 4312290;
  v_dados(v_dados.last()).vr_vllanmto := 1.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13184270;
  v_dados(v_dados.last()).vr_nrctremp := 4313478;
  v_dados(v_dados.last()).vr_vllanmto := 26.26;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12584541;
  v_dados(v_dados.last()).vr_nrctremp := 4322781;
  v_dados(v_dados.last()).vr_vllanmto := 1.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13202502;
  v_dados(v_dados.last()).vr_nrctremp := 4330143;
  v_dados(v_dados.last()).vr_vllanmto := 8.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9210750;
  v_dados(v_dados.last()).vr_nrctremp := 4338371;
  v_dados(v_dados.last()).vr_vllanmto := 5.08;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13032127;
  v_dados(v_dados.last()).vr_nrctremp := 4346766;
  v_dados(v_dados.last()).vr_vllanmto := 6.62;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13132504;
  v_dados(v_dados.last()).vr_nrctremp := 4346910;
  v_dados(v_dados.last()).vr_vllanmto := 21.22;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13116967;
  v_dados(v_dados.last()).vr_nrctremp := 4348356;
  v_dados(v_dados.last()).vr_vllanmto := 1.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12957461;
  v_dados(v_dados.last()).vr_nrctremp := 4349766;
  v_dados(v_dados.last()).vr_vllanmto := 26.98;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12281220;
  v_dados(v_dados.last()).vr_nrctremp := 4366078;
  v_dados(v_dados.last()).vr_vllanmto := 5.25;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13235087;
  v_dados(v_dados.last()).vr_nrctremp := 4369298;
  v_dados(v_dados.last()).vr_vllanmto := 6.64;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13235087;
  v_dados(v_dados.last()).vr_nrctremp := 4369330;
  v_dados(v_dados.last()).vr_vllanmto := 2.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13151088;
  v_dados(v_dados.last()).vr_nrctremp := 4375227;
  v_dados(v_dados.last()).vr_vllanmto := 39.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13246003;
  v_dados(v_dados.last()).vr_nrctremp := 4375937;
  v_dados(v_dados.last()).vr_vllanmto := 57.66;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9726543;
  v_dados(v_dados.last()).vr_nrctremp := 4389334;
  v_dados(v_dados.last()).vr_vllanmto := 3.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11747820;
  v_dados(v_dados.last()).vr_nrctremp := 4401141;
  v_dados(v_dados.last()).vr_vllanmto := 7.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11834021;
  v_dados(v_dados.last()).vr_nrctremp := 4407237;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13308173;
  v_dados(v_dados.last()).vr_nrctremp := 4409489;
  v_dados(v_dados.last()).vr_vllanmto := 631.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13314084;
  v_dados(v_dados.last()).vr_nrctremp := 4413621;
  v_dados(v_dados.last()).vr_vllanmto := 7.91;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13177630;
  v_dados(v_dados.last()).vr_nrctremp := 4428083;
  v_dados(v_dados.last()).vr_vllanmto := 15.94;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9304444;
  v_dados(v_dados.last()).vr_nrctremp := 4434555;
  v_dados(v_dados.last()).vr_vllanmto := 3.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2415119;
  v_dados(v_dados.last()).vr_nrctremp := 4440402;
  v_dados(v_dados.last()).vr_vllanmto := 50.45;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6788432;
  v_dados(v_dados.last()).vr_nrctremp := 4440698;
  v_dados(v_dados.last()).vr_vllanmto := 15.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739103;
  v_dados(v_dados.last()).vr_nrctremp := 4441023;
  v_dados(v_dados.last()).vr_vllanmto := 1.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13342509;
  v_dados(v_dados.last()).vr_nrctremp := 4463416;
  v_dados(v_dados.last()).vr_vllanmto := 22.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12737640;
  v_dados(v_dados.last()).vr_nrctremp := 4471080;
  v_dados(v_dados.last()).vr_vllanmto := 5.09;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11505184;
  v_dados(v_dados.last()).vr_nrctremp := 4486388;
  v_dados(v_dados.last()).vr_vllanmto := 104.17;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13413341;
  v_dados(v_dados.last()).vr_nrctremp := 4488120;
  v_dados(v_dados.last()).vr_vllanmto := 3.01;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9189416;
  v_dados(v_dados.last()).vr_nrctremp := 4494116;
  v_dados(v_dados.last()).vr_vllanmto := .38;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13432109;
  v_dados(v_dados.last()).vr_nrctremp := 4500315;
  v_dados(v_dados.last()).vr_vllanmto := 3.5;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8762473;
  v_dados(v_dados.last()).vr_nrctremp := 4500533;
  v_dados(v_dados.last()).vr_vllanmto := .21;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10360581;
  v_dados(v_dados.last()).vr_nrctremp := 4521812;
  v_dados(v_dados.last()).vr_vllanmto := 82.3;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12274135;
  v_dados(v_dados.last()).vr_nrctremp := 4542269;
  v_dados(v_dados.last()).vr_vllanmto := 6.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9433171;
  v_dados(v_dados.last()).vr_nrctremp := 4559377;
  v_dados(v_dados.last()).vr_vllanmto := 29.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6788580;
  v_dados(v_dados.last()).vr_nrctremp := 4566950;
  v_dados(v_dados.last()).vr_vllanmto := 18.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8084840;
  v_dados(v_dados.last()).vr_nrctremp := 4569856;
  v_dados(v_dados.last()).vr_vllanmto := 28.59;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10831150;
  v_dados(v_dados.last()).vr_nrctremp := 4571633;
  v_dados(v_dados.last()).vr_vllanmto := 45.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12825212;
  v_dados(v_dados.last()).vr_nrctremp := 4576380;
  v_dados(v_dados.last()).vr_vllanmto := 20.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9406352;
  v_dados(v_dados.last()).vr_nrctremp := 4576551;
  v_dados(v_dados.last()).vr_vllanmto := 21.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13437275;
  v_dados(v_dados.last()).vr_nrctremp := 4576677;
  v_dados(v_dados.last()).vr_vllanmto := 7.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12029823;
  v_dados(v_dados.last()).vr_nrctremp := 4577555;
  v_dados(v_dados.last()).vr_vllanmto := 10.45;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8753822;
  v_dados(v_dados.last()).vr_nrctremp := 4577604;
  v_dados(v_dados.last()).vr_vllanmto := 14.55;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9734325;
  v_dados(v_dados.last()).vr_nrctremp := 4598794;
  v_dados(v_dados.last()).vr_vllanmto := 20;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3968944;
  v_dados(v_dados.last()).vr_nrctremp := 4606072;
  v_dados(v_dados.last()).vr_vllanmto := 12.7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10752188;
  v_dados(v_dados.last()).vr_nrctremp := 4616770;
  v_dados(v_dados.last()).vr_vllanmto := 15.22;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8683352;
  v_dados(v_dados.last()).vr_nrctremp := 4624468;
  v_dados(v_dados.last()).vr_vllanmto := 30.58;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10940650;
  v_dados(v_dados.last()).vr_nrctremp := 4639145;
  v_dados(v_dados.last()).vr_vllanmto := 6.22;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9356380;
  v_dados(v_dados.last()).vr_nrctremp := 4642262;
  v_dados(v_dados.last()).vr_vllanmto := 16.33;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11908637;
  v_dados(v_dados.last()).vr_nrctremp := 4650401;
  v_dados(v_dados.last()).vr_vllanmto := 18.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13481622;
  v_dados(v_dados.last()).vr_nrctremp := 4650705;
  v_dados(v_dados.last()).vr_vllanmto := 15.08;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12847089;
  v_dados(v_dados.last()).vr_nrctremp := 4651191;
  v_dados(v_dados.last()).vr_vllanmto := 4.87;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13584227;
  v_dados(v_dados.last()).vr_nrctremp := 4658244;
  v_dados(v_dados.last()).vr_vllanmto := 3.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13584227;
  v_dados(v_dados.last()).vr_nrctremp := 4658300;
  v_dados(v_dados.last()).vr_vllanmto := 7.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9474021;
  v_dados(v_dados.last()).vr_nrctremp := 4661418;
  v_dados(v_dados.last()).vr_vllanmto := 4.9;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13298216;
  v_dados(v_dados.last()).vr_nrctremp := 4662710;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13659030;
  v_dados(v_dados.last()).vr_nrctremp := 4663143;
  v_dados(v_dados.last()).vr_vllanmto := 4.17;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13440241;
  v_dados(v_dados.last()).vr_nrctremp := 4672702;
  v_dados(v_dados.last()).vr_vllanmto := 14.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11786345;
  v_dados(v_dados.last()).vr_nrctremp := 4680798;
  v_dados(v_dados.last()).vr_vllanmto := 16.03;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2540495;
  v_dados(v_dados.last()).vr_nrctremp := 4699203;
  v_dados(v_dados.last()).vr_vllanmto := 8.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8928029;
  v_dados(v_dados.last()).vr_nrctremp := 4702686;
  v_dados(v_dados.last()).vr_vllanmto := 6.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13343602;
  v_dados(v_dados.last()).vr_nrctremp := 4702720;
  v_dados(v_dados.last()).vr_vllanmto := 7.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9973877;
  v_dados(v_dados.last()).vr_nrctremp := 4705248;
  v_dados(v_dados.last()).vr_vllanmto := 12.62;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10885471;
  v_dados(v_dados.last()).vr_nrctremp := 4712416;
  v_dados(v_dados.last()).vr_vllanmto := 12.98;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9676902;
  v_dados(v_dados.last()).vr_nrctremp := 4729697;
  v_dados(v_dados.last()).vr_vllanmto := 7.3;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13763890;
  v_dados(v_dados.last()).vr_nrctremp := 4739175;
  v_dados(v_dados.last()).vr_vllanmto := 7.62;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12923419;
  v_dados(v_dados.last()).vr_nrctremp := 4741564;
  v_dados(v_dados.last()).vr_vllanmto := 4.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9322817;
  v_dados(v_dados.last()).vr_nrctremp := 4747166;
  v_dados(v_dados.last()).vr_vllanmto := 12.79;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2811030;
  v_dados(v_dados.last()).vr_nrctremp := 4751728;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6389643;
  v_dados(v_dados.last()).vr_nrctremp := 4754021;
  v_dados(v_dados.last()).vr_vllanmto := .92;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12288195;
  v_dados(v_dados.last()).vr_nrctremp := 4761996;
  v_dados(v_dados.last()).vr_vllanmto := 4.72;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11887176;
  v_dados(v_dados.last()).vr_nrctremp := 4778799;
  v_dados(v_dados.last()).vr_vllanmto := 3.84;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11468610;
  v_dados(v_dados.last()).vr_nrctremp := 4779849;
  v_dados(v_dados.last()).vr_vllanmto := 5.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12637106;
  v_dados(v_dados.last()).vr_nrctremp := 4782826;
  v_dados(v_dados.last()).vr_vllanmto := 2.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10640622;
  v_dados(v_dados.last()).vr_nrctremp := 4784340;
  v_dados(v_dados.last()).vr_vllanmto := 9.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7187068;
  v_dados(v_dados.last()).vr_nrctremp := 4810669;
  v_dados(v_dados.last()).vr_vllanmto := 30.21;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12324841;
  v_dados(v_dados.last()).vr_nrctremp := 4822507;
  v_dados(v_dados.last()).vr_vllanmto := 4.78;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10636048;
  v_dados(v_dados.last()).vr_nrctremp := 4839172;
  v_dados(v_dados.last()).vr_vllanmto := 3.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8737665;
  v_dados(v_dados.last()).vr_nrctremp := 4850258;
  v_dados(v_dados.last()).vr_vllanmto := 2.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

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
  v_dados(v_dados.last()).vr_vllanmto := 1.27;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9569871;
  v_dados(v_dados.last()).vr_nrctremp := 4855726;
  v_dados(v_dados.last()).vr_vllanmto := 4.74;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11449098;
  v_dados(v_dados.last()).vr_nrctremp := 4887179;
  v_dados(v_dados.last()).vr_vllanmto := 7.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11191945;
  v_dados(v_dados.last()).vr_nrctremp := 4887457;
  v_dados(v_dados.last()).vr_vllanmto := 9.37;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10273557;
  v_dados(v_dados.last()).vr_nrctremp := 4889176;
  v_dados(v_dados.last()).vr_vllanmto := .7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9626352;
  v_dados(v_dados.last()).vr_nrctremp := 4898022;
  v_dados(v_dados.last()).vr_vllanmto := 3.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11009993;
  v_dados(v_dados.last()).vr_nrctremp := 4901511;
  v_dados(v_dados.last()).vr_vllanmto := 5.63;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8254346;
  v_dados(v_dados.last()).vr_nrctremp := 4907943;
  v_dados(v_dados.last()).vr_vllanmto := 1.74;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11629410;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 3.8;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11262818;
  v_dados(v_dados.last()).vr_nrctremp := 4925150;
  v_dados(v_dados.last()).vr_vllanmto := 3.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80140939;
  v_dados(v_dados.last()).vr_nrctremp := 5042593;
  v_dados(v_dados.last()).vr_vllanmto := .43;
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
