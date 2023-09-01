DECLARE 
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
BEGIN

  GESTAODERISCO.finalizarCentralRisco(pr_cdcooper => 1
                                     ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic || ' - ' || SQLERRM);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
