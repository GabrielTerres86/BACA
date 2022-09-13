BEGIN

  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0
   WHERE cdcooper = 5
     AND nrdconta = 117358
     AND nrctremp = 80131;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
