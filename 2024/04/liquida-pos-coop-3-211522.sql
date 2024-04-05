BEGIN
  UPDATE CECRED.crappep a
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0,
         a.dtultpag = to_date('05/04/2024','dd/mm/yyyy') 
   WHERE cdcooper = 3
     AND nrdconta = 94
     AND nrctremp = 211522
     AND inliquid = 0;
  UPDATE CECRED.crapepr a
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0,
        a.dtliquid = to_date('05/04/2024','dd/mm/yyyy') 
   WHERE cdcooper = 3
     AND nrdconta = 94
     AND nrctremp = 211522
     AND inliquid = 0;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;                                
