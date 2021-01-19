BEGIN
  UPDATE crawcrd w 
     SET w.cdgraupr = 5
   WHERE w.cdcooper = 1
     AND w.nrdconta = 9196226
     AND w.nrctrcrd = 1797523;
   
   COMMIT;
END; 
