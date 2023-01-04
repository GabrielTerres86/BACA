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
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 224723;
    v_dados(v_dados.last()).vr_nrctremp := 35191;
    v_dados(v_dados.last()).vr_vllanmto := 71.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 88463;
    v_dados(v_dados.last()).vr_nrctremp := 36984;
    v_dados(v_dados.last()).vr_vllanmto := 125.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 78913;
    v_dados(v_dados.last()).vr_nrctremp := 37377;
    v_dados(v_dados.last()).vr_vllanmto := 84.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 264539;
    v_dados(v_dados.last()).vr_nrctremp := 37852;
    v_dados(v_dados.last()).vr_vllanmto := 209.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 185108;
    v_dados(v_dados.last()).vr_nrctremp := 40215;
    v_dados(v_dados.last()).vr_vllanmto := 38.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 65790;
    v_dados(v_dados.last()).vr_nrctremp := 40646;
    v_dados(v_dados.last()).vr_vllanmto := 45.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 25321;
    v_dados(v_dados.last()).vr_nrctremp := 40756;
    v_dados(v_dados.last()).vr_vllanmto := 76.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 50024;
    v_dados(v_dados.last()).vr_nrctremp := 41489;
    v_dados(v_dados.last()).vr_vllanmto := 80.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 103756;
    v_dados(v_dados.last()).vr_nrctremp := 41507;
    v_dados(v_dados.last()).vr_vllanmto := 65.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 78522;
    v_dados(v_dados.last()).vr_nrctremp := 42184;
    v_dados(v_dados.last()).vr_vllanmto := 38.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 274291;
    v_dados(v_dados.last()).vr_nrctremp := 42922;
    v_dados(v_dados.last()).vr_vllanmto := 54.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 296791;
    v_dados(v_dados.last()).vr_nrctremp := 44556;
    v_dados(v_dados.last()).vr_vllanmto := 36.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 112399;
    v_dados(v_dados.last()).vr_nrctremp := 46676;
    v_dados(v_dados.last()).vr_vllanmto := 17.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 264539;
    v_dados(v_dados.last()).vr_nrctremp := 46780;
    v_dados(v_dados.last()).vr_vllanmto := 1742.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 202444;
    v_dados(v_dados.last()).vr_nrctremp := 50641;
    v_dados(v_dados.last()).vr_vllanmto := 21.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 333387;
    v_dados(v_dados.last()).vr_nrctremp := 51145;
    v_dados(v_dados.last()).vr_vllanmto := 56.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 159441;
    v_dados(v_dados.last()).vr_nrctremp := 51159;
    v_dados(v_dados.last()).vr_vllanmto := 22.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 269140;
    v_dados(v_dados.last()).vr_nrctremp := 57904;
    v_dados(v_dados.last()).vr_vllanmto := 25.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 332585;
    v_dados(v_dados.last()).vr_nrctremp := 57979;
    v_dados(v_dados.last()).vr_vllanmto := 38.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 332194;
    v_dados(v_dados.last()).vr_nrctremp := 58051;
    v_dados(v_dados.last()).vr_vllanmto := 27.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 360929;
    v_dados(v_dados.last()).vr_nrctremp := 62245;
    v_dados(v_dados.last()).vr_vllanmto := 22.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 14231336;
    v_dados(v_dados.last()).vr_nrctremp := 66777;
    v_dados(v_dados.last()).vr_vllanmto := 24.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 162094;
    v_dados(v_dados.last()).vr_nrctremp := 68242;
    v_dados(v_dados.last()).vr_vllanmto := 4899.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 264539;
    v_dados(v_dados.last()).vr_nrctremp := 80922;
    v_dados(v_dados.last()).vr_vllanmto := 1074.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 361860;
    v_dados(v_dados.last()).vr_nrctremp := 82820;
    v_dados(v_dados.last()).vr_vllanmto := 415.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 286052;
    v_dados(v_dados.last()).vr_nrctremp := 83521;
    v_dados(v_dados.last()).vr_vllanmto := 39.91;
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
