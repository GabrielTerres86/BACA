BEGIN
  
  UPDATE cecred.crapepr
     SET vlsdeved = 0,vlsprojt = 0
   WHERE cdcooper = 1
         AND nrdconta = 8207690
         AND nrctremp = 2416667;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
