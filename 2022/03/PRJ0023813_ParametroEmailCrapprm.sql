DECLARE
  vr_nmsistem crapprm.nmsistem%TYPE := 'CRED';
  vr_cdcooper crapprm.cdcooper%TYPE := 0;

  vr_cdacessohonra crapprm.cdacesso%TYPE := 'EMAIL_CRITICA_HONRA_PEAC';
  vr_dstexprmhonra crapprm.dstexprm%TYPE := 'E-mail de recebimento de criticas da solicitacao de honra e recuperacao do valor - PEAC';
  vr_dsvlrprmhonra crapprm.dsvlrprm%TYPE := 'estrategiadecobranca@ailos.coop.br';

  vr_cdacessoamort crapprm.cdacesso%TYPE := 'EMAIL_CRITICA_AMORT_PEAC';
  vr_dstexprmamort crapprm.dstexprm%TYPE := 'E-mail de recebimento de criticas da amortizacao antecipada - PEAC';
  vr_dsvlrprmamort crapprm.dsvlrprm%TYPE := 'produtoscredito@ailos.coop.br';

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
      ,vr_cdacessohonra
      ,vr_dstexprmhonra
      ,vr_dsvlrprmhonra);
  EXCEPTION
    WHEN dup_val_on_index THEN
      UPDATE crapprm
         SET dsvlrprm = vr_dsvlrprmhonra
       WHERE nmsistem = vr_nmsistem
         AND cdcooper = vr_cdcooper
         AND cdacesso = vr_cdacessohonra;
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      RAISE vr_exc_erro;
  END;

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
      ,vr_cdacessoamort
      ,vr_dstexprmamort
      ,vr_dsvlrprmamort);
  EXCEPTION
    WHEN dup_val_on_index THEN
      UPDATE crapprm
         SET dsvlrprm = vr_dsvlrprmamort
       WHERE nmsistem = vr_nmsistem
         AND cdcooper = vr_cdcooper
         AND cdacesso = vr_cdacessoamort;
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
