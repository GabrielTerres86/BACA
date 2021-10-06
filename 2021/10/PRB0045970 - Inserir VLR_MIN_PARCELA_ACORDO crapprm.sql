DECLARE
  CURSOR cr_crapprm(pr_nmsistem crapprm.nmsistem%TYPE
                   ,pr_cdcooper crapprm.cdcooper%TYPE
                   ,pr_cdacesso crapprm.cdacesso%TYPE) IS
    SELECT 1
      FROM crapprm
     WHERE nmsistem = pr_nmsistem
       AND cdcooper = pr_cdcooper
       AND cdacesso = pr_cdacesso;

  rw_crapprm  cr_crapprm%ROWTYPE;
  vr_nmsistem crapprm.nmsistem%TYPE := 'CRED';
  vr_cdcooper crapprm.cdcooper%TYPE := 0;
  vr_cdacesso crapprm.cdacesso%TYPE := 'VLR_MIN_PARCELA_ACORDO';
BEGIN
  OPEN cr_crapprm(pr_nmsistem => vr_nmsistem
                 ,pr_cdcooper => vr_cdcooper
                 ,pr_cdacesso => vr_cdacesso);
  FETCH cr_crapprm
    INTO rw_crapprm;

  IF cr_crapprm%NOTFOUND THEN
    INSERT INTO crapprm
      (NMSISTEM
      ,CDCOOPER
      ,CDACESSO
      ,DSTEXPRM
      ,DSVLRPRM)
    VALUES
      (vr_nmsistem
      ,vr_cdcooper
      ,vr_cdacesso
      ,'Valor mínimo para geração do boleto da parcela do acordo'
      ,'5,00');
    COMMIT;
  END IF;

  CLOSE cr_crapprm;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, 'Erro ao inserir na tabela CRAPPRM: ' || SQLERRM);
END;
