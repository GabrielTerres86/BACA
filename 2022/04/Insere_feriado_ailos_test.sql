BEGIN
  INSERT 
    INTO CECRED.CRAPFER(DTFERIAD
                       ,CDCOOPER
                       ,TPFERIAD
                       ,DSFERIAD)
                VALUES(TO_DATE('13/04/2022','DD/MM/RRRR')
                      ,3
                      ,1
                      ,'TESTE ANDERSON');
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
