declare
  vr_cdcritic  cecred.crapcri.cdcritic%TYPE;
  vr_dscritic  VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto  varchar(3);
  vr_tab_erro  cecred.GENE0001.typ_tab_erro;
  
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE,
      vr_cdhistor cecred.craplem.cdhistor%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
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
    v_dados(v_dados.last()).vr_vllanmto := 29.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 78913;
    v_dados(v_dados.last()).vr_nrctremp := 37377;
    v_dados(v_dados.last()).vr_vllanmto := 31.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 278963;
    v_dados(v_dados.last()).vr_nrctremp := 39197;
    v_dados(v_dados.last()).vr_vllanmto := 113.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 160296;
    v_dados(v_dados.last()).vr_nrctremp := 39477;
    v_dados(v_dados.last()).vr_vllanmto := 182.58;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 310190;
    v_dados(v_dados.last()).vr_nrctremp := 40091;
    v_dados(v_dados.last()).vr_vllanmto := 259.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 159565;
    v_dados(v_dados.last()).vr_nrctremp := 40202;
    v_dados(v_dados.last()).vr_vllanmto := 26.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 185108;
    v_dados(v_dados.last()).vr_nrctremp := 40215;
    v_dados(v_dados.last()).vr_vllanmto := 11.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 65790;
    v_dados(v_dados.last()).vr_nrctremp := 40646;
    v_dados(v_dados.last()).vr_vllanmto := 12.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 136352;
    v_dados(v_dados.last()).vr_nrctremp := 41051;
    v_dados(v_dados.last()).vr_vllanmto := 11.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 50024;
    v_dados(v_dados.last()).vr_nrctremp := 41489;
    v_dados(v_dados.last()).vr_vllanmto := 11.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 106704;
    v_dados(v_dados.last()).vr_nrctremp := 44726;
    v_dados(v_dados.last()).vr_vllanmto := 20.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 100862;
    v_dados(v_dados.last()).vr_nrctremp := 45034;
    v_dados(v_dados.last()).vr_vllanmto := 8828.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 219690;
    v_dados(v_dados.last()).vr_nrctremp := 48729;
    v_dados(v_dados.last()).vr_vllanmto := 1727.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 195189;
    v_dados(v_dados.last()).vr_nrctremp := 57208;
    v_dados(v_dados.last()).vr_vllanmto := 16.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 269140;
    v_dados(v_dados.last()).vr_nrctremp := 57904;
    v_dados(v_dados.last()).vr_vllanmto := 531.09;
    v_dados(v_dados.last()).vr_cdhistor := 3918;


  
  FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
      FETCH cecred.btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE cecred.btch0001.cr_crapdat;
      OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
  
      cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => v_dados(x).vr_cdcooper,
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
