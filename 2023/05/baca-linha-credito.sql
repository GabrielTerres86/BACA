BEGIN

  UPDATE crapepr
     SET cdlcremp = 6901
   WHERE cdcooper = 10
         AND nrdconta = 99971062
         AND nrctremp = 27088;

  UPDATE crawepr
     SET cdlcremp = 6901
   WHERE cdcooper = 10
         AND nrdconta = 99971062
         AND nrctremp = 27088;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
