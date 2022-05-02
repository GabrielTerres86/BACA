BEGIN
  update crawcrd set
  insitcrd = 4,
  nrcrcard = 5127070283056646
  where cdcooper = 1
  and nrdconta = 930
  and nrctrcrd = 2010153;  
  
  update crapcrd set
  nrcrcard = 5127070283056646
  where cdcooper = 1
  and nrdconta = 930
  and nrctrcrd = 2010153; 
  
  COMMIT;
  
  update crawcrd set
  insitcrd = 4,
  nrcrcard = 5158940050030200
  where cdcooper = 1
  and nrdconta = 930
  and nrctrcrd = 1279721;  
  
  update crapcrd set
  nrcrcard = 5158940050030200
  where cdcooper = 1
  and nrdconta = 930
  and nrctrcrd = 1279721; 

  COMMIT;
END;
