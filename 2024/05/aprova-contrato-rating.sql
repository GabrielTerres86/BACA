BEGIN
  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 8
         AND nrdconta = 99939436
         AND nrctremp = 17706;

  COMMIT;

END;
