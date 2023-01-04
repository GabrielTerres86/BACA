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
    v_dados(v_dados.last()).vr_nrdconta := 96121;
    v_dados(v_dados.last()).vr_nrctremp := 66693;
    v_dados(v_dados.last()).vr_vllanmto := 110.25;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166200;
    v_dados(v_dados.last()).vr_nrctremp := 126085;
    v_dados(v_dados.last()).vr_vllanmto := 33.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450200;
    v_dados(v_dados.last()).vr_nrctremp := 65949;
    v_dados(v_dados.last()).vr_vllanmto := 47.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91572;
    v_dados(v_dados.last()).vr_vllanmto := 50.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22560;
    v_dados(v_dados.last()).vr_nrctremp := 222572;
    v_dados(v_dados.last()).vr_vllanmto := 15.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 140.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 28312;
    v_dados(v_dados.last()).vr_nrctremp := 185993;
    v_dados(v_dados.last()).vr_vllanmto := 22.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 43.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59307;
    v_dados(v_dados.last()).vr_nrctremp := 182948;
    v_dados(v_dados.last()).vr_vllanmto := 27.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 61751;
    v_dados(v_dados.last()).vr_nrctremp := 202617;
    v_dados(v_dados.last()).vr_vllanmto := 71.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66672;
    v_dados(v_dados.last()).vr_nrctremp := 179795;
    v_dados(v_dados.last()).vr_vllanmto := 66.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 139.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 70386;
    v_dados(v_dados.last()).vr_nrctremp := 210912;
    v_dados(v_dados.last()).vr_vllanmto := 35.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71730;
    v_dados(v_dados.last()).vr_nrctremp := 191099;
    v_dados(v_dados.last()).vr_vllanmto := 15.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 223.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 76961;
    v_dados(v_dados.last()).vr_nrctremp := 93710;
    v_dados(v_dados.last()).vr_vllanmto := 43.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 240.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 88480;
    v_dados(v_dados.last()).vr_nrctremp := 97562;
    v_dados(v_dados.last()).vr_vllanmto := 42.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 64692;
    v_dados(v_dados.last()).vr_vllanmto := 33.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 89842;
    v_dados(v_dados.last()).vr_nrctremp := 209320;
    v_dados(v_dados.last()).vr_vllanmto := 21.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91189;
    v_dados(v_dados.last()).vr_nrctremp := 237190;
    v_dados(v_dados.last()).vr_vllanmto := 19.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92630;
    v_dados(v_dados.last()).vr_nrctremp := 182139;
    v_dados(v_dados.last()).vr_vllanmto := 46.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93378;
    v_dados(v_dados.last()).vr_nrctremp := 184796;
    v_dados(v_dados.last()).vr_vllanmto := 37.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 79.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94889;
    v_dados(v_dados.last()).vr_nrctremp := 84839;
    v_dados(v_dados.last()).vr_vllanmto := 112.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95141;
    v_dados(v_dados.last()).vr_nrctremp := 128642;
    v_dados(v_dados.last()).vr_vllanmto := 40.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95257;
    v_dados(v_dados.last()).vr_nrctremp := 114045;
    v_dados(v_dados.last()).vr_vllanmto := 86.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103691;
    v_dados(v_dados.last()).vr_nrctremp := 96084;
    v_dados(v_dados.last()).vr_vllanmto := 67.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103861;
    v_dados(v_dados.last()).vr_nrctremp := 134554;
    v_dados(v_dados.last()).vr_vllanmto := 120.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105295;
    v_dados(v_dados.last()).vr_nrctremp := 109809;
    v_dados(v_dados.last()).vr_vllanmto := 40.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107620;
    v_dados(v_dados.last()).vr_nrctremp := 132064;
    v_dados(v_dados.last()).vr_vllanmto := 66.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116530;
    v_dados(v_dados.last()).vr_nrctremp := 67611;
    v_dados(v_dados.last()).vr_vllanmto := 489.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116955;
    v_dados(v_dados.last()).vr_nrctremp := 195008;
    v_dados(v_dados.last()).vr_vllanmto := 31.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 117137;
    v_dados(v_dados.last()).vr_nrctremp := 192908;
    v_dados(v_dados.last()).vr_vllanmto := 71.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 128333;
    v_dados(v_dados.last()).vr_nrctremp := 174807;
    v_dados(v_dados.last()).vr_vllanmto := 99.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129046;
    v_dados(v_dados.last()).vr_nrctremp := 201380;
    v_dados(v_dados.last()).vr_vllanmto := 16.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 178763;
    v_dados(v_dados.last()).vr_vllanmto := 30.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131822;
    v_dados(v_dados.last()).vr_nrctremp := 179860;
    v_dados(v_dados.last()).vr_vllanmto := 33.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136050;
    v_dados(v_dados.last()).vr_nrctremp := 168147;
    v_dados(v_dados.last()).vr_vllanmto := 41.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136816;
    v_dados(v_dados.last()).vr_nrctremp := 189224;
    v_dados(v_dados.last()).vr_vllanmto := 38.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138207;
    v_dados(v_dados.last()).vr_nrctremp := 230115;
    v_dados(v_dados.last()).vr_vllanmto := 16.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 187057;
    v_dados(v_dados.last()).vr_vllanmto := 32.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142921;
    v_dados(v_dados.last()).vr_nrctremp := 75052;
    v_dados(v_dados.last()).vr_vllanmto := 202.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144053;
    v_dados(v_dados.last()).vr_nrctremp := 102361;
    v_dados(v_dados.last()).vr_vllanmto := 61.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145708;
    v_dados(v_dados.last()).vr_vllanmto := 29.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146013;
    v_dados(v_dados.last()).vr_nrctremp := 209282;
    v_dados(v_dados.last()).vr_vllanmto := 17.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137561;
    v_dados(v_dados.last()).vr_vllanmto := 28.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149039;
    v_dados(v_dados.last()).vr_nrctremp := 88625;
    v_dados(v_dados.last()).vr_vllanmto := 77.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133556;
    v_dados(v_dados.last()).vr_vllanmto := 61.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133557;
    v_dados(v_dados.last()).vr_vllanmto := 22.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150304;
    v_dados(v_dados.last()).vr_nrctremp := 59164;
    v_dados(v_dados.last()).vr_vllanmto := 116.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149764;
    v_dados(v_dados.last()).vr_nrctremp := 73063;
    v_dados(v_dados.last()).vr_vllanmto := 34.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 69.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 88.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135768;
    v_dados(v_dados.last()).vr_vllanmto := 126.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 162602;
    v_dados(v_dados.last()).vr_vllanmto := 19.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 245701;
    v_dados(v_dados.last()).vr_vllanmto := 3205.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156540;
    v_dados(v_dados.last()).vr_nrctremp := 120079;
    v_dados(v_dados.last()).vr_vllanmto := 54.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80361;
    v_dados(v_dados.last()).vr_vllanmto := 31.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80740;
    v_dados(v_dados.last()).vr_vllanmto := 19.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156272;
    v_dados(v_dados.last()).vr_nrctremp := 210406;
    v_dados(v_dados.last()).vr_vllanmto := 29.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 67072;
    v_dados(v_dados.last()).vr_vllanmto := 38.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 197038;
    v_dados(v_dados.last()).vr_vllanmto := 44.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158518;
    v_dados(v_dados.last()).vr_nrctremp := 215328;
    v_dados(v_dados.last()).vr_vllanmto := 81.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110736;
    v_dados(v_dados.last()).vr_vllanmto := 16.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163066;
    v_dados(v_dados.last()).vr_nrctremp := 61364;
    v_dados(v_dados.last()).vr_vllanmto := 94.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110555;
    v_dados(v_dados.last()).vr_vllanmto := 100.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := 56.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168491;
    v_dados(v_dados.last()).vr_nrctremp := 92472;
    v_dados(v_dados.last()).vr_vllanmto := 101.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 86810;
    v_dados(v_dados.last()).vr_vllanmto := 163.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54514;
    v_dados(v_dados.last()).vr_vllanmto := 33.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170119;
    v_dados(v_dados.last()).vr_nrctremp := 119673;
    v_dados(v_dados.last()).vr_vllanmto := 25.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170453;
    v_dados(v_dados.last()).vr_nrctremp := 59887;
    v_dados(v_dados.last()).vr_vllanmto := 17.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 110909;
    v_dados(v_dados.last()).vr_vllanmto := 28.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 142019;
    v_dados(v_dados.last()).vr_vllanmto := 42.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 182237;
    v_dados(v_dados.last()).vr_vllanmto := 17.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 60470;
    v_dados(v_dados.last()).vr_vllanmto := 344.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179752;
    v_dados(v_dados.last()).vr_nrctremp := 151796;
    v_dados(v_dados.last()).vr_vllanmto := 22.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83766;
    v_dados(v_dados.last()).vr_vllanmto := 141.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 196857;
    v_dados(v_dados.last()).vr_vllanmto := 20.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181218;
    v_dados(v_dados.last()).vr_nrctremp := 131509;
    v_dados(v_dados.last()).vr_vllanmto := 42.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183202;
    v_dados(v_dados.last()).vr_nrctremp := 134827;
    v_dados(v_dados.last()).vr_vllanmto := 50.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182702;
    v_dados(v_dados.last()).vr_nrctremp := 53514;
    v_dados(v_dados.last()).vr_vllanmto := 38.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 101588;
    v_dados(v_dados.last()).vr_vllanmto := 194.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 103395;
    v_dados(v_dados.last()).vr_vllanmto := 30.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183504;
    v_dados(v_dados.last()).vr_nrctremp := 237342;
    v_dados(v_dados.last()).vr_vllanmto := 21.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184470;
    v_dados(v_dados.last()).vr_nrctremp := 175964;
    v_dados(v_dados.last()).vr_vllanmto := 18.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185272;
    v_dados(v_dados.last()).vr_nrctremp := 139153;
    v_dados(v_dados.last()).vr_vllanmto := 44.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186139;
    v_dados(v_dados.last()).vr_nrctremp := 79508;
    v_dados(v_dados.last()).vr_vllanmto := 38.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 184919;
    v_dados(v_dados.last()).vr_vllanmto := 106.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 38.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188620;
    v_dados(v_dados.last()).vr_nrctremp := 90707;
    v_dados(v_dados.last()).vr_vllanmto := 143.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188158;
    v_dados(v_dados.last()).vr_nrctremp := 79186;
    v_dados(v_dados.last()).vr_vllanmto := 49.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192350;
    v_dados(v_dados.last()).vr_nrctremp := 213885;
    v_dados(v_dados.last()).vr_vllanmto := 46.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192546;
    v_dados(v_dados.last()).vr_nrctremp := 169910;
    v_dados(v_dados.last()).vr_vllanmto := 15.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192902;
    v_dados(v_dados.last()).vr_nrctremp := 87507;
    v_dados(v_dados.last()).vr_vllanmto := 192.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192929;
    v_dados(v_dados.last()).vr_nrctremp := 52884;
    v_dados(v_dados.last()).vr_vllanmto := 53.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 97404;
    v_dados(v_dados.last()).vr_vllanmto := 90.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201146;
    v_dados(v_dados.last()).vr_nrctremp := 137625;
    v_dados(v_dados.last()).vr_vllanmto := 77.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := 66.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202576;
    v_dados(v_dados.last()).vr_nrctremp := 104041;
    v_dados(v_dados.last()).vr_vllanmto := 103.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207195;
    v_dados(v_dados.last()).vr_nrctremp := 129934;
    v_dados(v_dados.last()).vr_vllanmto := 75.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 209066;
    v_dados(v_dados.last()).vr_nrctremp := 56508;
    v_dados(v_dados.last()).vr_vllanmto := 115.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214981;
    v_dados(v_dados.last()).vr_nrctremp := 71663;
    v_dados(v_dados.last()).vr_vllanmto := 108.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215570;
    v_dados(v_dados.last()).vr_nrctremp := 185045;
    v_dados(v_dados.last()).vr_vllanmto := 175.15;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216305;
    v_dados(v_dados.last()).vr_nrctremp := 97595;
    v_dados(v_dados.last()).vr_vllanmto := 70.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 111312;
    v_dados(v_dados.last()).vr_vllanmto := 26.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218847;
    v_dados(v_dados.last()).vr_nrctremp := 182279;
    v_dados(v_dados.last()).vr_vllanmto := 31.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227110;
    v_dados(v_dados.last()).vr_nrctremp := 212005;
    v_dados(v_dados.last()).vr_vllanmto := 19.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242985;
    v_dados(v_dados.last()).vr_nrctremp := 132628;
    v_dados(v_dados.last()).vr_vllanmto := 23.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 245437;
    v_dados(v_dados.last()).vr_nrctremp := 92577;
    v_dados(v_dados.last()).vr_vllanmto := 62.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 183630;
    v_dados(v_dados.last()).vr_vllanmto := 25.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 53.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 105884;
    v_dados(v_dados.last()).vr_vllanmto := 78.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 146804;
    v_dados(v_dados.last()).vr_vllanmto := 23.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 155016;
    v_dados(v_dados.last()).vr_vllanmto := 15.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263664;
    v_dados(v_dados.last()).vr_nrctremp := 185632;
    v_dados(v_dados.last()).vr_vllanmto := 45.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266450;
    v_dados(v_dados.last()).vr_nrctremp := 87972;
    v_dados(v_dados.last()).vr_vllanmto := 56.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269913;
    v_dados(v_dados.last()).vr_nrctremp := 68956;
    v_dados(v_dados.last()).vr_vllanmto := 41.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106404;
    v_dados(v_dados.last()).vr_vllanmto := 51.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 154.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 117990;
    v_dados(v_dados.last()).vr_vllanmto := 23.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273309;
    v_dados(v_dados.last()).vr_nrctremp := 197758;
    v_dados(v_dados.last()).vr_vllanmto := 23.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273821;
    v_dados(v_dados.last()).vr_nrctremp := 81164;
    v_dados(v_dados.last()).vr_vllanmto := 93.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124281;
    v_dados(v_dados.last()).vr_vllanmto := 64.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277541;
    v_dados(v_dados.last()).vr_nrctremp := 203879;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278114;
    v_dados(v_dados.last()).vr_nrctremp := 167193;
    v_dados(v_dados.last()).vr_vllanmto := 40.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278742;
    v_dados(v_dados.last()).vr_nrctremp := 83075;
    v_dados(v_dados.last()).vr_vllanmto := 107.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155954;
    v_dados(v_dados.last()).vr_vllanmto := 44.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 124814;
    v_dados(v_dados.last()).vr_vllanmto := 26.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := 87.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 291854;
    v_dados(v_dados.last()).vr_nrctremp := 162601;
    v_dados(v_dados.last()).vr_vllanmto := 207.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292206;
    v_dados(v_dados.last()).vr_nrctremp := 170286;
    v_dados(v_dados.last()).vr_vllanmto := 1185.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292303;
    v_dados(v_dados.last()).vr_nrctremp := 150969;
    v_dados(v_dados.last()).vr_vllanmto := 28.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 117419;
    v_dados(v_dados.last()).vr_vllanmto := 17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321907;
    v_dados(v_dados.last()).vr_nrctremp := 162583;
    v_dados(v_dados.last()).vr_vllanmto := 22.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 289.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 249.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 65.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334928;
    v_dados(v_dados.last()).vr_nrctremp := 97293;
    v_dados(v_dados.last()).vr_vllanmto := 1665.23;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351830;
    v_dados(v_dados.last()).vr_nrctremp := 209211;
    v_dados(v_dados.last()).vr_vllanmto := 20.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353507;
    v_dados(v_dados.last()).vr_nrctremp := 155363;
    v_dados(v_dados.last()).vr_vllanmto := 35.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 354996;
    v_dados(v_dados.last()).vr_nrctremp := 81005;
    v_dados(v_dados.last()).vr_vllanmto := 1028.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360333;
    v_dados(v_dados.last()).vr_nrctremp := 175913;
    v_dados(v_dados.last()).vr_vllanmto := 23.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 372021;
    v_dados(v_dados.last()).vr_nrctremp := 108178;
    v_dados(v_dados.last()).vr_vllanmto := 98.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395714;
    v_dados(v_dados.last()).vr_nrctremp := 185957;
    v_dados(v_dados.last()).vr_vllanmto := 45.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 64450;
    v_dados(v_dados.last()).vr_vllanmto := 24.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 384461;
    v_dados(v_dados.last()).vr_nrctremp := 51220;
    v_dados(v_dados.last()).vr_vllanmto := 169.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 386545;
    v_dados(v_dados.last()).vr_nrctremp := 51508;
    v_dados(v_dados.last()).vr_vllanmto := 196.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 119046;
    v_dados(v_dados.last()).vr_vllanmto := 26.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 71.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396770;
    v_dados(v_dados.last()).vr_nrctremp := 174032;
    v_dados(v_dados.last()).vr_vllanmto := 28.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 408298;
    v_dados(v_dados.last()).vr_nrctremp := 200556;
    v_dados(v_dados.last()).vr_vllanmto := 17.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 412481;
    v_dados(v_dados.last()).vr_nrctremp := 97843;
    v_dados(v_dados.last()).vr_vllanmto := 88.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 414433;
    v_dados(v_dados.last()).vr_nrctremp := 54746;
    v_dados(v_dados.last()).vr_vllanmto := 124.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419206;
    v_dados(v_dados.last()).vr_nrctremp := 85355;
    v_dados(v_dados.last()).vr_vllanmto := 30.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419869;
    v_dados(v_dados.last()).vr_nrctremp := 55947;
    v_dados(v_dados.last()).vr_vllanmto := 127.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425621;
    v_dados(v_dados.last()).vr_nrctremp := 193973;
    v_dados(v_dados.last()).vr_vllanmto := 31.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426610;
    v_dados(v_dados.last()).vr_nrctremp := 80116;
    v_dados(v_dados.last()).vr_vllanmto := 153.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 434183;
    v_dados(v_dados.last()).vr_nrctremp := 58723;
    v_dados(v_dados.last()).vr_vllanmto := 199.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435007;
    v_dados(v_dados.last()).vr_nrctremp := 197806;
    v_dados(v_dados.last()).vr_vllanmto := 15.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441376;
    v_dados(v_dados.last()).vr_nrctremp := 62504;
    v_dados(v_dados.last()).vr_vllanmto := 256.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 118810;
    v_dados(v_dados.last()).vr_vllanmto := 31.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114640;
    v_dados(v_dados.last()).vr_vllanmto := 65.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452211;
    v_dados(v_dados.last()).vr_nrctremp := 66716;
    v_dados(v_dados.last()).vr_vllanmto := 140.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 178.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462020;
    v_dados(v_dados.last()).vr_nrctremp := 144951;
    v_dados(v_dados.last()).vr_vllanmto := 21.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 465453;
    v_dados(v_dados.last()).vr_nrctremp := 196160;
    v_dados(v_dados.last()).vr_vllanmto := 22.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 82142;
    v_dados(v_dados.last()).vr_vllanmto := 49.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 471046;
    v_dados(v_dados.last()).vr_nrctremp := 185937;
    v_dados(v_dados.last()).vr_vllanmto := 31.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 474649;
    v_dados(v_dados.last()).vr_nrctremp := 116129;
    v_dados(v_dados.last()).vr_vllanmto := 25.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135081;
    v_dados(v_dados.last()).vr_vllanmto := 40.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135085;
    v_dados(v_dados.last()).vr_vllanmto := 21.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 485217;
    v_dados(v_dados.last()).vr_nrctremp := 216544;
    v_dados(v_dados.last()).vr_vllanmto := 57.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 119334;
    v_dados(v_dados.last()).vr_vllanmto := 17.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 136.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498211;
    v_dados(v_dados.last()).vr_nrctremp := 237892;
    v_dados(v_dados.last()).vr_vllanmto := 67.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498815;
    v_dados(v_dados.last()).vr_nrctremp := 84901;
    v_dados(v_dados.last()).vr_vllanmto := 76.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 500003;
    v_dados(v_dados.last()).vr_nrctremp := 196526;
    v_dados(v_dados.last()).vr_vllanmto := 32.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 125887;
    v_dados(v_dados.last()).vr_vllanmto := 34.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526118;
    v_dados(v_dados.last()).vr_nrctremp := 96688;
    v_dados(v_dados.last()).vr_vllanmto := 124.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 517399;
    v_dados(v_dados.last()).vr_nrctremp := 210631;
    v_dados(v_dados.last()).vr_vllanmto := 17.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 522457;
    v_dados(v_dados.last()).vr_nrctremp := 107491;
    v_dados(v_dados.last()).vr_vllanmto := 66.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524123;
    v_dados(v_dados.last()).vr_nrctremp := 94749;
    v_dados(v_dados.last()).vr_vllanmto := 241.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 145861;
    v_dados(v_dados.last()).vr_vllanmto := 43.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 97211;
    v_dados(v_dados.last()).vr_vllanmto := 243.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 175474;
    v_dados(v_dados.last()).vr_vllanmto := 28.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532711;
    v_dados(v_dados.last()).vr_nrctremp := 216332;
    v_dados(v_dados.last()).vr_vllanmto := 28.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 98825;
    v_dados(v_dados.last()).vr_vllanmto := 102.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 112505;
    v_dados(v_dados.last()).vr_vllanmto := 34.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545805;
    v_dados(v_dados.last()).vr_nrctremp := 105319;
    v_dados(v_dados.last()).vr_vllanmto := 79.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 128092;
    v_dados(v_dados.last()).vr_vllanmto := 27.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 106976;
    v_dados(v_dados.last()).vr_vllanmto := 85.44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 107679;
    v_dados(v_dados.last()).vr_vllanmto := 38.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 172784;
    v_dados(v_dados.last()).vr_vllanmto := 16.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 552488;
    v_dados(v_dados.last()).vr_nrctremp := 208642;
    v_dados(v_dados.last()).vr_vllanmto := 15.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553905;
    v_dados(v_dados.last()).vr_nrctremp := 110020;
    v_dados(v_dados.last()).vr_vllanmto := 30.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 557153;
    v_dados(v_dados.last()).vr_nrctremp := 111077;
    v_dados(v_dados.last()).vr_vllanmto := 55.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 572314;
    v_dados(v_dados.last()).vr_nrctremp := 179477;
    v_dados(v_dados.last()).vr_vllanmto := 902.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 138.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 596876;
    v_dados(v_dados.last()).vr_nrctremp := 196849;
    v_dados(v_dados.last()).vr_vllanmto := 31.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 103963;
    v_dados(v_dados.last()).vr_vllanmto := 89.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 609447;
    v_dados(v_dados.last()).vr_nrctremp := 139009;
    v_dados(v_dados.last()).vr_vllanmto := 45.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 197733;
    v_dados(v_dados.last()).vr_vllanmto := 38.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 629090;
    v_dados(v_dados.last()).vr_nrctremp := 171164;
    v_dados(v_dados.last()).vr_vllanmto := 116.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 170255;
    v_dados(v_dados.last()).vr_vllanmto := 23.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 626368;
    v_dados(v_dados.last()).vr_nrctremp := 150466;
    v_dados(v_dados.last()).vr_vllanmto := 73.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 652610;
    v_dados(v_dados.last()).vr_nrctremp := 212819;
    v_dados(v_dados.last()).vr_vllanmto := 25.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 151150;
    v_dados(v_dados.last()).vr_vllanmto := 24.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 652881;
    v_dados(v_dados.last()).vr_nrctremp := 171328;
    v_dados(v_dados.last()).vr_vllanmto := 139.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 193159;
    v_dados(v_dados.last()).vr_vllanmto := 75.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654710;
    v_dados(v_dados.last()).vr_nrctremp := 203107;
    v_dados(v_dados.last()).vr_vllanmto := 85.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662380;
    v_dados(v_dados.last()).vr_nrctremp := 163482;
    v_dados(v_dados.last()).vr_vllanmto := 170.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670324;
    v_dados(v_dados.last()).vr_nrctremp := 167935;
    v_dados(v_dados.last()).vr_vllanmto := 99.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 672130;
    v_dados(v_dados.last()).vr_nrctremp := 166378;
    v_dados(v_dados.last()).vr_vllanmto := 101.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 677132;
    v_dados(v_dados.last()).vr_nrctremp := 170004;
    v_dados(v_dados.last()).vr_vllanmto := 62.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 678856;
    v_dados(v_dados.last()).vr_nrctremp := 171515;
    v_dados(v_dados.last()).vr_vllanmto := 154.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 684660;
    v_dados(v_dados.last()).vr_nrctremp := 176178;
    v_dados(v_dados.last()).vr_vllanmto := 15.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14912775;
    v_dados(v_dados.last()).vr_nrctremp := 208297;
    v_dados(v_dados.last()).vr_vllanmto := 168.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15340805;
    v_dados(v_dados.last()).vr_nrctremp := 227532;
    v_dados(v_dados.last()).vr_vllanmto := 25.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15358933;
    v_dados(v_dados.last()).vr_nrctremp := 230002;
    v_dados(v_dados.last()).vr_vllanmto := 16.9;
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
