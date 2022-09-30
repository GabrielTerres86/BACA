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
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505897;
    v_dados(v_dados.last()).vr_nrctremp := 21300019;
    v_dados(v_dados.last()).vr_vllanmto := 267.65;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504769;
    v_dados(v_dados.last()).vr_nrctremp := 20100374;
    v_dados(v_dados.last()).vr_vllanmto := 14.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500917;
    v_dados(v_dados.last()).vr_nrctremp := 20300019;
    v_dados(v_dados.last()).vr_vllanmto := 573.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504327;
    v_dados(v_dados.last()).vr_nrctremp := 21100187;
    v_dados(v_dados.last()).vr_vllanmto := 14.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525715;
    v_dados(v_dados.last()).vr_nrctremp := 20100428;
    v_dados(v_dados.last()).vr_vllanmto := 21.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 403903;
    v_dados(v_dados.last()).vr_nrctremp := 55860;
    v_dados(v_dados.last()).vr_vllanmto := 140.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 423912;
    v_dados(v_dados.last()).vr_nrctremp := 56496;
    v_dados(v_dados.last()).vr_vllanmto := 114.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502987;
    v_dados(v_dados.last()).vr_nrctremp := 20100614;
    v_dados(v_dados.last()).vr_vllanmto := 22.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514640;
    v_dados(v_dados.last()).vr_nrctremp := 20100508;
    v_dados(v_dados.last()).vr_vllanmto := 347.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525774;
    v_dados(v_dados.last()).vr_nrctremp := 20100533;
    v_dados(v_dados.last()).vr_vllanmto := 15.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 531537;
    v_dados(v_dados.last()).vr_nrctremp := 21100144;
    v_dados(v_dados.last()).vr_vllanmto := 4.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 192392;
    v_dados(v_dados.last()).vr_nrctremp := 70223;
    v_dados(v_dados.last()).vr_vllanmto := 14.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 15101924;
    v_dados(v_dados.last()).vr_nrctremp := 69736;
    v_dados(v_dados.last()).vr_vllanmto := 20.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518166;
    v_dados(v_dados.last()).vr_nrctremp := 21100279;
    v_dados(v_dados.last()).vr_vllanmto := 28.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518425;
    v_dados(v_dados.last()).vr_nrctremp := 21100046;
    v_dados(v_dados.last()).vr_vllanmto := 57.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525014;
    v_dados(v_dados.last()).vr_nrctremp := 21100133;
    v_dados(v_dados.last()).vr_vllanmto := 9.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 235032;
    v_dados(v_dados.last()).vr_nrctremp := 64074;
    v_dados(v_dados.last()).vr_vllanmto := 33.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532177;
    v_dados(v_dados.last()).vr_nrctremp := 21200016;
    v_dados(v_dados.last()).vr_vllanmto := 38.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503665;
    v_dados(v_dados.last()).vr_nrctremp := 21100124;
    v_dados(v_dados.last()).vr_vllanmto := 97.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 505358;
    v_dados(v_dados.last()).vr_nrctremp := 21300027;
    v_dados(v_dados.last()).vr_vllanmto := 24.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502995;
    v_dados(v_dados.last()).vr_nrctremp := 20100622;
    v_dados(v_dados.last()).vr_vllanmto := 41.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530689;
    v_dados(v_dados.last()).vr_nrctremp := 21100201;
    v_dados(v_dados.last()).vr_vllanmto := 47.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 526096;
    v_dados(v_dados.last()).vr_nrctremp := 21100115;
    v_dados(v_dados.last()).vr_vllanmto := 38.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501646;
    v_dados(v_dados.last()).vr_nrctremp := 20100441;
    v_dados(v_dados.last()).vr_vllanmto := 3.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 515639;
    v_dados(v_dados.last()).vr_nrctremp := 21100207;
    v_dados(v_dados.last()).vr_vllanmto := 142.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503207;
    v_dados(v_dados.last()).vr_nrctremp := 20300044;
    v_dados(v_dados.last()).vr_vllanmto := 696.3;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503126;
    v_dados(v_dados.last()).vr_nrctremp := 21200019;
    v_dados(v_dados.last()).vr_vllanmto := 213.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514500;
    v_dados(v_dados.last()).vr_nrctremp := 20100648;
    v_dados(v_dados.last()).vr_vllanmto := 15.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 404136;
    v_dados(v_dados.last()).vr_nrctremp := 58419;
    v_dados(v_dados.last()).vr_vllanmto := 2.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530786;
    v_dados(v_dados.last()).vr_nrctremp := 20100634;
    v_dados(v_dados.last()).vr_vllanmto := 35.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 475785;
    v_dados(v_dados.last()).vr_nrctremp := 66151;
    v_dados(v_dados.last()).vr_vllanmto := 2.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530042;
    v_dados(v_dados.last()).vr_nrctremp := 20100507;
    v_dados(v_dados.last()).vr_vllanmto := 66.91;
    v_dados(v_dados.last()).vr_cdhistor := 1041;



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
