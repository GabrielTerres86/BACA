BEGIN

  UPDATE crawepr
     SET insitest = 3, insitapr = 1
   WHERE cdcooper = 6
     AND nrdconta = 83226109
     AND nrctremp = 278885;

  COMMIT;

END;
