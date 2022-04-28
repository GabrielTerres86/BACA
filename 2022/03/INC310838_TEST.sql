BEGIN
  
  UPDATE CECRED.crapass ass
     SET ass.nmprimtl = 'HELENA NASCIMENTO' 
        ,ass.nmttlrfb = 'HELENA NASCIMENTO'
   WHERE ass.cdcooper = 1
     AND ass.nrdconta = 14347199;
  
  COMMIT;
  
END;   


