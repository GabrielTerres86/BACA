
BEGIN
  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE cdcooper = 3
     AND nrdconta IN (43, 108, 116, 86, 132)
     AND nrctremp IN (211481, 211480, 211483, 211486, 211496, 211498)
     AND inliquid = 0;
  
  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0
   WHERE cdcooper = 3
     AND nrdconta IN (43, 108, 116, 86, 132)
     AND nrctremp IN (211481, 211480, 211483, 211486, 211496, 211498)
     AND inliquid = 0;
 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
