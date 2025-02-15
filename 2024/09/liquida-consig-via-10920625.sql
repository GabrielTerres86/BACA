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
  v_dados(v_dados.last()).vr_nrdconta := 10920625;
  v_dados(v_dados.last()).vr_nrctremp := 8220789;
  v_dados(v_dados.last()).vr_vllanmto := 1200.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP

    UPDATE cecred.crapepr
       SET dtliquid = to_date('13/09/2024', 'DD/MM/YYYY')
          ,inliquid = 1
          ,vlsdeved = 0
          ,vlsdevat = 0
     WHERE cdcooper = v_dados(x).vr_cdcooper
       AND nrdconta = v_dados(x).vr_nrdconta
       AND nrctremp = v_dados(x).vr_nrctremp;

    UPDATE cecred.crappep
       SET inliquid = 1
          ,vlsdvpar = 0
          ,vlsdvatu = 0
          ,vlpagpar = v_dados(x).vr_vllanmto
          ,dtultpag = to_date('11/09/2024', 'DD/MM/YYYY')
     WHERE cdcooper = v_dados(x).vr_cdcooper
       AND nrdconta = v_dados(x).vr_nrdconta
       AND nrctremp = v_dados(x).vr_nrctremp
       AND nrparepr = 3;

    OPEN  cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
    INTO  rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;

    OPEN  cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
    FETCH cr_crapass
    INTO  rw_crapass;
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
  
  delete from cecred.tbepr_renegociacao_crapepr where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 5395951 and nrversao = 3;

  delete from cecred.tbepr_renegociacao_crawepr where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 5395951 and nrversao = 3;

  delete from cecred.tbepr_renegociacao_craplem where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 5395951 and nrversao = 3;

  delete from cecred.tbepr_renegociacao_crappep where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 5395951 and nrversao = 3;

  delete from  cecred.tbepr_renegociacao where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 8537687;

  delete from cecred.tbepr_renegociacao_contrato where cdcooper = 1 and nrdconta = 6631533 and nrctremp = 8537687;

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
