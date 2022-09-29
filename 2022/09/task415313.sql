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
    v_dados(v_dados.last()).vr_nrdconta := 194034;
    v_dados(v_dados.last()).vr_nrctremp := 63823;
    v_dados(v_dados.last()).vr_vllanmto := 46.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 206750;
    v_dados(v_dados.last()).vr_nrctremp := 57881;
    v_dados(v_dados.last()).vr_vllanmto := 18.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 235032;
    v_dados(v_dados.last()).vr_nrctremp := 64074;
    v_dados(v_dados.last()).vr_vllanmto := 45.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 297283;
    v_dados(v_dados.last()).vr_nrctremp := 54417;
    v_dados(v_dados.last()).vr_vllanmto := 13.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 339199;
    v_dados(v_dados.last()).vr_nrctremp := 52014;
    v_dados(v_dados.last()).vr_vllanmto := 124.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 354180;
    v_dados(v_dados.last()).vr_nrctremp := 69436;
    v_dados(v_dados.last()).vr_vllanmto := 1712.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 387606;
    v_dados(v_dados.last()).vr_nrctremp := 51788;
    v_dados(v_dados.last()).vr_vllanmto := 124.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 397083;
    v_dados(v_dados.last()).vr_nrctremp := 51918;
    v_dados(v_dados.last()).vr_vllanmto := 124.28;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 402206;
    v_dados(v_dados.last()).vr_nrctremp := 53507;
    v_dados(v_dados.last()).vr_vllanmto := 157.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 403903;
    v_dados(v_dados.last()).vr_nrctremp := 55860;
    v_dados(v_dados.last()).vr_vllanmto := 131.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 404136;
    v_dados(v_dados.last()).vr_nrctremp := 58419;
    v_dados(v_dados.last()).vr_vllanmto := 87.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 423912;
    v_dados(v_dados.last()).vr_nrctremp := 56496;
    v_dados(v_dados.last()).vr_vllanmto := 70.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 447722;
    v_dados(v_dados.last()).vr_nrctremp := 69018;
    v_dados(v_dados.last()).vr_vllanmto := 2802.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 500917;
    v_dados(v_dados.last()).vr_nrctremp := 20300019;
    v_dados(v_dados.last()).vr_vllanmto := 78.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501948;
    v_dados(v_dados.last()).vr_nrctremp := 21100009;
    v_dados(v_dados.last()).vr_vllanmto := 68.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 501999;
    v_dados(v_dados.last()).vr_nrctremp := 20100370;
    v_dados(v_dados.last()).vr_vllanmto := 18.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 502987;
    v_dados(v_dados.last()).vr_nrctremp := 20100614;
    v_dados(v_dados.last()).vr_vllanmto := 16.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503126;
    v_dados(v_dados.last()).vr_nrctremp := 21200019;
    v_dados(v_dados.last()).vr_vllanmto := 65.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 503665;
    v_dados(v_dados.last()).vr_nrctremp := 21100124;
    v_dados(v_dados.last()).vr_vllanmto := 36.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504297;
    v_dados(v_dados.last()).vr_nrctremp := 21100102;
    v_dados(v_dados.last()).vr_vllanmto := 27.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504327;
    v_dados(v_dados.last()).vr_nrctremp := 21100187;
    v_dados(v_dados.last()).vr_vllanmto := 14.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504556;
    v_dados(v_dados.last()).vr_nrctremp := 20200022;
    v_dados(v_dados.last()).vr_vllanmto := 96.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504726;
    v_dados(v_dados.last()).vr_nrctremp := 21100038;
    v_dados(v_dados.last()).vr_vllanmto := 25.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 504769;
    v_dados(v_dados.last()).vr_nrctremp := 20100374;
    v_dados(v_dados.last()).vr_vllanmto := 14.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506133;
    v_dados(v_dados.last()).vr_nrctremp := 21300028;
    v_dados(v_dados.last()).vr_vllanmto := 44.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 506613;
    v_dados(v_dados.last()).vr_nrctremp := 21300039;
    v_dados(v_dados.last()).vr_vllanmto := 73.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 511358;
    v_dados(v_dados.last()).vr_nrctremp := 20100239;
    v_dados(v_dados.last()).vr_vllanmto := 29.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514500;
    v_dados(v_dados.last()).vr_nrctremp := 20100648;
    v_dados(v_dados.last()).vr_vllanmto := 35.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 514640;
    v_dados(v_dados.last()).vr_nrctremp := 20100508;
    v_dados(v_dados.last()).vr_vllanmto := 27.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 517194;
    v_dados(v_dados.last()).vr_nrctremp := 20200024;
    v_dados(v_dados.last()).vr_vllanmto := 5.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 518425;
    v_dados(v_dados.last()).vr_nrctremp := 21100046;
    v_dados(v_dados.last()).vr_vllanmto := 19.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 519650;
    v_dados(v_dados.last()).vr_nrctremp := 20100538;
    v_dados(v_dados.last()).vr_vllanmto := 40.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522023;
    v_dados(v_dados.last()).vr_nrctremp := 21100140;
    v_dados(v_dados.last()).vr_vllanmto := 16.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 522830;
    v_dados(v_dados.last()).vr_nrctremp := 21100047;
    v_dados(v_dados.last()).vr_vllanmto := 22.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525014;
    v_dados(v_dados.last()).vr_nrctremp := 21100133;
    v_dados(v_dados.last()).vr_vllanmto := 27.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 525774;
    v_dados(v_dados.last()).vr_nrctremp := 20100533;
    v_dados(v_dados.last()).vr_vllanmto := 12.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 526096;
    v_dados(v_dados.last()).vr_nrctremp := 21100115;
    v_dados(v_dados.last()).vr_vllanmto := 92.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 527610;
    v_dados(v_dados.last()).vr_nrctremp := 21100135;
    v_dados(v_dados.last()).vr_vllanmto := 21.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 528889;
    v_dados(v_dados.last()).vr_nrctremp := 21100057;
    v_dados(v_dados.last()).vr_vllanmto := 19.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 529958;
    v_dados(v_dados.last()).vr_nrctremp := 21100163;
    v_dados(v_dados.last()).vr_vllanmto := 18.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 530689;
    v_dados(v_dados.last()).vr_nrctremp := 21100201;
    v_dados(v_dados.last()).vr_vllanmto := 34.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 532177;
    v_dados(v_dados.last()).vr_nrctremp := 21200016;
    v_dados(v_dados.last()).vr_vllanmto := 258.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 533530;
    v_dados(v_dados.last()).vr_nrctremp := 21300015;
    v_dados(v_dados.last()).vr_vllanmto := 12.16;
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
