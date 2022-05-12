declare
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
  v_dados        t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
BEGIN

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 834688;
    v_dados(v_dados.last()).vr_nrctremp := 264344;
    v_dados(v_dados.last()).vr_vllanmto := 57.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 839132;
    v_dados(v_dados.last()).vr_nrctremp := 265217;
    v_dados(v_dados.last()).vr_vllanmto := 182.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 839132;
    v_dados(v_dados.last()).vr_nrctremp := 265217;
    v_dados(v_dados.last()).vr_vllanmto := 92.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 580830;
    v_dados(v_dados.last()).vr_nrctremp := 265383;
    v_dados(v_dados.last()).vr_vllanmto := 113.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 580830;
    v_dados(v_dados.last()).vr_nrctremp := 265383;
    v_dados(v_dados.last()).vr_vllanmto := 12.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 846210;
    v_dados(v_dados.last()).vr_nrctremp := 266676;
    v_dados(v_dados.last()).vr_vllanmto := 15.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 846210;
    v_dados(v_dados.last()).vr_nrctremp := 266676;
    v_dados(v_dados.last()).vr_vllanmto := 23.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 853720;
    v_dados(v_dados.last()).vr_nrctremp := 268464;
    v_dados(v_dados.last()).vr_vllanmto := 5.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 858200;
    v_dados(v_dados.last()).vr_nrctremp := 269473;
    v_dados(v_dados.last()).vr_vllanmto := 34.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 859079;
    v_dados(v_dados.last()).vr_nrctremp := 269679;
    v_dados(v_dados.last()).vr_vllanmto := 7.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 859354;
    v_dados(v_dados.last()).vr_nrctremp := 269793;
    v_dados(v_dados.last()).vr_vllanmto := 165.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 860301;
    v_dados(v_dados.last()).vr_nrctremp := 270125;
    v_dados(v_dados.last()).vr_vllanmto := 3.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 866547;
    v_dados(v_dados.last()).vr_nrctremp := 271760;
    v_dados(v_dados.last()).vr_vllanmto := 10.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 866547;
    v_dados(v_dados.last()).vr_nrctremp := 271760;
    v_dados(v_dados.last()).vr_vllanmto := 78.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 844730;
    v_dados(v_dados.last()).vr_nrctremp := 272518;
    v_dados(v_dados.last()).vr_vllanmto := 65.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 871389;
    v_dados(v_dados.last()).vr_nrctremp := 273233;
    v_dados(v_dados.last()).vr_vllanmto := 163.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 870447;
    v_dados(v_dados.last()).vr_nrctremp := 273372;
    v_dados(v_dados.last()).vr_vllanmto := 60.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 870447;
    v_dados(v_dados.last()).vr_nrctremp := 273372;
    v_dados(v_dados.last()).vr_vllanmto := 221.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 884367;
    v_dados(v_dados.last()).vr_nrctremp := 276947;
    v_dados(v_dados.last()).vr_vllanmto := 14.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 884367;
    v_dados(v_dados.last()).vr_nrctremp := 276947;
    v_dados(v_dados.last()).vr_vllanmto := 184.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 837180;
    v_dados(v_dados.last()).vr_nrctremp := 277467;
    v_dados(v_dados.last()).vr_vllanmto := 96.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 891134;
    v_dados(v_dados.last()).vr_nrctremp := 277529;
    v_dados(v_dados.last()).vr_vllanmto := 43.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 891134;
    v_dados(v_dados.last()).vr_nrctremp := 277529;
    v_dados(v_dados.last()).vr_vllanmto := 203.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 848050;
    v_dados(v_dados.last()).vr_nrctremp := 278327;
    v_dados(v_dados.last()).vr_vllanmto := 97.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 848050;
    v_dados(v_dados.last()).vr_nrctremp := 278327;
    v_dados(v_dados.last()).vr_vllanmto := 54.05;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 890499;
    v_dados(v_dados.last()).vr_nrctremp := 279292;
    v_dados(v_dados.last()).vr_vllanmto := 8.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 890499;
    v_dados(v_dados.last()).vr_nrctremp := 279292;
    v_dados(v_dados.last()).vr_vllanmto := 142.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 909165;
    v_dados(v_dados.last()).vr_nrctremp := 281596;
    v_dados(v_dados.last()).vr_vllanmto := 29.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 909165;
    v_dados(v_dados.last()).vr_nrctremp := 281596;
    v_dados(v_dados.last()).vr_vllanmto := 107.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 926388;
    v_dados(v_dados.last()).vr_nrctremp := 286504;
    v_dados(v_dados.last()).vr_vllanmto := 91.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 926388;
    v_dados(v_dados.last()).vr_nrctremp := 286504;
    v_dados(v_dados.last()).vr_vllanmto := 14.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 927228;
    v_dados(v_dados.last()).vr_nrctremp := 287284;
    v_dados(v_dados.last()).vr_vllanmto := 32.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 643017;
    v_dados(v_dados.last()).vr_nrctremp := 297340;
    v_dados(v_dados.last()).vr_vllanmto := 5021.7;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 961116;
    v_dados(v_dados.last()).vr_nrctremp := 297576;
    v_dados(v_dados.last()).vr_vllanmto := 32.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 961116;
    v_dados(v_dados.last()).vr_nrctremp := 297576;
    v_dados(v_dados.last()).vr_vllanmto := 174.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 741000;
    v_dados(v_dados.last()).vr_nrctremp := 304587;
    v_dados(v_dados.last()).vr_vllanmto := 7.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 989231;
    v_dados(v_dados.last()).vr_nrctremp := 307718;
    v_dados(v_dados.last()).vr_vllanmto := 86.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 999105;
    v_dados(v_dados.last()).vr_nrctremp := 310302;
    v_dados(v_dados.last()).vr_vllanmto := 7.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 615455;
    v_dados(v_dados.last()).vr_nrctremp := 321708;
    v_dados(v_dados.last()).vr_vllanmto := 308.43;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 615455;
    v_dados(v_dados.last()).vr_nrctremp := 321708;
    v_dados(v_dados.last()).vr_vllanmto := 133.05;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 930938;
    v_dados(v_dados.last()).vr_nrctremp := 322349;
    v_dados(v_dados.last()).vr_vllanmto := 68.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 936057;
    v_dados(v_dados.last()).vr_nrctremp := 322439;
    v_dados(v_dados.last()).vr_vllanmto := 51.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1069217;
    v_dados(v_dados.last()).vr_nrctremp := 338555;
    v_dados(v_dados.last()).vr_vllanmto := 18.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1119605;
    v_dados(v_dados.last()).vr_nrctremp := 352146;
    v_dados(v_dados.last()).vr_vllanmto := 170.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 697370;
    v_dados(v_dados.last()).vr_nrctremp := 352338;
    v_dados(v_dados.last()).vr_vllanmto := 181.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 708461;
    v_dados(v_dados.last()).vr_nrctremp := 353095;
    v_dados(v_dados.last()).vr_vllanmto := 472.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 608475;
    v_dados(v_dados.last()).vr_nrctremp := 353441;
    v_dados(v_dados.last()).vr_vllanmto := 418.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1136470;
    v_dados(v_dados.last()).vr_nrctremp := 358638;
    v_dados(v_dados.last()).vr_vllanmto := 11.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 585068;
    v_dados(v_dados.last()).vr_nrctremp := 359290;
    v_dados(v_dados.last()).vr_vllanmto := 25.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 874655;
    v_dados(v_dados.last()).vr_nrctremp := 359656;
    v_dados(v_dados.last()).vr_vllanmto := 7.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;




  
  FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
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
end;
