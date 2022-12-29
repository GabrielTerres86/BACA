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
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 858200;
    v_dados(v_dados.last()).vr_nrctremp := 269473;
    v_dados(v_dados.last()).vr_vllanmto := 62.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 860905;
    v_dados(v_dados.last()).vr_nrctremp := 270236;
    v_dados(v_dados.last()).vr_vllanmto := 312.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 866547;
    v_dados(v_dados.last()).vr_nrctremp := 271760;
    v_dados(v_dados.last()).vr_vllanmto := 139.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 884367;
    v_dados(v_dados.last()).vr_nrctremp := 276947;
    v_dados(v_dados.last()).vr_vllanmto := 170.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 891134;
    v_dados(v_dados.last()).vr_nrctremp := 277529;
    v_dados(v_dados.last()).vr_vllanmto := 187.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 890499;
    v_dados(v_dados.last()).vr_nrctremp := 279292;
    v_dados(v_dados.last()).vr_vllanmto := 132.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 914711;
    v_dados(v_dados.last()).vr_nrctremp := 283184;
    v_dados(v_dados.last()).vr_vllanmto := 130.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 932167;
    v_dados(v_dados.last()).vr_nrctremp := 289034;
    v_dados(v_dados.last()).vr_vllanmto := 248.97;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 858072;
    v_dados(v_dados.last()).vr_nrctremp := 299588;
    v_dados(v_dados.last()).vr_vllanmto := 84.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 788066;
    v_dados(v_dados.last()).vr_nrctremp := 301304;
    v_dados(v_dados.last()).vr_vllanmto := 151.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 770876;
    v_dados(v_dados.last()).vr_nrctremp := 303009;
    v_dados(v_dados.last()).vr_vllanmto := 76.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 622435;
    v_dados(v_dados.last()).vr_nrctremp := 304265;
    v_dados(v_dados.last()).vr_vllanmto := 97.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 879819;
    v_dados(v_dados.last()).vr_nrctremp := 306534;
    v_dados(v_dados.last()).vr_vllanmto := 82.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 987905;
    v_dados(v_dados.last()).vr_nrctremp := 311566;
    v_dados(v_dados.last()).vr_vllanmto := 1519.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 760030;
    v_dados(v_dados.last()).vr_nrctremp := 312388;
    v_dados(v_dados.last()).vr_vllanmto := 35.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1019570;
    v_dados(v_dados.last()).vr_nrctremp := 315729;
    v_dados(v_dados.last()).vr_vllanmto := 78.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 831581;
    v_dados(v_dados.last()).vr_nrctremp := 320894;
    v_dados(v_dados.last()).vr_vllanmto := 69.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 936057;
    v_dados(v_dados.last()).vr_nrctremp := 322439;
    v_dados(v_dados.last()).vr_vllanmto := 50.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 923770;
    v_dados(v_dados.last()).vr_nrctremp := 325369;
    v_dados(v_dados.last()).vr_vllanmto := 54.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 588610;
    v_dados(v_dados.last()).vr_nrctremp := 325682;
    v_dados(v_dados.last()).vr_vllanmto := 38.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 368148;
    v_dados(v_dados.last()).vr_nrctremp := 326262;
    v_dados(v_dados.last()).vr_vllanmto := 74.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 966835;
    v_dados(v_dados.last()).vr_nrctremp := 328953;
    v_dados(v_dados.last()).vr_vllanmto := 28.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 958883;
    v_dados(v_dados.last()).vr_nrctremp := 329872;
    v_dados(v_dados.last()).vr_vllanmto := 87.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 887382;
    v_dados(v_dados.last()).vr_nrctremp := 334227;
    v_dados(v_dados.last()).vr_vllanmto := 48.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1079115;
    v_dados(v_dados.last()).vr_nrctremp := 335834;
    v_dados(v_dados.last()).vr_vllanmto := 26.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1094157;
    v_dados(v_dados.last()).vr_nrctremp := 341025;
    v_dados(v_dados.last()).vr_vllanmto := 18.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 927210;
    v_dados(v_dados.last()).vr_nrctremp := 342655;
    v_dados(v_dados.last()).vr_vllanmto := 120.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 608475;
    v_dados(v_dados.last()).vr_nrctremp := 353441;
    v_dados(v_dados.last()).vr_vllanmto := 146.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1125664;
    v_dados(v_dados.last()).vr_nrctremp := 354805;
    v_dados(v_dados.last()).vr_vllanmto := 157.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1130781;
    v_dados(v_dados.last()).vr_nrctremp := 356325;
    v_dados(v_dados.last()).vr_vllanmto := 50.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1136470;
    v_dados(v_dados.last()).vr_nrctremp := 358638;
    v_dados(v_dados.last()).vr_vllanmto := 43.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 585068;
    v_dados(v_dados.last()).vr_nrctremp := 359290;
    v_dados(v_dados.last()).vr_vllanmto := 84.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14466244;
    v_dados(v_dados.last()).vr_nrctremp := 363449;
    v_dados(v_dados.last()).vr_vllanmto := 19.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14466953;
    v_dados(v_dados.last()).vr_nrctremp := 364021;
    v_dados(v_dados.last()).vr_vllanmto := 17.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 976075;
    v_dados(v_dados.last()).vr_nrctremp := 365323;
    v_dados(v_dados.last()).vr_vllanmto := 26.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 419052;
    v_dados(v_dados.last()).vr_nrctremp := 366778;
    v_dados(v_dados.last()).vr_vllanmto := 21.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1144782;
    v_dados(v_dados.last()).vr_nrctremp := 366812;
    v_dados(v_dados.last()).vr_vllanmto := 40.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 967416;
    v_dados(v_dados.last()).vr_nrctremp := 366847;
    v_dados(v_dados.last()).vr_vllanmto := 18.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 978442;
    v_dados(v_dados.last()).vr_nrctremp := 367150;
    v_dados(v_dados.last()).vr_vllanmto := 21.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 933856;
    v_dados(v_dados.last()).vr_nrctremp := 370700;
    v_dados(v_dados.last()).vr_vllanmto := 15.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 913227;
    v_dados(v_dados.last()).vr_nrctremp := 370804;
    v_dados(v_dados.last()).vr_vllanmto := 16.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14646846;
    v_dados(v_dados.last()).vr_nrctremp := 371966;
    v_dados(v_dados.last()).vr_vllanmto := 28.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 870110;
    v_dados(v_dados.last()).vr_nrctremp := 373409;
    v_dados(v_dados.last()).vr_vllanmto := 118.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 601470;
    v_dados(v_dados.last()).vr_nrctremp := 376735;
    v_dados(v_dados.last()).vr_vllanmto := 46.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14762226;
    v_dados(v_dados.last()).vr_nrctremp := 376972;
    v_dados(v_dados.last()).vr_vllanmto := 21.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1080946;
    v_dados(v_dados.last()).vr_nrctremp := 377942;
    v_dados(v_dados.last()).vr_vllanmto := 28.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 575046;
    v_dados(v_dados.last()).vr_nrctremp := 383395;
    v_dados(v_dados.last()).vr_vllanmto := 63.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 583766;
    v_dados(v_dados.last()).vr_nrctremp := 385867;
    v_dados(v_dados.last()).vr_vllanmto := 40.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 931195;
    v_dados(v_dados.last()).vr_nrctremp := 394750;
    v_dados(v_dados.last()).vr_vllanmto := 17.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1026089;
    v_dados(v_dados.last()).vr_nrctremp := 399005;
    v_dados(v_dados.last()).vr_vllanmto := 43.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 663255;
    v_dados(v_dados.last()).vr_nrctremp := 399040;
    v_dados(v_dados.last()).vr_vllanmto := 5.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1165046;
    v_dados(v_dados.last()).vr_nrctremp := 400449;
    v_dados(v_dados.last()).vr_vllanmto := 15.88;
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
