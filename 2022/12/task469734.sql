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
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 567256;
    v_dados(v_dados.last()).vr_nrctremp := 112311;
    v_dados(v_dados.last()).vr_vllanmto := 227.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 454788;
    v_dados(v_dados.last()).vr_nrctremp := 129483;
    v_dados(v_dados.last()).vr_vllanmto := 77.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 11550;
    v_dados(v_dados.last()).vr_nrctremp := 132265;
    v_dados(v_dados.last()).vr_vllanmto := 257.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 487287;
    v_dados(v_dados.last()).vr_nrctremp := 144637;
    v_dados(v_dados.last()).vr_vllanmto := 140.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 606561;
    v_dados(v_dados.last()).vr_nrctremp := 170419;
    v_dados(v_dados.last()).vr_vllanmto := 20.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 164372;
    v_dados(v_dados.last()).vr_nrctremp := 172142;
    v_dados(v_dados.last()).vr_vllanmto := 4162.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 763896;
    v_dados(v_dados.last()).vr_nrctremp := 174662;
    v_dados(v_dados.last()).vr_vllanmto := 173.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 456551;
    v_dados(v_dados.last()).vr_nrctremp := 180168;
    v_dados(v_dados.last()).vr_vllanmto := 35.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 874892;
    v_dados(v_dados.last()).vr_nrctremp := 182061;
    v_dados(v_dados.last()).vr_vllanmto := 65.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 589977;
    v_dados(v_dados.last()).vr_nrctremp := 208448;
    v_dados(v_dados.last()).vr_vllanmto := 20.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 662186;
    v_dados(v_dados.last()).vr_nrctremp := 225275;
    v_dados(v_dados.last()).vr_vllanmto := 7.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 729582;
    v_dados(v_dados.last()).vr_nrctremp := 237608;
    v_dados(v_dados.last()).vr_vllanmto := 443.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 15015246;
    v_dados(v_dados.last()).vr_nrctremp := 250563;
    v_dados(v_dados.last()).vr_vllanmto := 20;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 402176;
    v_dados(v_dados.last()).vr_nrctremp := 254349;
    v_dados(v_dados.last()).vr_vllanmto := 15.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 829366;
    v_dados(v_dados.last()).vr_nrctremp := 261350;
    v_dados(v_dados.last()).vr_vllanmto := 19.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 15335267;
    v_dados(v_dados.last()).vr_nrctremp := 265294;
    v_dados(v_dados.last()).vr_vllanmto := 18.08;
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
