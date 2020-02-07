DECLARE

  -- Busca cooperativas ativas
  CURSOR CR_CRAPCOP IS
    SELECT COP.CDCOOPER
      FROM CRAPCOP COP
     WHERE COP.FLGATIVO = 1
       AND COP.CDCOOPER <> 3
     ORDER BY COP.CDCOOPER;

  VR_DSCRITIC VARCHAR2(4000);
  VR_EXC_ERRO EXCEPTION;

BEGIN

  FOR RW_CRAPCOP IN CR_CRAPCOP LOOP
    BEGIN
      INSERT INTO CRAPMOT
        (CDCOOPER,
         CDDBANCO,
         CDOCORRE,
         TPOCORRE,
         CDMOTIVO,
         DSMOTIVO,
         DSABREVI,
         CDOPERAD,
         DTALTERA,
         HRTRANSA)
      VALUES
        (RW_CRAPCOP.CDCOOPER,
         85,
         26,
         2,
         'B6',
         'Parâmetro Pag. Divergente não habilitado no convênio de cobrança',
         ' ',
         '1',
         TRUNC(SYSDATE),
         ((TO_CHAR(SYSDATE, 'HH24') * 60 * 60) +
         TO_CHAR(SYSDATE, 'MI') * 60) + TO_CHAR(SYSDATE, 'SS'));
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.PC_INTERNAL_EXCEPTION;
        ROLLBACK;
    END;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    ROLLBACK;
END;
