DECLARE
  vr_nmsistem crapprm.nmsistem%TYPE := 'CRED';
  vr_cdcooper crapprm.cdcooper%TYPE := 0;
  vr_cdacesso crapprm.cdacesso%TYPE := 'DATA_INICIO_AMORT_PEAC';
  vr_dstexprm crapprm.dstexprm%TYPE := 'PEAC - Data de Inicio da Amortizacao Antecipada';
  vr_dsvlrprm crapprm.dsvlrprm%TYPE := '29/05/2022';
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
BEGIN
  BEGIN
    INSERT INTO crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      (vr_nmsistem
      ,vr_cdcooper
      ,vr_cdacesso
      ,vr_dstexprm
      ,vr_dsvlrprm);
  EXCEPTION
    WHEN dup_val_on_index THEN
      UPDATE crapprm
         SET dsvlrprm = vr_dsvlrprm
       WHERE nmsistem = vr_nmsistem
         AND cdcooper = vr_cdcooper
         AND cdacesso = vr_cdacesso;
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      RAISE vr_exc_erro;
  END;

  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
