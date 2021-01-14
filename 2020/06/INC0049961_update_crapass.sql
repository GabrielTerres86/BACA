BEGIN
  UPDATE crapass ass
     SET ass.nmprimtl = 'ILANI MARLINDA KOLM'
   WHERE ass.cdcooper = 2
     AND ass.nrdconta = 340243;
  COMMIT;    
END;   
