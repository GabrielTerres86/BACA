BEGIN
 
  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 11
         AND nrdconta = 82978190
         AND nrctremp = 439891;
 
  COMMIT;
 
END;
