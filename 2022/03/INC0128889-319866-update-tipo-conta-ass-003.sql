BEGIN    
  UPDATE crapass ass
     SET ass.cdtipcta = 8  
   WHERE ass.cdcooper = 7
     AND ass.nrdconta = 850004
     AND ass.nrcpfcgc = 5979692000185
     AND ass.cdtipcta = 19;
     
  COMMIT;
END;