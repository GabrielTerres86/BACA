BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 1
     AND nrdconta = 92279333
     AND nrctremp = 8149837;

  COMMIT;

END;
