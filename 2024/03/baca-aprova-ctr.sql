BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 13
         AND nrdconta = 99455960
         AND nrctremp = 322730;

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 13
         AND nrdconta = 99993473
         AND nrctremp = 322731;

  COMMIT;

END;
