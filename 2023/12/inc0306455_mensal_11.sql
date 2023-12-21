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
  v_dados(v_dados.last()).vr_nrdconta := 8652007;
  v_dados(v_dados.last()).vr_nrctremp := 2507442;
  v_dados(v_dados.last()).vr_vllanmto := 94.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7669437;
  v_dados(v_dados.last()).vr_nrctremp := 2507640;
  v_dados(v_dados.last()).vr_vllanmto := 45.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9038760;
  v_dados(v_dados.last()).vr_nrctremp := 2985651;
  v_dados(v_dados.last()).vr_vllanmto := 64.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10682333;
  v_dados(v_dados.last()).vr_nrctremp := 3088171;
  v_dados(v_dados.last()).vr_vllanmto := 2129.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10682333;
  v_dados(v_dados.last()).vr_nrctremp := 3189310;
  v_dados(v_dados.last()).vr_vllanmto := 1428.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12127426;
  v_dados(v_dados.last()).vr_nrctremp := 3319430;
  v_dados(v_dados.last()).vr_vllanmto := 27.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 3383461;
  v_dados(v_dados.last()).vr_vllanmto := 162.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 575.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12397253;
  v_dados(v_dados.last()).vr_nrctremp := 3600273;
  v_dados(v_dados.last()).vr_vllanmto := 321.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80334768;
  v_dados(v_dados.last()).vr_nrctremp := 3858963;
  v_dados(v_dados.last()).vr_vllanmto := 219.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12873632;
  v_dados(v_dados.last()).vr_nrctremp := 4085979;
  v_dados(v_dados.last()).vr_vllanmto := 233.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8637733;
  v_dados(v_dados.last()).vr_nrctremp := 4101609;
  v_dados(v_dados.last()).vr_vllanmto := 97.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6319572;
  v_dados(v_dados.last()).vr_nrctremp := 4108542;
  v_dados(v_dados.last()).vr_vllanmto := 936.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12561762;
  v_dados(v_dados.last()).vr_nrctremp := 4109959;
  v_dados(v_dados.last()).vr_vllanmto := 140.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12146870;
  v_dados(v_dados.last()).vr_nrctremp := 4251082;
  v_dados(v_dados.last()).vr_vllanmto := 85.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3790622;
  v_dados(v_dados.last()).vr_nrctremp := 4307968;
  v_dados(v_dados.last()).vr_vllanmto := 355.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9942831;
  v_dados(v_dados.last()).vr_nrctremp := 4445492;
  v_dados(v_dados.last()).vr_vllanmto := 125.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12823350;
  v_dados(v_dados.last()).vr_nrctremp := 4463112;
  v_dados(v_dados.last()).vr_vllanmto := 2949.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9406352;
  v_dados(v_dados.last()).vr_nrctremp := 4576551;
  v_dados(v_dados.last()).vr_vllanmto := 7281.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3013529;
  v_dados(v_dados.last()).vr_nrctremp := 4615616;
  v_dados(v_dados.last()).vr_vllanmto := 3449.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7914857;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 57.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8496293;
  v_dados(v_dados.last()).vr_nrctremp := 4694140;
  v_dados(v_dados.last()).vr_vllanmto := 2620.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10325727;
  v_dados(v_dados.last()).vr_nrctremp := 4829682;
  v_dados(v_dados.last()).vr_vllanmto := 4715.69;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11433779;
  v_dados(v_dados.last()).vr_nrctremp := 5257224;
  v_dados(v_dados.last()).vr_vllanmto := 47.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12359980;
  v_dados(v_dados.last()).vr_nrctremp := 5290818;
  v_dados(v_dados.last()).vr_vllanmto := 641.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8684413;
  v_dados(v_dados.last()).vr_nrctremp := 5323281;
  v_dados(v_dados.last()).vr_vllanmto := 516;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9875638;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 2722.47;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6496571;
  v_dados(v_dados.last()).vr_nrctremp := 5461206;
  v_dados(v_dados.last()).vr_vllanmto := 46.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12869694;
  v_dados(v_dados.last()).vr_nrctremp := 5461441;
  v_dados(v_dados.last()).vr_vllanmto := 2174.08;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10845933;
  v_dados(v_dados.last()).vr_nrctremp := 5501714;
  v_dados(v_dados.last()).vr_vllanmto := 159.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6484034;
  v_dados(v_dados.last()).vr_nrctremp := 5546985;
  v_dados(v_dados.last()).vr_vllanmto := 42.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10031146;
  v_dados(v_dados.last()).vr_nrctremp := 5552972;
  v_dados(v_dados.last()).vr_vllanmto := 1908.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9084720;
  v_dados(v_dados.last()).vr_nrctremp := 5566176;
  v_dados(v_dados.last()).vr_vllanmto := 83.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14419394;
  v_dados(v_dados.last()).vr_nrctremp := 5573717;
  v_dados(v_dados.last()).vr_vllanmto := 22.45;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 5587986;
  v_dados(v_dados.last()).vr_vllanmto := 70.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10923101;
  v_dados(v_dados.last()).vr_nrctremp := 5661694;
  v_dados(v_dados.last()).vr_vllanmto := 1.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6819567;
  v_dados(v_dados.last()).vr_nrctremp := 5783710;
  v_dados(v_dados.last()).vr_vllanmto := 3257.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10325727;
  v_dados(v_dados.last()).vr_nrctremp := 5821028;
  v_dados(v_dados.last()).vr_vllanmto := 2515.29;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12084824;
  v_dados(v_dados.last()).vr_nrctremp := 5872763;
  v_dados(v_dados.last()).vr_vllanmto := 3093.07;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14526077;
  v_dados(v_dados.last()).vr_nrctremp := 5895954;
  v_dados(v_dados.last()).vr_vllanmto := 10366.82;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11689668;
  v_dados(v_dados.last()).vr_nrctremp := 5905890;
  v_dados(v_dados.last()).vr_vllanmto := 6.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916683;
  v_dados(v_dados.last()).vr_vllanmto := 126.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11326816;
  v_dados(v_dados.last()).vr_nrctremp := 6024671;
  v_dados(v_dados.last()).vr_vllanmto := 37.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11310480;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 202;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10750029;
  v_dados(v_dados.last()).vr_nrctremp := 6135678;
  v_dados(v_dados.last()).vr_vllanmto := 30.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12103721;
  v_dados(v_dados.last()).vr_nrctremp := 6277579;
  v_dados(v_dados.last()).vr_vllanmto := 235.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13167537;
  v_dados(v_dados.last()).vr_nrctremp := 6440873;
  v_dados(v_dados.last()).vr_vllanmto := 88.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16043812;
  v_dados(v_dados.last()).vr_nrctremp := 6468398;
  v_dados(v_dados.last()).vr_vllanmto := 2766.01;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10675515;
  v_dados(v_dados.last()).vr_nrctremp := 6524795;
  v_dados(v_dados.last()).vr_vllanmto := 12.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15062449;
  v_dados(v_dados.last()).vr_nrctremp := 6597582;
  v_dados(v_dados.last()).vr_vllanmto := 73.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12967467;
  v_dados(v_dados.last()).vr_nrctremp := 6613536;
  v_dados(v_dados.last()).vr_vllanmto := 161.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13803107;
  v_dados(v_dados.last()).vr_nrctremp := 6647967;
  v_dados(v_dados.last()).vr_vllanmto := 182.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12193860;
  v_dados(v_dados.last()).vr_nrctremp := 6678616;
  v_dados(v_dados.last()).vr_vllanmto := 26.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15215997;
  v_dados(v_dados.last()).vr_nrctremp := 6679265;
  v_dados(v_dados.last()).vr_vllanmto := 113.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11075252;
  v_dados(v_dados.last()).vr_nrctremp := 6735712;
  v_dados(v_dados.last()).vr_vllanmto := 76.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15609766;
  v_dados(v_dados.last()).vr_nrctremp := 6863294;
  v_dados(v_dados.last()).vr_vllanmto := 3700.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10426000;
  v_dados(v_dados.last()).vr_nrctremp := 6975315;
  v_dados(v_dados.last()).vr_vllanmto := 12.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10106383;
  v_dados(v_dados.last()).vr_nrctremp := 7068455;
  v_dados(v_dados.last()).vr_vllanmto := 20.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7283989;
  v_dados(v_dados.last()).vr_nrctremp := 571824979;
  v_dados(v_dados.last()).vr_vllanmto := 1426.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 866547;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 47.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 217.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 902519;
  v_dados(v_dados.last()).vr_nrctremp := 318129;
  v_dados(v_dados.last()).vr_vllanmto := 44.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931314;
  v_dados(v_dados.last()).vr_nrctremp := 322787;
  v_dados(v_dados.last()).vr_vllanmto := 84.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 757365;
  v_dados(v_dados.last()).vr_nrctremp := 325061;
  v_dados(v_dados.last()).vr_vllanmto := 159.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 958883;
  v_dados(v_dados.last()).vr_nrctremp := 329872;
  v_dados(v_dados.last()).vr_vllanmto := 83.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 682993;
  v_dados(v_dados.last()).vr_nrctremp := 333984;
  v_dados(v_dados.last()).vr_vllanmto := 215.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 663778;
  v_dados(v_dados.last()).vr_nrctremp := 336241;
  v_dados(v_dados.last()).vr_vllanmto := 22.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1106880;
  v_dados(v_dados.last()).vr_nrctremp := 345685;
  v_dados(v_dados.last()).vr_vllanmto := 7.69;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 348292;
  v_dados(v_dados.last()).vr_vllanmto := 350.83;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1014935;
  v_dados(v_dados.last()).vr_nrctremp := 374317;
  v_dados(v_dados.last()).vr_vllanmto := 565.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 809560;
  v_dados(v_dados.last()).vr_nrctremp := 381601;
  v_dados(v_dados.last()).vr_vllanmto := 37.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15768279;
  v_dados(v_dados.last()).vr_nrctremp := 421314;
  v_dados(v_dados.last()).vr_vllanmto := 25.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15852431;
  v_dados(v_dados.last()).vr_nrctremp := 425028;
  v_dados(v_dados.last()).vr_vllanmto := 46.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 15699927;
  v_dados(v_dados.last()).vr_nrctremp := 427146;
  v_dados(v_dados.last()).vr_vllanmto := 18.09;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16891732;
  v_dados(v_dados.last()).vr_nrctremp := 463382;
  v_dados(v_dados.last()).vr_vllanmto := 11.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 17351049;
  v_dados(v_dados.last()).vr_nrctremp := 480606;
  v_dados(v_dados.last()).vr_vllanmto := 24.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 150045;
  v_dados(v_dados.last()).vr_nrctremp := 95929;
  v_dados(v_dados.last()).vr_vllanmto := 337.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 304174;
  v_dados(v_dados.last()).vr_nrctremp := 99070;
  v_dados(v_dados.last()).vr_vllanmto := 20.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 315516;
  v_dados(v_dados.last()).vr_nrctremp := 95930;
  v_dados(v_dados.last()).vr_vllanmto := 19.33;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 348732;
  v_dados(v_dados.last()).vr_nrctremp := 59739;
  v_dados(v_dados.last()).vr_vllanmto := 23.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 349682;
  v_dados(v_dados.last()).vr_nrctremp := 60356;
  v_dados(v_dados.last()).vr_vllanmto := 3174.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14430177;
  v_dados(v_dados.last()).vr_nrctremp := 65975;
  v_dados(v_dados.last()).vr_vllanmto := 71.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 16125347;
  v_dados(v_dados.last()).vr_nrctremp := 112866;
  v_dados(v_dados.last()).vr_vllanmto := 19.34;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14166313;
  v_dados(v_dados.last()).vr_nrctremp := 71878;
  v_dados(v_dados.last()).vr_vllanmto := 194.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14346109;
  v_dados(v_dados.last()).vr_nrctremp := 73941;
  v_dados(v_dados.last()).vr_vllanmto := 33.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14348390;
  v_dados(v_dados.last()).vr_nrctremp := 74050;
  v_dados(v_dados.last()).vr_vllanmto := 65.51;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14254085;
  v_dados(v_dados.last()).vr_nrctremp := 74207;
  v_dados(v_dados.last()).vr_vllanmto := 270.81;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14418940;
  v_dados(v_dados.last()).vr_nrctremp := 75101;
  v_dados(v_dados.last()).vr_vllanmto := 118.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14542056;
  v_dados(v_dados.last()).vr_nrctremp := 76994;
  v_dados(v_dados.last()).vr_vllanmto := 67.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14287943;
  v_dados(v_dados.last()).vr_nrctremp := 79178;
  v_dados(v_dados.last()).vr_vllanmto := 24.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 446025;
  v_dados(v_dados.last()).vr_nrctremp := 83056;
  v_dados(v_dados.last()).vr_vllanmto := 51.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85491;
  v_dados(v_dados.last()).vr_vllanmto := 13.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85493;
  v_dados(v_dados.last()).vr_vllanmto := 17.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15039285;
  v_dados(v_dados.last()).vr_nrctremp := 85494;
  v_dados(v_dados.last()).vr_vllanmto := 11.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15335305;
  v_dados(v_dados.last()).vr_nrctremp := 88160;
  v_dados(v_dados.last()).vr_vllanmto := 41.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14426650;
  v_dados(v_dados.last()).vr_nrctremp := 90754;
  v_dados(v_dados.last()).vr_vllanmto := 31.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15295974;
  v_dados(v_dados.last()).vr_nrctremp := 91837;
  v_dados(v_dados.last()).vr_vllanmto := 12.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15695530;
  v_dados(v_dados.last()).vr_nrctremp := 92488;
  v_dados(v_dados.last()).vr_vllanmto := 1535.53;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16006399;
  v_dados(v_dados.last()).vr_nrctremp := 97494;
  v_dados(v_dados.last()).vr_vllanmto := 44.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 406791;
  v_dados(v_dados.last()).vr_nrctremp := 103941;
  v_dados(v_dados.last()).vr_vllanmto := 27.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16695020;
  v_dados(v_dados.last()).vr_nrctremp := 111559;
  v_dados(v_dados.last()).vr_vllanmto := 29.25;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 128830;
  v_dados(v_dados.last()).vr_nrctremp := 73341;
  v_dados(v_dados.last()).vr_vllanmto := 179.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 314226;
  v_dados(v_dados.last()).vr_nrctremp := 79049;
  v_dados(v_dados.last()).vr_vllanmto := 23080.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 435481;
  v_dados(v_dados.last()).vr_nrctremp := 69854;
  v_dados(v_dados.last()).vr_vllanmto := 38.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 15242617;
  v_dados(v_dados.last()).vr_nrctremp := 85458;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 17107393;
  v_dados(v_dados.last()).vr_nrctremp := 89187;
  v_dados(v_dados.last()).vr_vllanmto := 413.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 47694;
  v_dados(v_dados.last()).vr_nrctremp := 32701;
  v_dados(v_dados.last()).vr_vllanmto := 2842.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 190039;
  v_dados(v_dados.last()).vr_nrctremp := 38452;
  v_dados(v_dados.last()).vr_vllanmto := 3309.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 14841908;
  v_dados(v_dados.last()).vr_nrctremp := 43421;
  v_dados(v_dados.last()).vr_vllanmto := 418.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15988198;
  v_dados(v_dados.last()).vr_nrctremp := 44283;
  v_dados(v_dados.last()).vr_vllanmto := 500.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 140481;
  v_dados(v_dados.last()).vr_nrctremp := 44721;
  v_dados(v_dados.last()).vr_vllanmto := 29.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 189995;
  v_dados(v_dados.last()).vr_nrctremp := 45413;
  v_dados(v_dados.last()).vr_vllanmto := 18.34;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77038;
  v_dados(v_dados.last()).vr_nrctremp := 45687;
  v_dados(v_dados.last()).vr_vllanmto := 117.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 709735;
  v_dados(v_dados.last()).vr_nrctremp := 144800;
  v_dados(v_dados.last()).vr_vllanmto := 74.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 258334;
  v_dados(v_dados.last()).vr_nrctremp := 160195;
  v_dados(v_dados.last()).vr_vllanmto := 6566.96;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 340790;
  v_dados(v_dados.last()).vr_nrctremp := 176369;
  v_dados(v_dados.last()).vr_vllanmto := 540.83;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 656470;
  v_dados(v_dados.last()).vr_nrctremp := 213344;
  v_dados(v_dados.last()).vr_vllanmto := 444.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 829366;
  v_dados(v_dados.last()).vr_nrctremp := 261350;
  v_dados(v_dados.last()).vr_vllanmto := 239.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 656283;
  v_dados(v_dados.last()).vr_nrctremp := 307231;
  v_dados(v_dados.last()).vr_vllanmto := 9756.75;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16125673;
  v_dados(v_dados.last()).vr_nrctremp := 309197;
  v_dados(v_dados.last()).vr_vllanmto := 225.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16087569;
  v_dados(v_dados.last()).vr_nrctremp := 312066;
  v_dados(v_dados.last()).vr_vllanmto := 221.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15316734;
  v_dados(v_dados.last()).vr_nrctremp := 317120;
  v_dados(v_dados.last()).vr_vllanmto := 272.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16319036;
  v_dados(v_dados.last()).vr_nrctremp := 318272;
  v_dados(v_dados.last()).vr_vllanmto := 6207.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16745965;
  v_dados(v_dados.last()).vr_nrctremp := 339590;
  v_dados(v_dados.last()).vr_vllanmto := 626.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16709616;
  v_dados(v_dados.last()).vr_nrctremp := 341925;
  v_dados(v_dados.last()).vr_vllanmto := 76.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 987581;
  v_dados(v_dados.last()).vr_nrctremp := 359973;
  v_dados(v_dados.last()).vr_vllanmto := 51.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15128792;
  v_dados(v_dados.last()).vr_nrctremp := 371162;
  v_dados(v_dados.last()).vr_vllanmto := 19248.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 384461;
  v_dados(v_dados.last()).vr_nrctremp := 51220;
  v_dados(v_dados.last()).vr_vllanmto := 982.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 175609;
  v_dados(v_dados.last()).vr_nrctremp := 51504;
  v_dados(v_dados.last()).vr_vllanmto := 381.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 386545;
  v_dados(v_dados.last()).vr_nrctremp := 51508;
  v_dados(v_dados.last()).vr_vllanmto := 1701.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 256544;
  v_dados(v_dados.last()).vr_nrctremp := 58944;
  v_dados(v_dados.last()).vr_vllanmto := 261.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 550;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 222348;
  v_dados(v_dados.last()).vr_nrctremp := 84303;
  v_dados(v_dados.last()).vr_vllanmto := 1016.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 76961;
  v_dados(v_dados.last()).vr_nrctremp := 93710;
  v_dados(v_dados.last()).vr_vllanmto := 78.28;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 287024;
  v_dados(v_dados.last()).vr_nrctremp := 94244;
  v_dados(v_dados.last()).vr_vllanmto := 928.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 201.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 121304;
  v_dados(v_dados.last()).vr_nrctremp := 99096;
  v_dados(v_dados.last()).vr_vllanmto := 6.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 106976;
  v_dados(v_dados.last()).vr_vllanmto := 4.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 94730;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 73.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 113391;
  v_dados(v_dados.last()).vr_vllanmto := 147.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 303771;
  v_dados(v_dados.last()).vr_nrctremp := 128054;
  v_dados(v_dados.last()).vr_vllanmto := 12.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 128092;
  v_dados(v_dados.last()).vr_vllanmto := 100.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 311863;
  v_dados(v_dados.last()).vr_nrctremp := 135708;
  v_dados(v_dados.last()).vr_vllanmto := 1070.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 80250;
  v_dados(v_dados.last()).vr_nrctremp := 139169;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 396.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139845;
  v_dados(v_dados.last()).vr_vllanmto := 450.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 141142;
  v_dados(v_dados.last()).vr_vllanmto := 153.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 111.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 60.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 148826;
  v_dados(v_dados.last()).vr_vllanmto := 453.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 150785;
  v_dados(v_dados.last()).vr_vllanmto := 381.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 442240;
  v_dados(v_dados.last()).vr_nrctremp := 151553;
  v_dados(v_dados.last()).vr_vllanmto := 422.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129410;
  v_dados(v_dados.last()).vr_nrctremp := 158870;
  v_dados(v_dados.last()).vr_vllanmto := 119.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382833;
  v_dados(v_dados.last()).vr_nrctremp := 163160;
  v_dados(v_dados.last()).vr_vllanmto := 20.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 165366;
  v_dados(v_dados.last()).vr_vllanmto := 161.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 258636;
  v_dados(v_dados.last()).vr_nrctremp := 165420;
  v_dados(v_dados.last()).vr_vllanmto := 4487.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 9482;
  v_dados(v_dados.last()).vr_nrctremp := 166510;
  v_dados(v_dados.last()).vr_vllanmto := 118.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 183334;
  v_dados(v_dados.last()).vr_nrctremp := 172593;
  v_dados(v_dados.last()).vr_vllanmto := 1379.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 33472;
  v_dados(v_dados.last()).vr_nrctremp := 172807;
  v_dados(v_dados.last()).vr_vllanmto := 13261.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 598410;
  v_dados(v_dados.last()).vr_nrctremp := 172974;
  v_dados(v_dados.last()).vr_vllanmto := 31923.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 185908;
  v_dados(v_dados.last()).vr_vllanmto := 58.09;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 57.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 187546;
  v_dados(v_dados.last()).vr_vllanmto := 623.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 102911;
  v_dados(v_dados.last()).vr_nrctremp := 193069;
  v_dados(v_dados.last()).vr_vllanmto := 14.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 194673;
  v_dados(v_dados.last()).vr_vllanmto := 234.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61751;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 323.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 202660;
  v_dados(v_dados.last()).vr_vllanmto := 578.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 539759;
  v_dados(v_dados.last()).vr_nrctremp := 203098;
  v_dados(v_dados.last()).vr_vllanmto := 78.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185531;
  v_dados(v_dados.last()).vr_nrctremp := 205263;
  v_dados(v_dados.last()).vr_vllanmto := 59.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 480517;
  v_dados(v_dados.last()).vr_nrctremp := 209089;
  v_dados(v_dados.last()).vr_vllanmto := 128.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 6934.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 261122;
  v_dados(v_dados.last()).vr_nrctremp := 210724;
  v_dados(v_dados.last()).vr_vllanmto := 45.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668680;
  v_dados(v_dados.last()).vr_nrctremp := 216343;
  v_dados(v_dados.last()).vr_vllanmto := 4143.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668680;
  v_dados(v_dados.last()).vr_nrctremp := 216645;
  v_dados(v_dados.last()).vr_vllanmto := 5806.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 436801;
  v_dados(v_dados.last()).vr_nrctremp := 218225;
  v_dados(v_dados.last()).vr_vllanmto := 3157.36;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 222053;
  v_dados(v_dados.last()).vr_vllanmto := 18.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 584.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78638;
  v_dados(v_dados.last()).vr_nrctremp := 225615;
  v_dados(v_dados.last()).vr_vllanmto := 15.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565849;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 2934.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668680;
  v_dados(v_dados.last()).vr_nrctremp := 230185;
  v_dados(v_dados.last()).vr_vllanmto := 16565.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 507210;
  v_dados(v_dados.last()).vr_nrctremp := 230274;
  v_dados(v_dados.last()).vr_vllanmto := 241.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 698;
  v_dados(v_dados.last()).vr_nrctremp := 233794;
  v_dados(v_dados.last()).vr_vllanmto := 649.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 236669;
  v_dados(v_dados.last()).vr_vllanmto := 493.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 268569;
  v_dados(v_dados.last()).vr_nrctremp := 236688;
  v_dados(v_dados.last()).vr_vllanmto := 419.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145947;
  v_dados(v_dados.last()).vr_nrctremp := 240761;
  v_dados(v_dados.last()).vr_vllanmto := 1110.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 241295;
  v_dados(v_dados.last()).vr_vllanmto := 11279.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 420905;
  v_dados(v_dados.last()).vr_nrctremp := 241303;
  v_dados(v_dados.last()).vr_vllanmto := 158.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14602733;
  v_dados(v_dados.last()).vr_nrctremp := 244871;
  v_dados(v_dados.last()).vr_vllanmto := 7375.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 245466;
  v_dados(v_dados.last()).vr_vllanmto := 71.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 451088;
  v_dados(v_dados.last()).vr_nrctremp := 250791;
  v_dados(v_dados.last()).vr_vllanmto := 436.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 697486;
  v_dados(v_dados.last()).vr_nrctremp := 252060;
  v_dados(v_dados.last()).vr_vllanmto := 4001.59;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14630958;
  v_dados(v_dados.last()).vr_nrctremp := 252114;
  v_dados(v_dados.last()).vr_vllanmto := 24.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170488;
  v_dados(v_dados.last()).vr_nrctremp := 252797;
  v_dados(v_dados.last()).vr_vllanmto := 626.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445550;
  v_dados(v_dados.last()).vr_nrctremp := 253030;
  v_dados(v_dados.last()).vr_vllanmto := 193.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 679127;
  v_dados(v_dados.last()).vr_nrctremp := 262237;
  v_dados(v_dados.last()).vr_vllanmto := 15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14958;
  v_dados(v_dados.last()).vr_nrctremp := 264032;
  v_dados(v_dados.last()).vr_vllanmto := 11.51;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16145399;
  v_dados(v_dados.last()).vr_nrctremp := 264117;
  v_dados(v_dados.last()).vr_vllanmto := 511.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15685233;
  v_dados(v_dados.last()).vr_nrctremp := 266075;
  v_dados(v_dados.last()).vr_vllanmto := 13.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 299596;
  v_dados(v_dados.last()).vr_nrctremp := 266459;
  v_dados(v_dados.last()).vr_vllanmto := 345.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16257324;
  v_dados(v_dados.last()).vr_nrctremp := 268640;
  v_dados(v_dados.last()).vr_vllanmto := 418.42;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 808.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328014;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 417.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14601087;
  v_dados(v_dados.last()).vr_nrctremp := 281189;
  v_dados(v_dados.last()).vr_vllanmto := 18.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15152952;
  v_dados(v_dados.last()).vr_nrctremp := 284519;
  v_dados(v_dados.last()).vr_vllanmto := 28.29;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 284704;
  v_dados(v_dados.last()).vr_vllanmto := 1623.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 18180;
  v_dados(v_dados.last()).vr_nrctremp := 287995;
  v_dados(v_dados.last()).vr_vllanmto := 376.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14552345;
  v_dados(v_dados.last()).vr_nrctremp := 290158;
  v_dados(v_dados.last()).vr_vllanmto := 7437.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 249475;
  v_dados(v_dados.last()).vr_nrctremp := 291676;
  v_dados(v_dados.last()).vr_vllanmto := 78.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 295195;
  v_dados(v_dados.last()).vr_vllanmto := 64.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15725979;
  v_dados(v_dados.last()).vr_nrctremp := 298678;
  v_dados(v_dados.last()).vr_vllanmto := 52.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 204803;
  v_dados(v_dados.last()).vr_nrctremp := 300046;
  v_dados(v_dados.last()).vr_vllanmto := 12.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 3905;
  v_dados(v_dados.last()).vr_nrctremp := 300931;
  v_dados(v_dados.last()).vr_vllanmto := 76.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16909119;
  v_dados(v_dados.last()).vr_nrctremp := 304970;
  v_dados(v_dados.last()).vr_vllanmto := .72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 335690;
  v_dados(v_dados.last()).vr_nrctremp := 77871;
  v_dados(v_dados.last()).vr_vllanmto := 697.19;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 943320;
  v_dados(v_dados.last()).vr_nrctremp := 330956;
  v_dados(v_dados.last()).vr_vllanmto := 84.98;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1026100;
  v_dados(v_dados.last()).vr_nrctremp := 425701;
  v_dados(v_dados.last()).vr_vllanmto := 123.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 90530;
  v_dados(v_dados.last()).vr_nrctremp := 494717;
  v_dados(v_dados.last()).vr_vllanmto := 613.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 316091;
  v_dados(v_dados.last()).vr_nrctremp := 520270;
  v_dados(v_dados.last()).vr_vllanmto := 811.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2922851;
  v_dados(v_dados.last()).vr_nrctremp := 555897;
  v_dados(v_dados.last()).vr_vllanmto := 36.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1000462;
  v_dados(v_dados.last()).vr_nrctremp := 594282;
  v_dados(v_dados.last()).vr_vllanmto := 174.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1080253;
  v_dados(v_dados.last()).vr_nrctremp := 617809;
  v_dados(v_dados.last()).vr_vllanmto := 95.39;
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
