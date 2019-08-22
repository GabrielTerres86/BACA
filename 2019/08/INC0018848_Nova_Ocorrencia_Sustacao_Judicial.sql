DECLARE
    CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
     ORDER BY cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

BEGIN

    FOR rw_crapcop IN cr_crapcop LOOP
      INSERT INTO crapoco (CDCOOPER, CDDBANCO, CDOCORRE, TPOCORRE, DSOCORRE, CDOPERAD, DTALTERA, HRTRANSA, FLGATIVO)
             VALUES (rw_crapcop.cdcooper, 85, 63, 2, 'Título Sustado Judicialmente', '1', SYSDATE, 0, 1);
    
    END LOOP;
    COMMIT;
END;
