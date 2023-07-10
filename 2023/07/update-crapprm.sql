BEGIN
  UPDATE cecred.crapprm 
     SET dsvlrprm = dsvlrprm || ','
   WHERE cdacesso = 'LMT_CREDITO_COTA_CAPITAL';   

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN    
    ROLLBACK;
END;
