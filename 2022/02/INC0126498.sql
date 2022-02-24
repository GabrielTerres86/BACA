BEGIN
  UPDATE crawcrd
     SET cdgraupr = 5
   WHERE cdcooper = 16
     AND nrdconta = 3970329
     AND nrctrcrd = 175053;
  
  COMMIT;
END;  
