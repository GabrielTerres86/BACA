BEGIN
  
  UPDATE cecred.crapttx
     SET qtdiaini = 30
   WHERE tptaxrdc = 7
     AND cdcooper = 11
     AND cdperapl = 1; 
     
  COMMIT;
  
END;
