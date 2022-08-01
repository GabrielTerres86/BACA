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
  v_dados(v_dados.last()).vr_nrdconta := 839132;
  v_dados(v_dados.last()).vr_nrctremp := 265217;
  v_dados(v_dados.last()).vr_vllanmto := 275.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 580830;
  v_dados(v_dados.last()).vr_nrctremp := 265383;
  v_dados(v_dados.last()).vr_vllanmto := 125.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 844780;
  v_dados(v_dados.last()).vr_nrctremp := 266343;
  v_dados(v_dados.last()).vr_vllanmto := 116.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 858200;
  v_dados(v_dados.last()).vr_nrctremp := 269473;
  v_dados(v_dados.last()).vr_vllanmto := 85.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 866547;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 88.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 844730;
  v_dados(v_dados.last()).vr_nrctremp := 272518;
  v_dados(v_dados.last()).vr_vllanmto := 65.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 781126;
  v_dados(v_dados.last()).vr_nrctremp := 273012;
  v_dados(v_dados.last()).vr_vllanmto := 89.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 870447;
  v_dados(v_dados.last()).vr_nrctremp := 273372;
  v_dados(v_dados.last()).vr_vllanmto := 119.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 884367;
  v_dados(v_dados.last()).vr_nrctremp := 276947;
  v_dados(v_dados.last()).vr_vllanmto := 67.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 891134;
  v_dados(v_dados.last()).vr_nrctremp := 277529;
  v_dados(v_dados.last()).vr_vllanmto := 102.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 848050;
  v_dados(v_dados.last()).vr_nrctremp := 278327;
  v_dados(v_dados.last()).vr_vllanmto := 66.36;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 890499;
  v_dados(v_dados.last()).vr_nrctremp := 279292;
  v_dados(v_dados.last()).vr_vllanmto := 50.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 909165;
  v_dados(v_dados.last()).vr_nrctremp := 281596;
  v_dados(v_dados.last()).vr_vllanmto := 52.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 961116;
  v_dados(v_dados.last()).vr_nrctremp := 297576;
  v_dados(v_dados.last()).vr_vllanmto := 77.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 832510;
  v_dados(v_dados.last()).vr_nrctremp := 301017;
  v_dados(v_dados.last()).vr_vllanmto := 23.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 880019;
  v_dados(v_dados.last()).vr_nrctremp := 302476;
  v_dados(v_dados.last()).vr_vllanmto := 31.47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 770876;
  v_dados(v_dados.last()).vr_nrctremp := 303009;
  v_dados(v_dados.last()).vr_vllanmto := 25.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 741000;
  v_dados(v_dados.last()).vr_nrctremp := 304587;
  v_dados(v_dados.last()).vr_vllanmto := 39.15;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 879819;
  v_dados(v_dados.last()).vr_nrctremp := 306534;
  v_dados(v_dados.last()).vr_vllanmto := 20.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 989231;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 86.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 835358;
  v_dados(v_dados.last()).vr_nrctremp := 313093;
  v_dados(v_dados.last()).vr_vllanmto := 41.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575186;
  v_dados(v_dados.last()).vr_nrctremp := 314780;
  v_dados(v_dados.last()).vr_vllanmto := 45.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 763497;
  v_dados(v_dados.last()).vr_nrctremp := 320569;
  v_dados(v_dados.last()).vr_vllanmto := 160.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1035673;
  v_dados(v_dados.last()).vr_nrctremp := 320862;
  v_dados(v_dados.last()).vr_vllanmto := 31.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 615455;
  v_dados(v_dados.last()).vr_nrctremp := 321708;
  v_dados(v_dados.last()).vr_vllanmto := 738.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 930938;
  v_dados(v_dados.last()).vr_nrctremp := 322349;
  v_dados(v_dados.last()).vr_vllanmto := 68.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 936057;
  v_dados(v_dados.last()).vr_nrctremp := 322439;
  v_dados(v_dados.last()).vr_vllanmto := 32.03;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1031481;
  v_dados(v_dados.last()).vr_nrctremp := 323479;
  v_dados(v_dados.last()).vr_vllanmto := 21.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 923770;
  v_dados(v_dados.last()).vr_nrctremp := 325369;
  v_dados(v_dados.last()).vr_vllanmto := 27.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 368148;
  v_dados(v_dados.last()).vr_nrctremp := 326262;
  v_dados(v_dados.last()).vr_vllanmto := 36.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1056530;
  v_dados(v_dados.last()).vr_nrctremp := 327276;
  v_dados(v_dados.last()).vr_vllanmto := 2429.07;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 966835;
  v_dados(v_dados.last()).vr_nrctremp := 328953;
  v_dados(v_dados.last()).vr_vllanmto := 33.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 855260;
  v_dados(v_dados.last()).vr_nrctremp := 332189;
  v_dados(v_dados.last()).vr_vllanmto := 90.01;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1069217;
  v_dados(v_dados.last()).vr_nrctremp := 338555;
  v_dados(v_dados.last()).vr_vllanmto := 102.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 928712;
  v_dados(v_dados.last()).vr_nrctremp := 340453;
  v_dados(v_dados.last()).vr_vllanmto := 230.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1119605;
  v_dados(v_dados.last()).vr_nrctremp := 352146;
  v_dados(v_dados.last()).vr_vllanmto := 170.82;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 697370;
  v_dados(v_dados.last()).vr_nrctremp := 352338;
  v_dados(v_dados.last()).vr_vllanmto := 200.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 708461;
  v_dados(v_dados.last()).vr_nrctremp := 353095;
  v_dados(v_dados.last()).vr_vllanmto := 472.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 608475;
  v_dados(v_dados.last()).vr_nrctremp := 353441;
  v_dados(v_dados.last()).vr_vllanmto := 386.02;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1136470;
  v_dados(v_dados.last()).vr_nrctremp := 358638;
  v_dados(v_dados.last()).vr_vllanmto := 16.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 736767;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 23.85;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 874655;
  v_dados(v_dados.last()).vr_nrctremp := 359656;
  v_dados(v_dados.last()).vr_vllanmto := 389.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 643017;
  v_dados(v_dados.last()).vr_nrctremp := 367176;
  v_dados(v_dados.last()).vr_vllanmto := 20.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14601168;
  v_dados(v_dados.last()).vr_nrctremp := 370082;
  v_dados(v_dados.last()).vr_vllanmto := 530.05;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

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
