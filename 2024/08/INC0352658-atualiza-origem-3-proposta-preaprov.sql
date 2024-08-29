BEGIN

  UPDATE cecred.crawepr
     SET cdorigem = 3
   WHERE cdcooper = 11
   AND nrdconta = 489352
   AND nrctremp = 470400;

  UPDATE cecred.crapepr
     SET cdorigem = 3
   WHERE cdcooper = 11
   AND nrdconta = 489352
   AND nrctremp = 470400;
   
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
