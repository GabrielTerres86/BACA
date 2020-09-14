BEGIN
  
  -- 11743611 -- Conta criada corretamente e que foi apagada indevidamente
  -- 11746352 -- Conta gerada para resolver o problema paleativamente, que deveria ter sido apagada, mas será utilizada como base para a nova conta

  UPDATE crapass t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;
  
  UPDATE crapttl t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;
 
  UPDATE crapenc t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;

  UPDATE craptfc t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;
  
  UPDATE crapcem t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;
  
  UPDATE crapbem t
     SET t.nrdconta = 11743611
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11746352;
    
  COMMIT;
    
END;
