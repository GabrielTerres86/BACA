BEGIN
  UPDATE crawcrd w
     SET w.insitcrd = 6
   WHERE w.nrdconta = 2533413
     AND w.cdcooper = 1;
     
 COMMIT;
END;