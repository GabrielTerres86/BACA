BEGIN
  UPDATE crawcrd
     SET cdgraupr = 5
   WHERE cdcooper = 1
     AND nrdconta = 8446008
     AND nrctrcrd = 2131253;
  
  COMMIT;
END;  
