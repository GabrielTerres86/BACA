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
    v_dados(v_dados.last()).vr_nrdconta := 10819967;
    v_dados(v_dados.last()).vr_nrctremp := 3159652;
    v_dados(v_dados.last()).vr_vllanmto := 5337.55;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10283439;
    v_dados(v_dados.last()).vr_nrctremp := 2042069;
    v_dados(v_dados.last()).vr_vllanmto := 3746.62;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2752336;
    v_dados(v_dados.last()).vr_nrctremp := 3884678;
    v_dados(v_dados.last()).vr_vllanmto := 329.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10688803;
    v_dados(v_dados.last()).vr_nrctremp := 5541451;
    v_dados(v_dados.last()).vr_vllanmto := 315.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7178565;
    v_dados(v_dados.last()).vr_nrctremp := 4556663;
    v_dados(v_dados.last()).vr_vllanmto := 252.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6683045;
    v_dados(v_dados.last()).vr_nrctremp := 3919366;
    v_dados(v_dados.last()).vr_vllanmto := 199.85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10688803;
    v_dados(v_dados.last()).vr_nrctremp := 5460810;
    v_dados(v_dados.last()).vr_vllanmto := 182.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12509680;
    v_dados(v_dados.last()).vr_nrctremp := 4175452;
    v_dados(v_dados.last()).vr_vllanmto := 153.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10827200;
    v_dados(v_dados.last()).vr_nrctremp := 3008250;
    v_dados(v_dados.last()).vr_vllanmto := 136.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11593059;
    v_dados(v_dados.last()).vr_nrctremp := 5159171;
    v_dados(v_dados.last()).vr_vllanmto := 96.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80170781;
    v_dados(v_dados.last()).vr_nrctremp := 3472408;
    v_dados(v_dados.last()).vr_vllanmto := 75.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80337074;
    v_dados(v_dados.last()).vr_nrctremp := 2955519;
    v_dados(v_dados.last()).vr_vllanmto := 61.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13011600;
    v_dados(v_dados.last()).vr_nrctremp := 5349520;
    v_dados(v_dados.last()).vr_vllanmto := 54.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80241247;
    v_dados(v_dados.last()).vr_nrctremp := 2046910;
    v_dados(v_dados.last()).vr_vllanmto := 51.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12578827;
    v_dados(v_dados.last()).vr_nrctremp := 5665047;
    v_dados(v_dados.last()).vr_vllanmto := 50.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13389408;
    v_dados(v_dados.last()).vr_nrctremp := 4639193;
    v_dados(v_dados.last()).vr_vllanmto := 49.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9868925;
    v_dados(v_dados.last()).vr_nrctremp := 3230862;
    v_dados(v_dados.last()).vr_vllanmto := 42.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13151088;
    v_dados(v_dados.last()).vr_nrctremp := 4375227;
    v_dados(v_dados.last()).vr_vllanmto := 34.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12825212;
    v_dados(v_dados.last()).vr_nrctremp := 4576380;
    v_dados(v_dados.last()).vr_vllanmto := 32.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12688665;
    v_dados(v_dados.last()).vr_nrctremp := 5246944;
    v_dados(v_dados.last()).vr_vllanmto := 29.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12381020;
    v_dados(v_dados.last()).vr_nrctremp := 5103175;
    v_dados(v_dados.last()).vr_vllanmto := 28.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10325689;
    v_dados(v_dados.last()).vr_nrctremp := 5598139;
    v_dados(v_dados.last()).vr_vllanmto := 23.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 5533545;
    v_dados(v_dados.last()).vr_vllanmto := 22.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12182249;
    v_dados(v_dados.last()).vr_nrctremp := 5319781;
    v_dados(v_dados.last()).vr_vllanmto := 22.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 21.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817678;
    v_dados(v_dados.last()).vr_nrctremp := 4256682;
    v_dados(v_dados.last()).vr_vllanmto := 21.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2415119;
    v_dados(v_dados.last()).vr_nrctremp := 4440402;
    v_dados(v_dados.last()).vr_vllanmto := 20.52;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 5076020;
    v_dados(v_dados.last()).vr_vllanmto := 19.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8257035;
    v_dados(v_dados.last()).vr_nrctremp := 5440866;
    v_dados(v_dados.last()).vr_vllanmto := 19.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710091;
    v_dados(v_dados.last()).vr_nrctremp := 3935842;
    v_dados(v_dados.last()).vr_vllanmto := 19.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12784630;
    v_dados(v_dados.last()).vr_nrctremp := 5782397;
    v_dados(v_dados.last()).vr_vllanmto := 18.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725262;
    v_dados(v_dados.last()).vr_nrctremp := 4846774;
    v_dados(v_dados.last()).vr_vllanmto := 17.95;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13132504;
    v_dados(v_dados.last()).vr_nrctremp := 4346910;
    v_dados(v_dados.last()).vr_vllanmto := 17.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6587216;
    v_dados(v_dados.last()).vr_nrctremp := 5309033;
    v_dados(v_dados.last()).vr_vllanmto := 17.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11754079;
    v_dados(v_dados.last()).vr_nrctremp := 5034347;
    v_dados(v_dados.last()).vr_vllanmto := 16.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12706523;
    v_dados(v_dados.last()).vr_nrctremp := 4160235;
    v_dados(v_dados.last()).vr_vllanmto := 14.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3183076;
    v_dados(v_dados.last()).vr_nrctremp := 5369358;
    v_dados(v_dados.last()).vr_vllanmto := 14.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12183890;
    v_dados(v_dados.last()).vr_nrctremp := 5541276;
    v_dados(v_dados.last()).vr_vllanmto := 14.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12756466;
    v_dados(v_dados.last()).vr_nrctremp := 4210230;
    v_dados(v_dados.last()).vr_vllanmto := 13.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212202;
    v_dados(v_dados.last()).vr_nrctremp := 5533981;
    v_dados(v_dados.last()).vr_vllanmto := 13.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12311170;
    v_dados(v_dados.last()).vr_nrctremp := 5511151;
    v_dados(v_dados.last()).vr_vllanmto := 13.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12833797;
    v_dados(v_dados.last()).vr_nrctremp := 4181782;
    v_dados(v_dados.last()).vr_vllanmto := 12.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80066810;
    v_dados(v_dados.last()).vr_nrctremp := 5793704;
    v_dados(v_dados.last()).vr_vllanmto := 11.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6797792;
    v_dados(v_dados.last()).vr_nrctremp := 5748538;
    v_dados(v_dados.last()).vr_vllanmto := 11.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11483598;
    v_dados(v_dados.last()).vr_nrctremp := 5492369;
    v_dados(v_dados.last()).vr_vllanmto := 11.35;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 11.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13520563;
    v_dados(v_dados.last()).vr_nrctremp := 5484482;
    v_dados(v_dados.last()).vr_vllanmto := 9.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13023020;
    v_dados(v_dados.last()).vr_nrctremp := 4301698;
    v_dados(v_dados.last()).vr_vllanmto := 9.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12785369;
    v_dados(v_dados.last()).vr_nrctremp := 4083531;
    v_dados(v_dados.last()).vr_vllanmto := 9.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4201717;
    v_dados(v_dados.last()).vr_vllanmto := 9.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4226847;
    v_dados(v_dados.last()).vr_vllanmto := 9.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665944;
    v_dados(v_dados.last()).vr_nrctremp := 4706959;
    v_dados(v_dados.last()).vr_vllanmto := 8.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8613010;
    v_dados(v_dados.last()).vr_nrctremp := 5775082;
    v_dados(v_dados.last()).vr_vllanmto := 7.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7471955;
    v_dados(v_dados.last()).vr_nrctremp := 5750249;
    v_dados(v_dados.last()).vr_vllanmto := 7.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12487937;
    v_dados(v_dados.last()).vr_nrctremp := 5598211;
    v_dados(v_dados.last()).vr_vllanmto := 7.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12903523;
    v_dados(v_dados.last()).vr_nrctremp := 5811915;
    v_dados(v_dados.last()).vr_vllanmto := 7.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 5646627;
    v_dados(v_dados.last()).vr_vllanmto := 6.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 15029433;
    v_dados(v_dados.last()).vr_nrctremp := 5748692;
    v_dados(v_dados.last()).vr_vllanmto := 6.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13481622;
    v_dados(v_dados.last()).vr_nrctremp := 5597672;
    v_dados(v_dados.last()).vr_vllanmto := 6.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 5647604;
    v_dados(v_dados.last()).vr_vllanmto := 6.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 4542269;
    v_dados(v_dados.last()).vr_vllanmto := 6.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12324841;
    v_dados(v_dados.last()).vr_nrctremp := 5722854;
    v_dados(v_dados.last()).vr_vllanmto := 6.09;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576196;
    v_dados(v_dados.last()).vr_vllanmto := 6.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413887;
    v_dados(v_dados.last()).vr_nrctremp := 4535597;
    v_dados(v_dados.last()).vr_vllanmto := 5.52;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 773565;
    v_dados(v_dados.last()).vr_nrctremp := 4922540;
    v_dados(v_dados.last()).vr_vllanmto := 5.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601179;
    v_dados(v_dados.last()).vr_nrctremp := 5736851;
    v_dados(v_dados.last()).vr_vllanmto := 5.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3968944;
    v_dados(v_dados.last()).vr_nrctremp := 6009963;
    v_dados(v_dados.last()).vr_vllanmto := 5.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097768;
    v_dados(v_dados.last()).vr_vllanmto := 4.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4050061;
    v_dados(v_dados.last()).vr_nrctremp := 2595397;
    v_dados(v_dados.last()).vr_vllanmto := 4.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13147110;
    v_dados(v_dados.last()).vr_nrctremp := 4511852;
    v_dados(v_dados.last()).vr_vllanmto := 4.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712643;
    v_dados(v_dados.last()).vr_nrctremp := 5690700;
    v_dados(v_dados.last()).vr_vllanmto := 4.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13174894;
    v_dados(v_dados.last()).vr_nrctremp := 4364977;
    v_dados(v_dados.last()).vr_vllanmto := 4.15;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3855929;
    v_dados(v_dados.last()).vr_nrctremp := 5811706;
    v_dados(v_dados.last()).vr_vllanmto := 3.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716200;
    v_dados(v_dados.last()).vr_nrctremp := 3996934;
    v_dados(v_dados.last()).vr_vllanmto := 3.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13432109;
    v_dados(v_dados.last()).vr_nrctremp := 4500315;
    v_dados(v_dados.last()).vr_vllanmto := 3.09;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12182249;
    v_dados(v_dados.last()).vr_nrctremp := 5777537;
    v_dados(v_dados.last()).vr_vllanmto := 2.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3890428;
    v_dados(v_dados.last()).vr_vllanmto := 2.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 5125079;
    v_dados(v_dados.last()).vr_vllanmto := 2.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80099920;
    v_dados(v_dados.last()).vr_nrctremp := 5085776;
    v_dados(v_dados.last()).vr_vllanmto := 1.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13151088;
    v_dados(v_dados.last()).vr_nrctremp := 4499659;
    v_dados(v_dados.last()).vr_vllanmto := 1.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13235087;
    v_dados(v_dados.last()).vr_nrctremp := 4369330;
    v_dados(v_dados.last()).vr_vllanmto := 1.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14701057;
    v_dados(v_dados.last()).vr_nrctremp := 5735284;
    v_dados(v_dados.last()).vr_vllanmto := 1.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10099468;
    v_dados(v_dados.last()).vr_nrctremp := 5308286;
    v_dados(v_dados.last()).vr_vllanmto := .97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717017;
    v_dados(v_dados.last()).vr_nrctremp := 4394694;
    v_dados(v_dados.last()).vr_vllanmto := .95;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11941650;
    v_dados(v_dados.last()).vr_nrctremp := 4302378;
    v_dados(v_dados.last()).vr_vllanmto := .76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 4499626;
    v_dados(v_dados.last()).vr_vllanmto := .67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12412902;
    v_dados(v_dados.last()).vr_nrctremp := 5996814;
    v_dados(v_dados.last()).vr_vllanmto := .44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3449703;
    v_dados(v_dados.last()).vr_vllanmto := .41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2269570;
    v_dados(v_dados.last()).vr_nrctremp := 5901353;
    v_dados(v_dados.last()).vr_vllanmto := .28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10745238;
    v_dados(v_dados.last()).vr_nrctremp := 5945969;
    v_dados(v_dados.last()).vr_vllanmto := .26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12790079;
    v_dados(v_dados.last()).vr_nrctremp := 5962537;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8498750;
    v_dados(v_dados.last()).vr_nrctremp := 5285090;
    v_dados(v_dados.last()).vr_vllanmto := .14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637106;
    v_dados(v_dados.last()).vr_nrctremp := 3868680;
    v_dados(v_dados.last()).vr_vllanmto := .34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 4059743;
    v_dados(v_dados.last()).vr_vllanmto := .35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7668732;
    v_dados(v_dados.last()).vr_nrctremp := 4885568;
    v_dados(v_dados.last()).vr_vllanmto := .6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3968944;
    v_dados(v_dados.last()).vr_nrctremp := 5306989;
    v_dados(v_dados.last()).vr_vllanmto := .85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4087763;
    v_dados(v_dados.last()).vr_nrctremp := 2955861;
    v_dados(v_dados.last()).vr_vllanmto := 2.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7986726;
    v_dados(v_dados.last()).vr_nrctremp := 5427406;
    v_dados(v_dados.last()).vr_vllanmto := 1.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11901756;
    v_dados(v_dados.last()).vr_nrctremp := 5514904;
    v_dados(v_dados.last()).vr_vllanmto := 1.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 3795640;
    v_dados(v_dados.last()).vr_vllanmto := 1.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12504661;
    v_dados(v_dados.last()).vr_nrctremp := 5755420;
    v_dados(v_dados.last()).vr_vllanmto := 1.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13087525;
    v_dados(v_dados.last()).vr_nrctremp := 4248623;
    v_dados(v_dados.last()).vr_vllanmto := 1.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11576537;
    v_dados(v_dados.last()).vr_nrctremp := 5627369;
    v_dados(v_dados.last()).vr_vllanmto := 1.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2845555;
    v_dados(v_dados.last()).vr_nrctremp := 5651748;
    v_dados(v_dados.last()).vr_vllanmto := 1.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939431;
    v_dados(v_dados.last()).vr_vllanmto := 1.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3004031;
    v_dados(v_dados.last()).vr_nrctremp := 3990299;
    v_dados(v_dados.last()).vr_vllanmto := 1.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9578560;
    v_dados(v_dados.last()).vr_nrctremp := 5651697;
    v_dados(v_dados.last()).vr_vllanmto := 2.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 4832937;
    v_dados(v_dados.last()).vr_vllanmto := 2.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4488682;
    v_dados(v_dados.last()).vr_vllanmto := 2.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8979464;
    v_dados(v_dados.last()).vr_nrctremp := 5787503;
    v_dados(v_dados.last()).vr_vllanmto := 2.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605498;
    v_dados(v_dados.last()).vr_vllanmto := 2.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6721087;
    v_dados(v_dados.last()).vr_nrctremp := 3736688;
    v_dados(v_dados.last()).vr_vllanmto := 2.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2630133;
    v_dados(v_dados.last()).vr_nrctremp := 5645878;
    v_dados(v_dados.last()).vr_vllanmto := 3.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12550884;
    v_dados(v_dados.last()).vr_nrctremp := 4602465;
    v_dados(v_dados.last()).vr_vllanmto := 3.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11286024;
    v_dados(v_dados.last()).vr_nrctremp := 5397806;
    v_dados(v_dados.last()).vr_vllanmto := 3.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14534606;
    v_dados(v_dados.last()).vr_nrctremp := 5379655;
    v_dados(v_dados.last()).vr_vllanmto := 4.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12568457;
    v_dados(v_dados.last()).vr_nrctremp := 3774764;
    v_dados(v_dados.last()).vr_vllanmto := 4.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 3504420;
    v_dados(v_dados.last()).vr_vllanmto := 4.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7740611;
    v_dados(v_dados.last()).vr_nrctremp := 5505329;
    v_dados(v_dados.last()).vr_vllanmto := 4.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9808299;
    v_dados(v_dados.last()).vr_nrctremp := 5655362;
    v_dados(v_dados.last()).vr_vllanmto := 4.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13525760;
    v_dados(v_dados.last()).vr_nrctremp := 5457508;
    v_dados(v_dados.last()).vr_vllanmto := 4.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 5324288;
    v_dados(v_dados.last()).vr_vllanmto := 4.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12305804;
    v_dados(v_dados.last()).vr_nrctremp := 3656154;
    v_dados(v_dados.last()).vr_vllanmto := 4.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13653555;
    v_dados(v_dados.last()).vr_nrctremp := 4659308;
    v_dados(v_dados.last()).vr_vllanmto := 5.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8357854;
    v_dados(v_dados.last()).vr_nrctremp := 4636849;
    v_dados(v_dados.last()).vr_vllanmto := 5.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12311170;
    v_dados(v_dados.last()).vr_nrctremp := 3502234;
    v_dados(v_dados.last()).vr_vllanmto := 6.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12395234;
    v_dados(v_dados.last()).vr_nrctremp := 3607075;
    v_dados(v_dados.last()).vr_vllanmto := 6.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 3706648;
    v_dados(v_dados.last()).vr_vllanmto := 6.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7507674;
    v_dados(v_dados.last()).vr_nrctremp := 5431791;
    v_dados(v_dados.last()).vr_vllanmto := 6.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413341;
    v_dados(v_dados.last()).vr_nrctremp := 4488146;
    v_dados(v_dados.last()).vr_vllanmto := 6.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097708;
    v_dados(v_dados.last()).vr_vllanmto := 6.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9352562;
    v_dados(v_dados.last()).vr_nrctremp := 5027319;
    v_dados(v_dados.last()).vr_vllanmto := 7.48;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097729;
    v_dados(v_dados.last()).vr_vllanmto := 7.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12392820;
    v_dados(v_dados.last()).vr_nrctremp := 3586887;
    v_dados(v_dados.last()).vr_vllanmto := 7.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752916;
    v_dados(v_dados.last()).vr_nrctremp := 4073735;
    v_dados(v_dados.last()).vr_vllanmto := 7.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12926779;
    v_dados(v_dados.last()).vr_nrctremp := 4121872;
    v_dados(v_dados.last()).vr_vllanmto := 8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12455180;
    v_dados(v_dados.last()).vr_nrctremp := 3655624;
    v_dados(v_dados.last()).vr_vllanmto := 8.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14097605;
    v_dados(v_dados.last()).vr_nrctremp := 5248882;
    v_dados(v_dados.last()).vr_vllanmto := 8.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9779035;
    v_dados(v_dados.last()).vr_nrctremp := 5591989;
    v_dados(v_dados.last()).vr_vllanmto := 8.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 8.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80029990;
    v_dados(v_dados.last()).vr_nrctremp := 5354239;
    v_dados(v_dados.last()).vr_vllanmto := 8.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6496571;
    v_dados(v_dados.last()).vr_nrctremp := 5461206;
    v_dados(v_dados.last()).vr_vllanmto := 8.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 3742862;
    v_dados(v_dados.last()).vr_vllanmto := 8.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10400354;
    v_dados(v_dados.last()).vr_nrctremp := 5541382;
    v_dados(v_dados.last()).vr_vllanmto := 9.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11875283;
    v_dados(v_dados.last()).vr_nrctremp := 4276059;
    v_dados(v_dados.last()).vr_vllanmto := 9.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9084720;
    v_dados(v_dados.last()).vr_nrctremp := 5566176;
    v_dados(v_dados.last()).vr_vllanmto := 9.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5575486;
    v_dados(v_dados.last()).vr_vllanmto := 9.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12964077;
    v_dados(v_dados.last()).vr_nrctremp := 5318470;
    v_dados(v_dados.last()).vr_vllanmto := 9.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12027413;
    v_dados(v_dados.last()).vr_nrctremp := 3988033;
    v_dados(v_dados.last()).vr_vllanmto := 9.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7255195;
    v_dados(v_dados.last()).vr_nrctremp := 4609372;
    v_dados(v_dados.last()).vr_vllanmto := 10.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12364690;
    v_dados(v_dados.last()).vr_nrctremp := 3572209;
    v_dados(v_dados.last()).vr_vllanmto := 10.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10568689;
    v_dados(v_dados.last()).vr_nrctremp := 5546017;
    v_dados(v_dados.last()).vr_vllanmto := 10.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10950842;
    v_dados(v_dados.last()).vr_nrctremp := 5554395;
    v_dados(v_dados.last()).vr_vllanmto := 10.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035734;
    v_dados(v_dados.last()).vr_nrctremp := 3434461;
    v_dados(v_dados.last()).vr_vllanmto := 11.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11912138;
    v_dados(v_dados.last()).vr_nrctremp := 4598827;
    v_dados(v_dados.last()).vr_vllanmto := 11.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10636048;
    v_dados(v_dados.last()).vr_nrctremp := 4839172;
    v_dados(v_dados.last()).vr_vllanmto := 11.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9911251;
    v_dados(v_dados.last()).vr_nrctremp := 5432210;
    v_dados(v_dados.last()).vr_vllanmto := 11.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 5053220;
    v_dados(v_dados.last()).vr_vllanmto := 11.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8737940;
    v_dados(v_dados.last()).vr_nrctremp := 5375592;
    v_dados(v_dados.last()).vr_vllanmto := 12.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14976994;
    v_dados(v_dados.last()).vr_nrctremp := 5708888;
    v_dados(v_dados.last()).vr_vllanmto := 12.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595373;
    v_dados(v_dados.last()).vr_nrctremp := 4753507;
    v_dados(v_dados.last()).vr_vllanmto := 13.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4252218;
    v_dados(v_dados.last()).vr_vllanmto := 13.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11116617;
    v_dados(v_dados.last()).vr_nrctremp := 5413304;
    v_dados(v_dados.last()).vr_vllanmto := 13.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9889566;
    v_dados(v_dados.last()).vr_nrctremp := 5457696;
    v_dados(v_dados.last()).vr_vllanmto := 13.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12103721;
    v_dados(v_dados.last()).vr_nrctremp := 3289323;
    v_dados(v_dados.last()).vr_vllanmto := 14.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14169320;
    v_dados(v_dados.last()).vr_nrctremp := 5104679;
    v_dados(v_dados.last()).vr_vllanmto := 14.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10799850;
    v_dados(v_dados.last()).vr_nrctremp := 4312290;
    v_dados(v_dados.last()).vr_vllanmto := 14.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10355898;
    v_dados(v_dados.last()).vr_nrctremp := 4746635;
    v_dados(v_dados.last()).vr_vllanmto := 15.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8727880;
    v_dados(v_dados.last()).vr_nrctremp := 5373802;
    v_dados(v_dados.last()).vr_vllanmto := 15.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6389643;
    v_dados(v_dados.last()).vr_nrctremp := 4754021;
    v_dados(v_dados.last()).vr_vllanmto := 15.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12544515;
    v_dados(v_dados.last()).vr_nrctremp := 4376574;
    v_dados(v_dados.last()).vr_vllanmto := 15.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3430704;
    v_dados(v_dados.last()).vr_vllanmto := 15.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7448619;
    v_dados(v_dados.last()).vr_nrctremp := 4914399;
    v_dados(v_dados.last()).vr_vllanmto := 15.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11888784;
    v_dados(v_dados.last()).vr_nrctremp := 5311993;
    v_dados(v_dados.last()).vr_vllanmto := 15.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12620491;
    v_dados(v_dados.last()).vr_nrctremp := 3830907;
    v_dados(v_dados.last()).vr_vllanmto := 16.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10677542;
    v_dados(v_dados.last()).vr_nrctremp := 3986642;
    v_dados(v_dados.last()).vr_vllanmto := 16.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421230;
    v_dados(v_dados.last()).vr_vllanmto := 16.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10961887;
    v_dados(v_dados.last()).vr_nrctremp := 5622318;
    v_dados(v_dados.last()).vr_vllanmto := 16.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12830402;
    v_dados(v_dados.last()).vr_nrctremp := 5230840;
    v_dados(v_dados.last()).vr_vllanmto := 17.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11504978;
    v_dados(v_dados.last()).vr_nrctremp := 5249696;
    v_dados(v_dados.last()).vr_vllanmto := 17.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12141534;
    v_dados(v_dados.last()).vr_nrctremp := 5130609;
    v_dados(v_dados.last()).vr_vllanmto := 17.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12543004;
    v_dados(v_dados.last()).vr_nrctremp := 4182794;
    v_dados(v_dados.last()).vr_vllanmto := 18.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11191945;
    v_dados(v_dados.last()).vr_nrctremp := 4887457;
    v_dados(v_dados.last()).vr_vllanmto := 18.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658300;
    v_dados(v_dados.last()).vr_vllanmto := 19.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9415831;
    v_dados(v_dados.last()).vr_nrctremp := 5350901;
    v_dados(v_dados.last()).vr_vllanmto := 19.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12412902;
    v_dados(v_dados.last()).vr_nrctremp := 4244848;
    v_dados(v_dados.last()).vr_vllanmto := 19.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3637271;
    v_dados(v_dados.last()).vr_nrctremp := 4876229;
    v_dados(v_dados.last()).vr_vllanmto := 20.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11035528;
    v_dados(v_dados.last()).vr_nrctremp := 4901280;
    v_dados(v_dados.last()).vr_vllanmto := 20.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12361283;
    v_dados(v_dados.last()).vr_nrctremp := 4016461;
    v_dados(v_dados.last()).vr_vllanmto := 20.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7914857;
    v_dados(v_dados.last()).vr_nrctremp := 4673930;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8928029;
    v_dados(v_dados.last()).vr_nrctremp := 4702686;
    v_dados(v_dados.last()).vr_vllanmto := 20.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3990688;
    v_dados(v_dados.last()).vr_vllanmto := 20.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10251138;
    v_dados(v_dados.last()).vr_nrctremp := 5345929;
    v_dados(v_dados.last()).vr_vllanmto := 21.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11576537;
    v_dados(v_dados.last()).vr_nrctremp := 4674681;
    v_dados(v_dados.last()).vr_vllanmto := 21.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8176493;
    v_dados(v_dados.last()).vr_nrctremp := 3702027;
    v_dados(v_dados.last()).vr_vllanmto := 21.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12143200;
    v_dados(v_dados.last()).vr_nrctremp := 4857588;
    v_dados(v_dados.last()).vr_vllanmto := 21.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12540552;
    v_dados(v_dados.last()).vr_nrctremp := 3741052;
    v_dados(v_dados.last()).vr_vllanmto := 21.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12377066;
    v_dados(v_dados.last()).vr_nrctremp := 4751942;
    v_dados(v_dados.last()).vr_vllanmto := 22.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9676902;
    v_dados(v_dados.last()).vr_nrctremp := 4729697;
    v_dados(v_dados.last()).vr_vllanmto := 22.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4212320;
    v_dados(v_dados.last()).vr_vllanmto := 22.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9666869;
    v_dados(v_dados.last()).vr_nrctremp := 5196774;
    v_dados(v_dados.last()).vr_vllanmto := 22.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11468610;
    v_dados(v_dados.last()).vr_nrctremp := 4779849;
    v_dados(v_dados.last()).vr_vllanmto := 23.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065067;
    v_dados(v_dados.last()).vr_nrctremp := 5120902;
    v_dados(v_dados.last()).vr_vllanmto := 23.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 15091171;
    v_dados(v_dados.last()).vr_nrctremp := 5794346;
    v_dados(v_dados.last()).vr_vllanmto := 25.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10896384;
    v_dados(v_dados.last()).vr_nrctremp := 4357704;
    v_dados(v_dados.last()).vr_vllanmto := 25.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11725753;
    v_dados(v_dados.last()).vr_nrctremp := 5503501;
    v_dados(v_dados.last()).vr_vllanmto := 26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3167828;
    v_dados(v_dados.last()).vr_vllanmto := 26.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 26.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877832;
    v_dados(v_dados.last()).vr_vllanmto := 27.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12949353;
    v_dados(v_dados.last()).vr_nrctremp := 4148318;
    v_dados(v_dados.last()).vr_vllanmto := 27.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 29.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2183315;
    v_dados(v_dados.last()).vr_nrctremp := 3907302;
    v_dados(v_dados.last()).vr_vllanmto := 29.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 30.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4077008;
    v_dados(v_dados.last()).vr_nrctremp := 4746811;
    v_dados(v_dados.last()).vr_vllanmto := 30.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10491970;
    v_dados(v_dados.last()).vr_nrctremp := 4253223;
    v_dados(v_dados.last()).vr_vllanmto := 30.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 3726006;
    v_dados(v_dados.last()).vr_vllanmto := 31.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 3808261;
    v_dados(v_dados.last()).vr_vllanmto := 31.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11357096;
    v_dados(v_dados.last()).vr_nrctremp := 5247177;
    v_dados(v_dados.last()).vr_vllanmto := 31.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760102;
    v_dados(v_dados.last()).vr_nrctremp := 3965764;
    v_dados(v_dados.last()).vr_vllanmto := 32.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 33.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10077928;
    v_dados(v_dados.last()).vr_nrctremp := 5159124;
    v_dados(v_dados.last()).vr_vllanmto := 33.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 33.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7797320;
    v_dados(v_dados.last()).vr_nrctremp := 3869609;
    v_dados(v_dados.last()).vr_vllanmto := 34.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 34.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10846166;
    v_dados(v_dados.last()).vr_nrctremp := 2955845;
    v_dados(v_dados.last()).vr_vllanmto := 37.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8273332;
    v_dados(v_dados.last()).vr_nrctremp := 4648247;
    v_dados(v_dados.last()).vr_vllanmto := 34.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065903;
    v_dados(v_dados.last()).vr_nrctremp := 4529120;
    v_dados(v_dados.last()).vr_vllanmto := 36.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389404;
    v_dados(v_dados.last()).vr_nrctremp := 4250955;
    v_dados(v_dados.last()).vr_vllanmto := 36.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8753822;
    v_dados(v_dados.last()).vr_nrctremp := 4577604;
    v_dados(v_dados.last()).vr_vllanmto := 36.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9474021;
    v_dados(v_dados.last()).vr_nrctremp := 4661418;
    v_dados(v_dados.last()).vr_vllanmto := 37.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4270455;
    v_dados(v_dados.last()).vr_vllanmto := 38.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573117;
    v_dados(v_dados.last()).vr_vllanmto := 38.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7204612;
    v_dados(v_dados.last()).vr_nrctremp := 4750120;
    v_dados(v_dados.last()).vr_vllanmto := 38.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10866515;
    v_dados(v_dados.last()).vr_nrctremp := 4249800;
    v_dados(v_dados.last()).vr_vllanmto := 39.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 41.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80431135;
    v_dados(v_dados.last()).vr_nrctremp := 1901589;
    v_dados(v_dados.last()).vr_vllanmto := 42.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10640622;
    v_dados(v_dados.last()).vr_nrctremp := 4784340;
    v_dados(v_dados.last()).vr_vllanmto := 43.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682368;
    v_dados(v_dados.last()).vr_nrctremp := 4987449;
    v_dados(v_dados.last()).vr_vllanmto := 44.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9274456;
    v_dados(v_dados.last()).vr_nrctremp := 4881776;
    v_dados(v_dados.last()).vr_vllanmto := 44.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10443576;
    v_dados(v_dados.last()).vr_nrctremp := 4660368;
    v_dados(v_dados.last()).vr_vllanmto := 44.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820408;
    v_dados(v_dados.last()).vr_nrctremp := 3838282;
    v_dados(v_dados.last()).vr_vllanmto := 44.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10223495;
    v_dados(v_dados.last()).vr_nrctremp := 5061087;
    v_dados(v_dados.last()).vr_vllanmto := 44.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12651443;
    v_dados(v_dados.last()).vr_nrctremp := 4950509;
    v_dados(v_dados.last()).vr_vllanmto := 45.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11834021;
    v_dados(v_dados.last()).vr_nrctremp := 4407237;
    v_dados(v_dados.last()).vr_vllanmto := 46.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11044039;
    v_dados(v_dados.last()).vr_nrctremp := 4344288;
    v_dados(v_dados.last()).vr_vllanmto := 46.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12594750;
    v_dados(v_dados.last()).vr_nrctremp := 3807129;
    v_dados(v_dados.last()).vr_vllanmto := 47.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10637753;
    v_dados(v_dados.last()).vr_nrctremp := 4453483;
    v_dados(v_dados.last()).vr_vllanmto := 47.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11908637;
    v_dados(v_dados.last()).vr_nrctremp := 4650401;
    v_dados(v_dados.last()).vr_vllanmto := 48.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13523252;
    v_dados(v_dados.last()).vr_nrctremp := 4564654;
    v_dados(v_dados.last()).vr_vllanmto := 48.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12068977;
    v_dados(v_dados.last()).vr_nrctremp := 3271903;
    v_dados(v_dados.last()).vr_vllanmto := 48.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7374763;
    v_dados(v_dados.last()).vr_nrctremp := 4178604;
    v_dados(v_dados.last()).vr_vllanmto := 49.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12349909;
    v_dados(v_dados.last()).vr_nrctremp := 3549289;
    v_dados(v_dados.last()).vr_vllanmto := 50.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6788432;
    v_dados(v_dados.last()).vr_nrctremp := 4440698;
    v_dados(v_dados.last()).vr_vllanmto := 53.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10092366;
    v_dados(v_dados.last()).vr_nrctremp := 4521572;
    v_dados(v_dados.last()).vr_vllanmto := 53.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10671110;
    v_dados(v_dados.last()).vr_nrctremp := 2956018;
    v_dados(v_dados.last()).vr_vllanmto := 61.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8707642;
    v_dados(v_dados.last()).vr_nrctremp := 3430425;
    v_dados(v_dados.last()).vr_vllanmto := 56.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8176493;
    v_dados(v_dados.last()).vr_nrctremp := 3618471;
    v_dados(v_dados.last()).vr_vllanmto := 57.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6365639;
    v_dados(v_dados.last()).vr_nrctremp := 4185048;
    v_dados(v_dados.last()).vr_vllanmto := 58.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8822905;
    v_dados(v_dados.last()).vr_nrctremp := 4746205;
    v_dados(v_dados.last()).vr_vllanmto := 59.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12450316;
    v_dados(v_dados.last()).vr_nrctremp := 3647430;
    v_dados(v_dados.last()).vr_vllanmto := 59.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80012248;
    v_dados(v_dados.last()).vr_nrctremp := 4068844;
    v_dados(v_dados.last()).vr_vllanmto := 59.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8904375;
    v_dados(v_dados.last()).vr_nrctremp := 4874504;
    v_dados(v_dados.last()).vr_vllanmto := 59.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8276412;
    v_dados(v_dados.last()).vr_nrctremp := 2956155;
    v_dados(v_dados.last()).vr_vllanmto := 60.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9683097;
    v_dados(v_dados.last()).vr_nrctremp := 2955793;
    v_dados(v_dados.last()).vr_vllanmto := 60.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10919597;
    v_dados(v_dados.last()).vr_nrctremp := 4141182;
    v_dados(v_dados.last()).vr_vllanmto := 61.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12333263;
    v_dados(v_dados.last()).vr_nrctremp := 5350282;
    v_dados(v_dados.last()).vr_vllanmto := 61.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14074320;
    v_dados(v_dados.last()).vr_nrctremp := 5086593;
    v_dados(v_dados.last()).vr_vllanmto := 63.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 64.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8713529;
    v_dados(v_dados.last()).vr_nrctremp := 2661058;
    v_dados(v_dados.last()).vr_vllanmto := 64.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80145345;
    v_dados(v_dados.last()).vr_nrctremp := 2955719;
    v_dados(v_dados.last()).vr_vllanmto := 66.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8177589;
    v_dados(v_dados.last()).vr_nrctremp := 3837514;
    v_dados(v_dados.last()).vr_vllanmto := 67.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 70.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683352;
    v_dados(v_dados.last()).vr_nrctremp := 4624468;
    v_dados(v_dados.last()).vr_vllanmto := 76.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7668058;
    v_dados(v_dados.last()).vr_nrctremp := 4183670;
    v_dados(v_dados.last()).vr_vllanmto := 76.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741741;
    v_dados(v_dados.last()).vr_nrctremp := 4570333;
    v_dados(v_dados.last()).vr_vllanmto := 77.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11207574;
    v_dados(v_dados.last()).vr_nrctremp := 2639416;
    v_dados(v_dados.last()).vr_vllanmto := 107.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9659293;
    v_dados(v_dados.last()).vr_nrctremp := 2955761;
    v_dados(v_dados.last()).vr_vllanmto := 81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10889833;
    v_dados(v_dados.last()).vr_nrctremp := 4581853;
    v_dados(v_dados.last()).vr_vllanmto := 91.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80277829;
    v_dados(v_dados.last()).vr_nrctremp := 3087767;
    v_dados(v_dados.last()).vr_vllanmto := 91.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11057300;
    v_dados(v_dados.last()).vr_nrctremp := 3653854;
    v_dados(v_dados.last()).vr_vllanmto := 91.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10403655;
    v_dados(v_dados.last()).vr_nrctremp := 2955266;
    v_dados(v_dados.last()).vr_vllanmto := 96.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533640;
    v_dados(v_dados.last()).vr_nrctremp := 3927171;
    v_dados(v_dados.last()).vr_vllanmto := 97.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10571760;
    v_dados(v_dados.last()).vr_nrctremp := 4167462;
    v_dados(v_dados.last()).vr_vllanmto := 97.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9547479;
    v_dados(v_dados.last()).vr_nrctremp := 2155460;
    v_dados(v_dados.last()).vr_vllanmto := 1190.20;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 98.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12763802;
    v_dados(v_dados.last()).vr_nrctremp := 4022781;
    v_dados(v_dados.last()).vr_vllanmto := 102.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12656992;
    v_dados(v_dados.last()).vr_nrctremp := 4813530;
    v_dados(v_dados.last()).vr_vllanmto := 97.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9355146;
    v_dados(v_dados.last()).vr_nrctremp := 2728862;
    v_dados(v_dados.last()).vr_vllanmto := 106.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10831150;
    v_dados(v_dados.last()).vr_nrctremp := 4571633;
    v_dados(v_dados.last()).vr_vllanmto := 108.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 112.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10140425;
    v_dados(v_dados.last()).vr_nrctremp := 3852530;
    v_dados(v_dados.last()).vr_vllanmto := 112.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10800824;
    v_dados(v_dados.last()).vr_nrctremp := 3684745;
    v_dados(v_dados.last()).vr_vllanmto := 112.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7521537;
    v_dados(v_dados.last()).vr_nrctremp := 2955842;
    v_dados(v_dados.last()).vr_vllanmto := 116.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 116.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 118.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3026450;
    v_dados(v_dados.last()).vr_nrctremp := 4642781;
    v_dados(v_dados.last()).vr_vllanmto := 121.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12561762;
    v_dados(v_dados.last()).vr_nrctremp := 4109959;
    v_dados(v_dados.last()).vr_vllanmto := 125.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80346790;
    v_dados(v_dados.last()).vr_nrctremp := 2502227;
    v_dados(v_dados.last()).vr_vllanmto := 126.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12504998;
    v_dados(v_dados.last()).vr_nrctremp := 4229059;
    v_dados(v_dados.last()).vr_vllanmto := 127.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8289077;
    v_dados(v_dados.last()).vr_nrctremp := 3293193;
    v_dados(v_dados.last()).vr_vllanmto := 127.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8171645;
    v_dados(v_dados.last()).vr_nrctremp := 4644755;
    v_dados(v_dados.last()).vr_vllanmto := 147.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 151.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8496293;
    v_dados(v_dados.last()).vr_nrctremp := 4694140;
    v_dados(v_dados.last()).vr_vllanmto := 152.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 156.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 167.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 174.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11766522;
    v_dados(v_dados.last()).vr_nrctremp := 2988271;
    v_dados(v_dados.last()).vr_vllanmto := 175.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10179569;
    v_dados(v_dados.last()).vr_nrctremp := 2967816;
    v_dados(v_dados.last()).vr_vllanmto := 184.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10360581;
    v_dados(v_dados.last()).vr_nrctremp := 4521812;
    v_dados(v_dados.last()).vr_vllanmto := 194.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093159;
    v_dados(v_dados.last()).vr_nrctremp := 1886421;
    v_dados(v_dados.last()).vr_vllanmto := 215.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10254358;
    v_dados(v_dados.last()).vr_nrctremp := 5534494;
    v_dados(v_dados.last()).vr_vllanmto := 260.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80115241;
    v_dados(v_dados.last()).vr_nrctremp := 4978930;
    v_dados(v_dados.last()).vr_vllanmto := 266.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3790622;
    v_dados(v_dados.last()).vr_nrctremp := 4307968;
    v_dados(v_dados.last()).vr_vllanmto := 304.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6880924;
    v_dados(v_dados.last()).vr_nrctremp := 3313425;
    v_dados(v_dados.last()).vr_vllanmto := 344.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6935915;
    v_dados(v_dados.last()).vr_nrctremp := 2991942;
    v_dados(v_dados.last()).vr_vllanmto := 561.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12763802;
    v_dados(v_dados.last()).vr_nrctremp := 3968735;
    v_dados(v_dados.last()).vr_vllanmto := 693.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10846166;
    v_dados(v_dados.last()).vr_nrctremp := 2955881;
    v_dados(v_dados.last()).vr_vllanmto := 855.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8462461;
    v_dados(v_dados.last()).vr_nrctremp := 3041554;
    v_dados(v_dados.last()).vr_vllanmto := 867.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10265651;
    v_dados(v_dados.last()).vr_nrctremp := 4717159;
    v_dados(v_dados.last()).vr_vllanmto := 1741.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11568828;
    v_dados(v_dados.last()).vr_nrctremp := 5538023;
    v_dados(v_dados.last()).vr_vllanmto := 2505.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3150054;
    v_dados(v_dados.last()).vr_nrctremp := 3855698;
    v_dados(v_dados.last()).vr_vllanmto := 2794.87;
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
