BEGIN         
  UPDATE  tbgen_batch_param t
  SET t.qtparalelo = 10
   WHERE t.cdcooper   = 1
   AND t.cdprograma = 'CRPS310';     
  COMMIT;
END; 
