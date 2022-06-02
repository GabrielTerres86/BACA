BEGIN
  update cecred.crawcrd set
         insitcrd = 6,
         nrcctitg = 7564468001636 
  where cdcooper = 14
  and nrdconta = 19852
  and nrctrcrd in (71239, 70993, 22209);  
  
  COMMIT;

END;
