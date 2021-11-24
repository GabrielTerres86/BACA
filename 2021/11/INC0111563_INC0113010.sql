BEGIN
  UPDATE CRAWCRD SET
  CDGRAUPR = 6
  where cdcooper = 1
  and nrdconta = 855359
  and nrctrcrd = 2364868;
  COMMIT;
  
  UPDATE crawcrd SET
  CDGRAUPR = 5
  where cdcooper = 1
  and nrdconta = 6463347
  and nrctrcrd = 2227712;
  COMMIT;
END;
