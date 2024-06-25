BEGIN
 
  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 16
         AND nrdconta = 82870748
         AND nrctremp = 821946;
 
  COMMIT;
 
END;
