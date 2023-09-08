BEGIN

  UPDATE cecred.crawepr
     SET vlemprst = 3000, vlpreemp = 272.75
   WHERE cdcooper = 1
         AND nrdconta = 3748464
         AND nrctremp = 7322029;

  UPDATE cecred.crapepr
     SET vlsdvctr = 3273
   WHERE cdcooper = 1
         AND nrdconta = 3748464
         AND nrctremp = 7322029;

  UPDATE cecred.crappep a
     SET a.vlparepr = 272.75, a.vlsdvpar = 272.75, a.vlsdvsji = 272.75
   WHERE cdcooper = 1
         AND nrdconta = 3748464
         AND nrctremp = 7322029;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
