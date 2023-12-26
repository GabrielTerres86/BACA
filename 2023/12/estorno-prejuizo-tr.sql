DECLARE
  vr_tab_erro gene0001.typ_tab_erro;
  vr_des_reto VARCHAR2(10) := 'OK';
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_exc_erro EXCEPTION;

  CURSOR cr_ctr_tr IS
    SELECT a.cdcooper, a.nrdconta, a.nrctremp, b.cdagenci
      FROM crapepr a
     INNER JOIN crapass b
        ON a.cdcooper = b.cdcooper
       AND a.nrdconta = b.nrdconta
     WHERE a.progress_recid IN (1390545, 1768261);

BEGIN

  FOR tr IN cr_ctr_tr LOOP
  
    OPEN btch0001.cr_crapdat(tr.cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    prej0001.pc_estorno_trf_prejuizo_tr(pr_cdcooper => tr.cdcooper,
                                        pr_cdagenci => tr.cdagenci,
                                        pr_nrdcaixa => 100,
                                        pr_cdoperad => 1,
                                        pr_nrdconta => tr.nrdconta,
                                        pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                        pr_nrctremp => tr.nrctremp,
                                        pr_des_reto => vr_des_reto,
                                        pr_tab_erro => vr_tab_erro);
  
    IF vr_des_reto <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
  
    COMMIT;
  END LOOP;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
END;
