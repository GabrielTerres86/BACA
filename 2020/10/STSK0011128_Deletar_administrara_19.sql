BEGIN
  DELETE FROM crapadc a WHERE a.cdadmcrd = 19;
  
  UPDATE crapadc a 
     SET a.nmadmcrd = 'AILOS MASTERCARD NOW PERSONALIZADO',
         a.nmresadm = 'AILOS NOW PERSONALIZADO'
   WHERE a.cdadmcrd = 18;
   
   DELETE FROM crapacb a WHERE a.cdadmcrd = 18;
   
   UPDATE crapacb a 
      SET a.cdadmcrd = 18
    WHERE a.cdadmcrd = 19;
   
   COMMIT;    
END;
