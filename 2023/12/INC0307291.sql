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
    vr_cdhistor cecred.craplem.cdhistor%TYPE,
    vr_nrparepr cecred.craplem.nrparepr%TYPE);

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
  v_dados(v_dados.last()).vr_nrdconta := 608203;
  v_dados(v_dados.last()).vr_nrctremp := 172851;
  v_dados(v_dados.last()).vr_vllanmto := 15.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11568828;
  v_dados(v_dados.last()).vr_nrctremp := 6867585;
  v_dados(v_dados.last()).vr_vllanmto := 18921.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16952677;
  v_dados(v_dados.last()).vr_nrctremp := 7045986;
  v_dados(v_dados.last()).vr_vllanmto := 12470;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16275462;
  v_dados(v_dados.last()).vr_nrctremp := 103527;
  v_dados(v_dados.last()).vr_vllanmto := 18096.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16275462;
  v_dados(v_dados.last()).vr_nrctremp := 103555;
  v_dados(v_dados.last()).vr_vllanmto := 19557.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16275462;
  v_dados(v_dados.last()).vr_nrctremp := 104166;
  v_dados(v_dados.last()).vr_vllanmto := 51704.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 16275462;
  v_dados(v_dados.last()).vr_nrctremp := 114069;
  v_dados(v_dados.last()).vr_vllanmto := 6857.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8664528;
  v_dados(v_dados.last()).vr_nrctremp := 1860294;
  v_dados(v_dados.last()).vr_vllanmto := 314.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10997237;
  v_dados(v_dados.last()).vr_nrctremp := 6683890;
  v_dados(v_dados.last()).vr_vllanmto := 435.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80093159;
  v_dados(v_dados.last()).vr_nrctremp := 1886421;
  v_dados(v_dados.last()).vr_vllanmto := 525.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80173870;
  v_dados(v_dados.last()).vr_nrctremp := 2955468;
  v_dados(v_dados.last()).vr_vllanmto := 192.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 290491;
  v_dados(v_dados.last()).vr_nrctremp := 93537;
  v_dados(v_dados.last()).vr_vllanmto := 102.22;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 203181;
  v_dados(v_dados.last()).vr_nrctremp := 43757;
  v_dados(v_dados.last()).vr_vllanmto := 103.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15278794;
  v_dados(v_dados.last()).vr_nrctremp := 46171;
  v_dados(v_dados.last()).vr_vllanmto := 146.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15588386;
  v_dados(v_dados.last()).vr_nrctremp := 42923;
  v_dados(v_dados.last()).vr_vllanmto := 449.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15640981;
  v_dados(v_dados.last()).vr_nrctremp := 45083;
  v_dados(v_dados.last()).vr_vllanmto := 227.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 16365348;
  v_dados(v_dados.last()).vr_nrctremp := 46003;
  v_dados(v_dados.last()).vr_vllanmto := 257.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 16213823;
  v_dados(v_dados.last()).vr_nrctremp := 312925;
  v_dados(v_dados.last()).vr_vllanmto := 109.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15789748;
  v_dados(v_dados.last()).vr_nrctremp := 247939;
  v_dados(v_dados.last()).vr_vllanmto := 367.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15897133;
  v_dados(v_dados.last()).vr_nrctremp := 257699;
  v_dados(v_dados.last()).vr_vllanmto := 291.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15897133;
  v_dados(v_dados.last()).vr_nrctremp := 287430;
  v_dados(v_dados.last()).vr_vllanmto := 82.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 922110;
  v_dados(v_dados.last()).vr_nrctremp := 646388;
  v_dados(v_dados.last()).vr_vllanmto := 491.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16586123;
  v_dados(v_dados.last()).vr_nrctremp := 6811962;
  v_dados(v_dados.last()).vr_vllanmto := 13152.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 16586123;
  v_dados(v_dados.last()).vr_nrctremp := 7510934;
  v_dados(v_dados.last()).vr_vllanmto := 4941.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 47023;
  v_dados(v_dados.last()).vr_nrctremp := 40619;
  v_dados(v_dados.last()).vr_vllanmto := 4601.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9995552;
  v_dados(v_dados.last()).vr_nrctremp := 5777598;
  v_dados(v_dados.last()).vr_vllanmto := 14929.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17623278;
  v_dados(v_dados.last()).vr_nrctremp := 319692;
  v_dados(v_dados.last()).vr_vllanmto := 4242.49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13642502;
  v_dados(v_dados.last()).vr_nrctremp := 7346872;
  v_dados(v_dados.last()).vr_vllanmto := 8335.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14786885;
  v_dados(v_dados.last()).vr_nrctremp := 100239;
  v_dados(v_dados.last()).vr_vllanmto := 755.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15793320;
  v_dados(v_dados.last()).vr_nrctremp := 96778;
  v_dados(v_dados.last()).vr_vllanmto := 151.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 149101;
  v_dados(v_dados.last()).vr_nrctremp := 19244;
  v_dados(v_dados.last()).vr_vllanmto := 193.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  
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
                                           pr_nrparepr => v_dados(x).vr_nrparepr,
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