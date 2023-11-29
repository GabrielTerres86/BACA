BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 6
         AND nrdconta = 99770261
         AND nrctremp = 273896;
  
   COMMIT;

END;
