BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 10
         AND nrdconta = 99971062
         AND nrctremp = 27088;

  COMMIT;

END;