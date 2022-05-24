DECLARE
  vr_code NUMBER;
  vr_errm VARCHAR2(64);
BEGIN
  DELETE FROM CECRED.CRAPCRI
   WHERE CDCRITIC IN (10606,10607);
   
   COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao executar Rollback das criticas 10606,10607,10608 e 10609 - ' || vr_code || ' / ' || vr_errm);
END;    
