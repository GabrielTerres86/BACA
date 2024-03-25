BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 13
         AND nrdconta = 99993473
         AND nrctremp = 322737;

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 13
         AND nrdconta = 99515644
         AND nrctremp = 322739;

  COMMIT;

END;
