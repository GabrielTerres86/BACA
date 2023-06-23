BEGIN
  
  UPDATE cecred.crapblj
     SET dtblqfim =  trunc(sysdate), 
         cdopddes = 1,
         nrofides = 1, 
         dtenvdes = trunc(sysdate),
         dsinfdes = 'Desbloqueio de valor zerado'
  WHERE cdcooper = 1 
    AND nrdconta = 14626730 
    AND vlbloque = 0 
    AND dtblqfim IS NULL;
    
  UPDATE cecred.crapblj
     SET dtblqfim =  trunc(sysdate), 
         cdopddes = 1,
         nrofides = 1, 
         dtenvdes = trunc(sysdate),
         dsinfdes = 'Desbloqueio de valor zerado'
  WHERE cdcooper = 16 
    AND nrdconta = 185884 
    AND vlbloque = 0 
    AND dtblqfim IS NULL;

  COMMIT;

END;
