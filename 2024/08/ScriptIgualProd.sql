DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro cecred.GENE0001.typ_tab_erro;
  vr_historic NUMBER(5);
  vr_lancamen NUMBER(25,2);

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
    SELECT
        ass.cdagenci,
        epr.inliquid,
        epr.inprejuz,
        CASE
            WHEN epr.inliquid = 1 AND epr.inprejuz = 0 THEN
                credito.obtersaldocontratoliquidadoconsignado(
                    pr_cdcooper => epr.cdcooper,
                    pr_nrdconta => epr.nrdconta,
                    pr_nrctremp => epr.nrctremp
                )
            ELSE
                0
        END AS saldo_contrato 
    FROM
      cecred.crapass ass,
      cecred.crapepr epr
    WHERE
        epr.cdcooper = ass.cdcooper
        AND epr.nrdconta = ass.nrdconta
        AND ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 99234645;
  v_dados(v_dados.last()).vr_nrctremp := 7492262;
  v_dados(v_dados.last()).vr_vllanmto := 20209.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;


  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP

    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;

    OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta, pr_nrctremp => v_dados(x).vr_nrctremp);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;

    IF rw_crapass.inliquid = 1 AND rw_crapass.inprejuz = 0 THEN
  
      IF rw_crapass.saldo_contrato <> 0 THEN
  
          vr_lancamen := 0;
          vr_historic := 0;
  
          IF nvl(rw_crapass.saldo_contrato, 0) < 0 THEN
              vr_historic := 3918;
              vr_lancamen := rw_crapass.saldo_contrato * -1;
            ELSIF nvl(rw_crapass.saldo_contrato, 0) > 0 THEN
              vr_historic := 3919;
              vr_lancamen := rw_crapass.saldo_contrato;
            END IF;
        
        
            cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => v_dados(x).vr_cdcooper,
                                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                   pr_cdagenci => rw_crapass.cdagenci,
                                                   pr_cdbccxlt => 100,
                                                   pr_cdoperad => 1,
                                                   pr_cdpactra => rw_crapass.cdagenci,
                                                   pr_tplotmov => 5,
                                                   pr_nrdolote => 600031,
                                                   pr_nrdconta => v_dados(x).vr_nrdconta,
                                                   pr_cdhistor => vr_historic,
                                                   pr_nrctremp => v_dados(x).vr_nrctremp,
                                                   pr_vllanmto => vr_lancamen,
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
    
    END IF;
    ELSE 
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
