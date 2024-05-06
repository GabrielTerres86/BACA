BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 14
         AND nrdconta = 84015004
         AND nrctremp = 133144;

  COMMIT;

END;
