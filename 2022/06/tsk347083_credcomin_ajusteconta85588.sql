BEGIN

  UPDATE cecred.crappep
     SET inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlsdvsji = 0,
         vlpagpar = vlparepr - vldespar
   WHERE nrdconta = 85588
     AND nrctremp = 13038
     AND cdcooper = 10
     AND inliquid = 0;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
