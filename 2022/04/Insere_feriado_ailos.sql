BEGIN
  INSERT 
    INTO CECRED.CRAPFER(DTFERIAD
                       ,CDCOOPER
                       ,TPFERIAD
                       ,DSFERIAD)
                VALUES('13/04/2022'
                      ,3
                      ,1
                      ,'TESTE ANDERSON');
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
