DECLARE
  VR_EXC_ERRO EXCEPTION;
  VR_DSCRITIC CECRED.CRAPCRI.DSCRITIC%TYPE;

  CURSOR CR_CRAPCOP IS
    SELECT C.CDCOOPER FROM CECRED.CRAPCOP C WHERE C.FLGATIVO = 1;

BEGIN
  FOR COP IN CR_CRAPCOP LOOP
    BEGIN
      INSERT INTO CECRED.CRAPPRM P
        (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
      VALUES
        ('CRED',
         COP.CDCOOPER,
         'QTDDIASDUPLICESSAOCARTAO',
         'Qtd em dias utilizada para validar cessao de cartão importada em duplicidade (PC_CRPS714)',
         '45');
    EXCEPTION
      WHEN OTHERS THEN
        VR_DSCRITIC := 'Erro ao criar parâmetro (CECRED.CRAPPRM) para a cooperativa: ' ||
                       COP.CDCOOPER;
        RAISE VR_EXC_ERRO;
    END;
  END LOOP;
  IF (SQL%ROWCOUNT > 0) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN VR_EXC_ERRO THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20100,
                            'Erro na criação de parametro - ' ||
                            VR_DSCRITIC || CHR(13) || SQLERRM);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20100,
                            'Erro na criação de parametro - ' || SQLERRM);
END;
