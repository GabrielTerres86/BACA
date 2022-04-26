BEGIN

  DELETE crapcem t 
   WHERE t.cdcooper = 1 
     AND t.nrdconta = 3744884
     AND t.cddemail = 2;
     
  UPDATE crapcem t 
     SET t.dsdemail = 'email-alterado@xxserver.com.br'
   WHERE t.cdcooper = 1 
     AND t.nrdconta = 3744884
     AND t.cddemail = 1;
  
  COMMIT;
  
END;
