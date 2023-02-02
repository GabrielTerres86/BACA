BEGIN

  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE cdcooper = 3
     AND nrdconta = 27
     AND nrctremp IN (211482, 211484, 211497)
     AND inliquid = 0;

  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0
   WHERE cdcooper = 3
     AND nrdconta = 27
     AND nrctremp IN (211482, 211484, 211497)
     AND inliquid = 0;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
