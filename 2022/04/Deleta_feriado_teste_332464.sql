BEGIN
  DELETE CECRED.CRAPFER
   WHERE CDCOOPER = 3
     AND DSFERIAD = 'TESTE ANDERSON';
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;         