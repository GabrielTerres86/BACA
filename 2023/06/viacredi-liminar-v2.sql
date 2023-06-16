BEGIN

  UPDATE cecred.crapepr
     SET qtprecal = 0
   WHERE cdcooper = 1
         AND nrdconta = 12857939
         AND nrctremp = 6232273;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
  
END;
