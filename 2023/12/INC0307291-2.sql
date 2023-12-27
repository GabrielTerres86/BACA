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
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 15128792;
  v_dados(v_dados.last()).vr_nrctremp := 371162;
  v_dados(v_dados.last()).vr_vllanmto := 19248.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 539759;
  v_dados(v_dados.last()).vr_nrctremp := 203098;
  v_dados(v_dados.last()).vr_vllanmto := 78.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 637823;
  v_dados(v_dados.last()).vr_nrctremp := 442887;
  v_dados(v_dados.last()).vr_vllanmto := 10715.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149969;
  v_dados(v_dados.last()).vr_nrctremp := 275424;
  v_dados(v_dados.last()).vr_vllanmto := 6927.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149969;
  v_dados(v_dados.last()).vr_nrctremp := 276618;
  v_dados(v_dados.last()).vr_vllanmto := 41610.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273872;
  v_dados(v_dados.last()).vr_nrctremp := 286877;
  v_dados(v_dados.last()).vr_vllanmto := 1628;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668311;
  v_dados(v_dados.last()).vr_nrctremp := 289348;
  v_dados(v_dados.last()).vr_vllanmto := 10030.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668311;
  v_dados(v_dados.last()).vr_nrctremp := 321200;
  v_dados(v_dados.last()).vr_vllanmto := 2831.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 668311;
  v_dados(v_dados.last()).vr_nrctremp := 329070;
  v_dados(v_dados.last()).vr_vllanmto := 511;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15458741;
  v_dados(v_dados.last()).vr_nrctremp := 117304;
  v_dados(v_dados.last()).vr_vllanmto := 9947.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 314430;
  v_dados(v_dados.last()).vr_vllanmto := 8945.35;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 342539;
  v_dados(v_dados.last()).vr_vllanmto := 2593.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 350139;
  v_dados(v_dados.last()).vr_vllanmto := 3330.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 383940;
  v_dados(v_dados.last()).vr_vllanmto := 11431.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145319;
  v_dados(v_dados.last()).vr_nrctremp := 113718;
  v_dados(v_dados.last()).vr_vllanmto := 31402.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145319;
  v_dados(v_dados.last()).vr_nrctremp := 114005;
  v_dados(v_dados.last()).vr_vllanmto := 10277.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145319;
  v_dados(v_dados.last()).vr_nrctremp := 185084;
  v_dados(v_dados.last()).vr_vllanmto := 3714.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 268569;
  v_dados(v_dados.last()).vr_nrctremp := 236688;
  v_dados(v_dados.last()).vr_vllanmto := 419.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 618713;
  v_dados(v_dados.last()).vr_nrctremp := 333271;
  v_dados(v_dados.last()).vr_vllanmto := 69.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17476348;
  v_dados(v_dados.last()).vr_nrctremp := 314491;
  v_dados(v_dados.last()).vr_vllanmto := 158.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17476348;
  v_dados(v_dados.last()).vr_nrctremp := 314508;
  v_dados(v_dados.last()).vr_vllanmto := 7393.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17476348;
  v_dados(v_dados.last()).vr_nrctremp := 314517;
  v_dados(v_dados.last()).vr_vllanmto := 6907.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17476348;
  v_dados(v_dados.last()).vr_nrctremp := 316606;
  v_dados(v_dados.last()).vr_vllanmto := 610.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17705754;
  v_dados(v_dados.last()).vr_nrctremp := 387197;
  v_dados(v_dados.last()).vr_vllanmto := 15929.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 17705754;
  v_dados(v_dados.last()).vr_nrctremp := 394894;
  v_dados(v_dados.last()).vr_vllanmto := 7639.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17738571;
  v_dados(v_dados.last()).vr_nrctremp := 330788;
  v_dados(v_dados.last()).vr_vllanmto := 2210.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 17738571;
  v_dados(v_dados.last()).vr_nrctremp := 330790;
  v_dados(v_dados.last()).vr_vllanmto := 1252.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 185140;
  v_dados(v_dados.last()).vr_nrctremp := 78622;
  v_dados(v_dados.last()).vr_vllanmto := 16112.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 185140;
  v_dados(v_dados.last()).vr_nrctremp := 108764;
  v_dados(v_dados.last()).vr_vllanmto := 9351.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8451133;
  v_dados(v_dados.last()).vr_nrctremp := 7254335;
  v_dados(v_dados.last()).vr_vllanmto := 4436.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14122413;
  v_dados(v_dados.last()).vr_nrctremp := 106506;
  v_dados(v_dados.last()).vr_vllanmto := 51541.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0; 
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129860;
  v_dados(v_dados.last()).vr_nrctremp := 262350;
  v_dados(v_dados.last()).vr_vllanmto := 2597.8;
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