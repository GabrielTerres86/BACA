BEGIN
  
  UPDATE crapprm
     SET dsvlrprm = ',1,2,5,6,7,8,9,10,11,12,13,14,16'
   WHERE cdcooper = 0
     AND cdacesso = 'LMT_CREDITO_COTA_CAPITAL';
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   
END;   
