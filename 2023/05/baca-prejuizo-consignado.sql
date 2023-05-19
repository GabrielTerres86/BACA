DECLARE
  vr_cdcoppar crapcop.cdcooper%TYPE;
  vr_infimsol INTEGER;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  vr_exc_erro_tratado EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM cecred.crapcop cop
     WHERE cop.cdcooper <> 3
           AND cop.flgativo = 1
     ORDER BY cop.cdcooper;
BEGIN

  UPDATE TBEPR_CONSIGNADO_PAGAMENTO A
     SET INSTATUS = 2
   WHERE CDCOOPER = 10
         AND NRDCONTA = 145890
         AND NRCTREMP = 12747
         AND NRPAREPR = 23
         AND INSTATUS = 3;

  FOR rw_crapcop IN cr_crapcop LOOP
    vr_cdcoppar := rw_crapcop.cdcooper;
    cecred.pc_crps780(pr_cdcooper => vr_cdcoppar
                     ,pr_nmdatela => 'job'
                     ,pr_infimsol => vr_infimsol
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);
  
    IF NVL(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
      vr_dscritic := vr_dscritic || ' Retorno pc_crps780';
      RAISE vr_exc_erro_tratado;
    END IF;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro_tratado THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_dscritic);
END;
