DECLARE
  CURSOR cr_crapepr(pr_cdcooper       IN cecred.crapepr.cdcooper%TYPE
                   ,pr_nrctremp       IN cecred.crapepr.nrctremp%TYPE
                   ,pr_progress_recid IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,b.cdagenci
          ,a.nrctremp
          ,a.dtmvtolt
          ,a.cdlcremp
          ,a.vlemprst
          ,c.dtdpagto wdtdpagto
          ,c.txmensal wtxmensal
          ,a.vlsprojt
          ,a.qttolatr
      FROM cecred.crapepr a
          ,cecred.crapass b
          ,cecred.crawepr c
     WHERE a.cdcooper = b.cdcooper
       AND a.nrdconta = b.nrdconta
       AND a.cdcooper = c.cdcooper
       AND a.nrdconta = c.nrdconta
       AND a.nrctremp = c.nrctremp
       AND a.cdcooper = pr_cdcooper
       AND a.nrctremp = pr_nrctremp
       AND b.progress_recid = pr_progress_recid;
  rw_crapepr cr_crapepr%ROWTYPE;

  vr_cdcooper       cecred.crapepr.cdcooper%TYPE := 9;
  vr_nrctremp       cecred.crapepr.nrctremp%TYPE := 51487;
  vr_progress_recid cecred.crapass.progress_recid%TYPE := 1444361;

  vr_idvlrmin NUMBER;
  vr_vltotpag NUMBER;
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic cecred.crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cecred.btch0001.cr_crapdat
    INTO cecred.btch0001.rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;

  OPEN cr_crapepr(pr_cdcooper       => vr_cdcooper,
                  pr_nrctremp       => vr_nrctremp,
                  pr_progress_recid => vr_progress_recid);
  FETCH cr_crapepr
    INTO rw_crapepr;
  CLOSE cr_crapepr;

  IF nvl(rw_crapepr.cdcooper, 0) > 0 THEN
    cecred.recp0001.pc_pagar_emprestimo_pos(pr_cdcooper => rw_crapepr.cdcooper,
                                            pr_nrdconta => rw_crapepr.nrdconta,
                                            pr_cdagenci => rw_crapepr.cdagenci,
                                            pr_crapdat  => cecred.btch0001.rw_crapdat,
                                            pr_nrctremp => rw_crapepr.nrctremp,
                                            pr_dtefetiv => rw_crapepr.dtmvtolt,
                                            pr_cdlcremp => rw_crapepr.cdlcremp,
                                            pr_vlemprst => rw_crapepr.vlemprst,
                                            pr_txmensal => rw_crapepr.wtxmensal,
                                            pr_dtdpagto => rw_crapepr.wdtdpagto,
                                            pr_vlsprojt => rw_crapepr.vlsprojt,
                                            pr_qttolatr => rw_crapepr.qttolatr,
                                            pr_nrparcel => 0,
                                            pr_vlparcel => 0,
                                            pr_inliqaco => 'S',
                                            pr_idorigem => 7,
                                            pr_nmtelant => 'BLQPREJU',
                                            pr_cdoperad => '1',
                                            pr_idvlrmin => vr_idvlrmin,
                                            pr_vltotpag => vr_vltotpag,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    COMMIT;
  ELSE
    vr_dscritic := 'Contrato não encontrado.';
    RAISE vr_exc_erro;
  END IF;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
