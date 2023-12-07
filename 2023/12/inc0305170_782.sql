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
  v_dados(v_dados.last()).vr_nrdconta := 9557504;
  v_dados(v_dados.last()).vr_nrctremp := 6765160;
  v_dados(v_dados.last()).vr_vllanmto := 943.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10995277;
  v_dados(v_dados.last()).vr_nrctremp := 6382671;
  v_dados(v_dados.last()).vr_vllanmto := 1393.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12515701;
  v_dados(v_dados.last()).vr_nrctremp := 6876735;
  v_dados(v_dados.last()).vr_vllanmto := 9012.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14133660;
  v_dados(v_dados.last()).vr_nrctremp := 6137614;
  v_dados(v_dados.last()).vr_vllanmto := 17986.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 457736;
  v_dados(v_dados.last()).vr_nrctremp := 373587;
  v_dados(v_dados.last()).vr_vllanmto := 20785.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 729450;
  v_dados(v_dados.last()).vr_nrctremp := 444897;
  v_dados(v_dados.last()).vr_vllanmto := 6393.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 779954;
  v_dados(v_dados.last()).vr_nrctremp := 369813;
  v_dados(v_dados.last()).vr_vllanmto := 299.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 847860;
  v_dados(v_dados.last()).vr_nrctremp := 452505;
  v_dados(v_dados.last()).vr_vllanmto := 8126.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 877786;
  v_dados(v_dados.last()).vr_nrctremp := 416930;
  v_dados(v_dados.last()).vr_vllanmto := 389.38;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 978892;
  v_dados(v_dados.last()).vr_nrctremp := 364835;
  v_dados(v_dados.last()).vr_vllanmto := 9056.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 978892;
  v_dados(v_dados.last()).vr_nrctremp := 430430;
  v_dados(v_dados.last()).vr_vllanmto := 3897.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 983667;
  v_dados(v_dados.last()).vr_nrctremp := 436128;
  v_dados(v_dados.last()).vr_vllanmto := 3032.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 371912;
  v_dados(v_dados.last()).vr_nrctremp := 350358;
  v_dados(v_dados.last()).vr_vllanmto := 227.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 920185;
  v_dados(v_dados.last()).vr_nrctremp := 277259;
  v_dados(v_dados.last()).vr_vllanmto := 11250.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 116432;
  v_dados(v_dados.last()).vr_nrctremp := 42317;
  v_dados(v_dados.last()).vr_vllanmto := 11566.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 116432;
  v_dados(v_dados.last()).vr_nrctremp := 68259;
  v_dados(v_dados.last()).vr_vllanmto := 2426.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 221317;
  v_dados(v_dados.last()).vr_nrctremp := 90302;
  v_dados(v_dados.last()).vr_vllanmto := 569.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 286184;
  v_dados(v_dados.last()).vr_nrctremp := 45957;
  v_dados(v_dados.last()).vr_vllanmto := 243.69;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14255308;
  v_dados(v_dados.last()).vr_nrctremp := 109017;
  v_dados(v_dados.last()).vr_vllanmto := 19304.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1045229;
  v_dados(v_dados.last()).vr_nrctremp := 662504;
  v_dados(v_dados.last()).vr_vllanmto := 365.75;
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